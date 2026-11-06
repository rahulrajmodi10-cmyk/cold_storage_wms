// lib/services/financial_report_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/finance_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'chart_of_accounts_service.dart';
import 'accounts_receivable_payable_service.dart';

class FinancialReportService {
  final Database db;
  final ChartOfAccountsService chartOfAccountsService;
  final AccountsReceivableService accountsReceivableService;
  final AccountsPayableService accountsPayableService;

  FinancialReportService(this.db, {
    ChartOfAccountsService? chartOfAccountsService,
    AccountsReceivableService? accountsReceivableService,
    AccountsPayableService? accountsPayableService,
  })  : chartOfAccountsService = chartOfAccountsService ?? ChartOfAccountsService(db),
        accountsReceivableService = accountsReceivableService ?? AccountsReceivableService(db),
        accountsPayableService = accountsPayableService ?? AccountsPayableService(db);

  // ============ Reports ============

  Future<Map<String, double>> getProfitLoss(int fromDate, int toDate) async {
    final accounts = await chartOfAccountsService.getAccounts(type: 'REVENUE');
    accounts.addAll(await chartOfAccountsService.getAccounts(type: 'EXPENSE'));

    final Map<String, double> results = {'revenue': 0.0, 'expense': 0.0};

    for (final account in accounts) {
      final result = await db.rawQuery('''
        SELECT
          SUM(jel.debit) as total_debit,
          SUM(jel.credit) as total_credit
        FROM journal_entry_lines jel
        JOIN journal_entries je ON jel.entry_id = je.id
        WHERE jel.account_id = ? AND je.entry_date BETWEEN ? AND ? AND je.status = 'POSTED'
      ''', [account.id, fromDate, toDate]);

      if (result.isNotEmpty) {
        final debit = (result.first['total_debit'] as num?)?.toDouble() ?? 0.0;
        final credit = (result.first['total_credit'] as num?)?.toDouble() ?? 0.0;
        double balance = account.type == 'REVENUE' ? credit - debit : debit - credit;

        if (account.type == 'REVENUE') {
          results['revenue'] = (results['revenue'] ?? 0.0) + balance;
        } else {
          results['expense'] = (results['expense'] ?? 0.0) + balance;
        }
      }
    }

    results['net_profit'] = (results['revenue'] ?? 0.0) - (results['expense'] ?? 0.0);
    return results;
  }

  Future<Map<String, dynamic>> getBalanceSheet(int asOfDate) async {
    final accounts = await chartOfAccountsService.getAccounts();

    double totalAssets = 0.0;
    double totalLiabilities = 0.0;
    double totalEquity = 0.0;

    for (final account in accounts) {
      double balance = account.openingBalance ?? 0.0;

      final result = await db.rawQuery('''
        SELECT
          SUM(jel.debit) as total_debit,
          SUM(jel.credit) as total_credit
        FROM journal_entry_lines jel
        JOIN journal_entries je ON jel.entry_id = je.id
        WHERE jel.account_id = ? AND je.entry_date <= ? AND je.status = 'POSTED'
      ''', [account.id, asOfDate]);

      if (result.isNotEmpty) {
        final debit = (result.first['total_debit'] as num?)?.toDouble() ?? 0.0;
        final credit = (result.first['total_credit'] as num?)?.toDouble() ?? 0.0;

        if (['ASSET', 'EXPENSE'].contains(account.type)) {
          balance += debit - credit;
        } else {
          balance += credit - debit;
        }
      }

      if (account.type == 'ASSET') {
        totalAssets += balance;
      } else if (account.type == 'LIABILITY') {
        totalLiabilities += balance;
      } else if (account.type == 'EQUITY') {
        totalEquity += balance;
      }
    }

    final pl = await getProfitLoss(
      DateTime.fromMillisecondsSinceEpoch(asOfDate).copyWith(month: 1, day: 1).millisecondsSinceEpoch,
      asOfDate
    );
    totalEquity += pl['net_profit'] ?? 0.0;

    final balanced = (totalAssets - (totalLiabilities + totalEquity)).abs() < 0.01;

    return {
      'total_assets': totalAssets,
      'total_liabilities': totalLiabilities,
      'total_equity': totalEquity,
      'balanced': balanced,
    };
  }

  Future<Map<String, double>> getTrialBalance(int asOfDate) async {
    final accounts = await chartOfAccountsService.getAccounts();
    final Map<String, double> balances = {};

    for (final account in accounts) {
      double balance = account.balance;

      final result = await db.rawQuery('''
        SELECT
          SUM(jel.debit) as total_debit,
          SUM(jel.credit) as total_credit
        FROM journal_entry_lines jel
        JOIN journal_entries je ON jel.entry_id = je.id
        WHERE jel.account_id = ? AND je.entry_date <= ? AND je.status = 'POSTED'
      ''', [account.id, asOfDate]);

      if (result.isNotEmpty) {
        final debit = (result.first['total_debit'] as num?)?.toDouble() ?? 0.0;
        final credit = (result.first['total_credit'] as num?)?.toDouble() ?? 0.0;

        if (['ASSET', 'EXPENSE'].contains(account.type)) {
          balance += debit - credit;
        } else {
          balance += credit - debit;
        }
      }

      if (balance != 0) {
        balances[account.code] = balance;
      }
    }

    return balances;
  }

  Future<List<Map<String, dynamic>>> getAgedReceivables(int asOfDate) async {
    return await db.rawQuery('''
      SELECT
        p.name as party_name,
        p.type as party_type,
        ar.outstanding_amount,
        ar.due_date,
        CASE
          WHEN ar.due_date IS NULL THEN 'NO_DUE_DATE'
          WHEN ar.due_date > ? THEN 'NOT_DUE'
          WHEN ar.due_date > ? - 30*24*60*60*1000 THEN '0-30'
          WHEN ar.due_date > ? - 60*24*60*60*1000 THEN '31-60'
          WHEN ar.due_date > ? - 90*24*60*60*1000 THEN '61-90'
          ELSE '90+'
        END as aging_bucket
      FROM accounts_receivable ar
      JOIN parties p ON ar.party_id = p.id
      WHERE ar.status IN ('OPEN', 'PARTIAL') AND ar.outstanding_amount > 0
      ORDER BY ar.due_date
    ''', [asOfDate, asOfDate, asOfDate, asOfDate]);
  }

  Future<List<Map<String, dynamic>>> getAgedPayables(int asOfDate) async {
    return await db.rawQuery('''
      SELECT
        p.name as party_name,
        p.type as party_type,
        ap.outstanding_amount,
        ap.due_date,
        CASE
          WHEN ap.due_date IS NULL THEN 'NO_DUE_DATE'
          WHEN ap.due_date > ? THEN 'NOT_DUE'
          WHEN ap.due_date > ? - 30*24*60*60*1000 THEN '0-30'
          WHEN ap.due_date > ? - 60*24*60*60*1000 THEN '31-60'
          WHEN ap.due_date > ? - 90*24*60*60*1000 THEN '61-90'
          ELSE '90+'
        END as aging_bucket
      FROM accounts_payable ap
      JOIN parties p ON ap.party_id = p.id
      WHERE ap.status IN ('OPEN', 'PARTIAL') AND ap.outstanding_amount > 0
      ORDER BY ap.due_date
    ''', [asOfDate, asOfDate, asOfDate, asOfDate]);
  }
}