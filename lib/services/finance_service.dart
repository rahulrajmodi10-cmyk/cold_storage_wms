// lib/services/finance_service.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/finance_models.dart';

class FinanceService {
  final Database db;

  FinanceService(this.db);

  // ============ Chart of Accounts ============

  Future<int> createAccount(ChartOfAccount account) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = account.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('chart_of_accounts', map);
  }

  Future<ChartOfAccount?> getAccount(int id) async {
    final maps = await db.query('chart_of_accounts', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return ChartOfAccount.fromMap(maps.first);
  }

  Future<List<ChartOfAccount>> getAccounts({String? type, int? parentId, bool activeOnly = true}) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (type != null) {
      where.add('type = ?');
      args.add(type);
    }
    if (parentId != null) {
      where.add('parent_id = ?');
      args.add(parentId);
    }
    if (activeOnly) {
      where.add('is_active = 1');
    }
    final maps = await db.query(
      'chart_of_accounts',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'code',
    );
    return maps.map((m) => ChartOfAccount.fromMap(m)).toList();
  }

  Future<int> updateAccount(ChartOfAccount account) async {
    final map = account.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('chart_of_accounts', map, where: 'id = ?', whereArgs: [account.id]);
  }

  // ============ Parties ============

  Future<int> createParty(Party party) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = party.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('parties', map);
  }

  Future<Party?> getParty(int id) async {
    final maps = await db.query('parties', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Party.fromMap(maps.first);
  }

  Future<List<Party>> getParties({String? type, bool activeOnly = true}) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (type != null) {
      where.add('type = ?');
      args.add(type);
    }
    if (activeOnly) {
      where.add('is_active = 1');
    }
    final maps = await db.query(
      'parties',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'name',
    );
    return maps.map((m) => Party.fromMap(m)).toList();
  }

  Future<int> updateParty(Party party) async {
    final map = party.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('parties', map, where: 'id = ?', whereArgs: [party.id]);
  }

  // ============ Tax Rates ============

  Future<int> createTaxRate(TaxRate taxRate) async {
    return await db.insert('tax_rates', taxRate.toMap());
  }

  Future<List<TaxRate>> getTaxRates({bool activeOnly = true, int? effectiveDate}) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (activeOnly) {
      where.add('is_active = 1');
    }
    if (effectiveDate != null) {
      where.add('effective_from <= ?');
      args.add(effectiveDate);
      where.add('(effective_to IS NULL OR effective_to >= ?)');
      args.add(effectiveDate);
    }
    final maps = await db.query(
      'tax_rates',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'type, rate',
    );
    return maps.map((m) => TaxRate.fromMap(m)).toList();
  }

  // ============ Invoices ============

  Future<int> createInvoice(Invoice invoice) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = invoice.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('invoices', map);
  }

  Future<Invoice?> getInvoice(int id) async {
    final maps = await db.query('invoices', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Invoice.fromMap(maps.first);
  }

  Future<Invoice?> getInvoiceByNumber(String invoiceNumber) async {
    final maps = await db.query('invoices', where: 'invoice_number = ?', whereArgs: [invoiceNumber]);
    if (maps.isEmpty) return null;
    return Invoice.fromMap(maps.first);
  }

  Future<List<Invoice>> getInvoices({
    String? type,
    String? status,
    int? partyId,
    int? fromDate,
    int? toDate,
    int limit = 100,
    int offset = 0,
  }) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (type != null) {
      where.add('type = ?');
      args.add(type);
    }
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    if (partyId != null) {
      where.add('party_id = ?');
      args.add(partyId);
    }
    if (fromDate != null) {
      where.add('invoice_date >= ?');
      args.add(fromDate);
    }
    if (toDate != null) {
      where.add('invoice_date <= ?');
      args.add(toDate);
    }
    final maps = await db.query(
      'invoices',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'invoice_date DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => Invoice.fromMap(m)).toList();
  }

  Future<int> updateInvoice(Invoice invoice) async {
    final map = invoice.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('invoices', map, where: 'id = ?', whereArgs: [invoice.id]);
  }

  Future<int> updateInvoiceStatus(int id, String status, {double? paidAmount, double? balanceAmount}) async {
    final map = {'status': status, 'updated_at': DateTime.now().millisecondsSinceEpoch};
    if (paidAmount != null) map['paid_amount'] = paidAmount;
    if (balanceAmount != null) map['balance_amount'] = balanceAmount;
    return await db.update('invoices', map, where: 'id = ?', whereArgs: [id]);
  }

  // ============ Invoice Items ============

  Future<int> addInvoiceItem(InvoiceItem item) async {
    return await db.insert('invoice_items', item.toMap());
  }

  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    final maps = await db.query('invoice_items', where: 'invoice_id = ?', whereArgs: [invoiceId]);
    return maps.map((m) => InvoiceItem.fromMap(m)).toList();
  }

  Future<int> updateInvoiceItem(InvoiceItem item) async {
    return await db.update('invoice_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> deleteInvoiceItems(int invoiceId) async {
    await db.delete('invoice_items', where: 'invoice_id = ?', whereArgs: [invoiceId]);
  }

  // ============ Payments ============

  Future<int> createPayment(Payment payment) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = payment.toMap();
    map['created_at'] = now;
    return await db.insert('payments', map);
  }

  Future<Payment?> getPayment(int id) async {
    final maps = await db.query('payments', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Payment.fromMap(maps.first);
  }

  Future<List<Payment>> getPayments({
    String? type,
    int? partyId,
    int? invoiceId,
    int? fromDate,
    int? toDate,
    int limit = 100,
    int offset = 0,
  }) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (type != null) {
      where.add('type = ?');
      args.add(type);
    }
    if (partyId != null) {
      where.add('party_id = ?');
      args.add(partyId);
    }
    if (invoiceId != null) {
      where.add('invoice_id = ?');
      args.add(invoiceId);
    }
    if (fromDate != null) {
      where.add('payment_date >= ?');
      args.add(fromDate);
    }
    if (toDate != null) {
      where.add('payment_date <= ?');
      args.add(toDate);
    }
    final maps = await db.query(
      'payments',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'payment_date DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => Payment.fromMap(m)).toList();
  }

  Future<int> updatePaymentStatus(int id, String status) async {
    return await db.update('payments', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  // ============ Accounts Receivable/Payable ============

  Future<int> createReceivable(AccountReceivable ar) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = ar.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('accounts_receivable', map);
  }

  Future<List<AccountReceivable>> getReceivables({int? partyId, String? status}) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (partyId != null) {
      where.add('party_id = ?');
      args.add(partyId);
    }
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    final maps = await db.query(
      'accounts_receivable',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'due_date',
    );
    return maps.map((m) => AccountReceivable.fromMap(m)).toList();
  }

  Future<int> updateReceivable(AccountReceivable ar) async {
    final map = ar.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('accounts_receivable', map, where: 'id = ?', whereArgs: [ar.id]);
  }

  Future<int> createPayable(AccountPayable ap) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = ap.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('accounts_payable', map);
  }

  Future<List<AccountPayable>> getPayables({int? partyId, String? status}) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (partyId != null) {
      where.add('party_id = ?');
      args.add(partyId);
    }
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    final maps = await db.query(
      'accounts_payable',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'due_date',
    );
    return maps.map((m) => AccountPayable.fromMap(m)).toList();
  }

  Future<int> updatePayable(AccountPayable ap) async {
    final map = ap.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('accounts_payable', map, where: 'id = ?', whereArgs: [ap.id]);
  }

  // ============ Journal Entries ============

  Future<int> createJournalEntry(JournalEntry entry) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = entry.toMap();
    map['created_at'] = now;
    final entryId = await db.insert('journal_entries', map);
    return entryId;
  }

  Future<int> addJournalEntryLine(JournalEntryLine line) async {
    return await db.insert('journal_entry_lines', line.toMap());
  }

  Future<void> addJournalEntryLines(int entryId, List<JournalEntryLine> lines) async {
    await db.transaction((txn) async {
      for (final line in lines) {
        final map = line.toMap();
        map['entry_id'] = entryId;
        await txn.insert('journal_entry_lines', map);
      }
    });
  }

  Future<JournalEntry?> getJournalEntry(int id) async {
    final maps = await db.query('journal_entries', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return JournalEntry.fromMap(maps.first);
  }

  Future<List<JournalEntryLine>> getJournalEntryLines(int entryId) async {
    final maps = await db.query('journal_entry_lines', where: 'entry_id = ?', whereArgs: [entryId]);
    return maps.map((m) => JournalEntryLine.fromMap(m)).toList();
  }

  Future<int> postJournalEntry(int entryId, int postedBy) async {
    return await db.update('journal_entries', {
      'status': 'POSTED',
      'posted_at': DateTime.now().millisecondsSinceEpoch,
      'posted_by': postedBy,
    }, where: 'id = ?', whereArgs: [entryId]);
  }

  // ============ Reports ============

  Future<Map<String, double>> getTrialBalance(int asOfDate) async {
    // Get all active accounts
    final accounts = await getAccounts();
    final Map<String, double> balances = {};

    for (final account in accounts) {
      double balance = account.balance;

      // Calculate from journal entries up to asOfDate
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

  Future<Map<String, double>> getProfitAndLoss(int fromDate, int toDate) async {
    final accounts = await getAccounts(type: 'REVENUE');
    accounts.addAll(await getAccounts(type: 'EXPENSE'));

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

  // ============ GST Returns ============

  Future<int> createGSTReturn(GSTReturn return_) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = return_.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('gst_returns', map);
  }

  Future<GSTReturn?> getGSTReturn(int id) async {
    final maps = await db.query('gst_returns', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return GSTReturn.fromMap(maps.first);
  }

  Future<List<GSTReturn>> getGSTRReturns({String? returnType, String? period}) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (returnType != null) {
      where.add('return_type = ?');
      args.add(returnType);
    }
    if (period != null) {
      where.add('period = ?');
      args.add(period);
    }
    final maps = await db.query(
      'gst_returns',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'period DESC',
    );
    return maps.map((m) => GSTReturn.fromMap(m)).toList();
  }

  // ============ Purchase Orders ============

  Future<int> createPurchaseOrder(PurchaseOrder po) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = po.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('purchase_orders', map);
  }

  Future<PurchaseOrder?> getPurchaseOrder(int id) async {
    final maps = await db.query('purchase_orders', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return PurchaseOrder.fromMap(maps.first);
  }

  Future<List<PurchaseOrder>> getPurchaseOrders({String? status, int? vendorId}) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    if (vendorId != null) {
      where.add('vendor_id = ?');
      args.add(vendorId);
    }
    final maps = await db.query(
      'purchase_orders',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'po_date DESC',
    );
    return maps.map((m) => PurchaseOrder.fromMap(m)).toList();
  }

  Future<int> addPurchaseOrderItem(PurchaseOrderItem item) async {
    return await db.insert('purchase_order_items', item.toMap());
  }

  Future<List<PurchaseOrderItem>> getPurchaseOrderItems(int poId) async {
    final maps = await db.query('purchase_order_items', where: 'po_id = ?', whereArgs: [poId]);
    return maps.map((m) => PurchaseOrderItem.fromMap(m)).toList();
  }

  // ============ Sales Orders ============

  Future<int> createSalesOrder(SalesOrder so) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = so.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('sales_orders', map);
  }

  Future<SalesOrder?> getSalesOrder(int id) async {
    final maps = await db.query('sales_orders', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return SalesOrder.fromMap(maps.first);
  }

  Future<List<SalesOrder>> getSalesOrders({String? status, int? customerId}) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    if (customerId != null) {
      where.add('customer_id = ?');
      args.add(customerId);
    }
    final maps = await db.query(
      'sales_orders',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'so_date DESC',
    );
    return maps.map((m) => SalesOrder.fromMap(m)).toList();
  }

  Future<int> addSalesOrderItem(SalesOrderItem item) async {
    return await db.insert('sales_order_items', item.toMap());
  }

  Future<List<SalesOrderItem>> getSalesOrderItems(int soId) async {
    final maps = await db.query('sales_order_items', where: 'so_id = ?', whereArgs: [soId]);
    return maps.map((m) => SalesOrderItem.fromMap(m)).toList();
  }
}