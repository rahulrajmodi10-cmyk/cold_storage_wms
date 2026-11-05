// test/finance_service_test.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import '../lib/services/finance_service.dart';
import '../lib/models/finance_models.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late FinanceService service;

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE chart_of_accounts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT NOT NULL,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            parent_id INTEGER,
            balance REAL DEFAULT 0,
            opening_balance REAL DEFAULT 0,
            is_active INTEGER DEFAULT 1,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE parties (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            type TEXT NOT NULL,
            balance REAL DEFAULT 0,
            is_active INTEGER DEFAULT 1,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE journal_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entry_number TEXT NOT NULL,
            entry_date INTEGER NOT NULL,
            narration TEXT,
            reference_type TEXT,
            reference_id INTEGER,
            status TEXT DEFAULT 'POSTED',
            created_by INTEGER,
            posted_at INTEGER,
            posted_by INTEGER,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE journal_entry_lines (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            entry_id INTEGER NOT NULL,
            account_id INTEGER NOT NULL,
            debit REAL DEFAULT 0,
            credit REAL DEFAULT 0,
            narration TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE audit_log (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER,
            action TEXT,
            detail TEXT,
            timestamp INTEGER,
            entity_type TEXT,
            entity_id INTEGER
          )
        ''');
      },
    );
    service = FinanceService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Chart of Accounts', () {
    test('create account', () async {
      final account = ChartOfAccount(
        code: '1000',
        name: 'Cash',
        type: 'ASSET',
        openingBalance: 10000.0,
      );

      final id = await service.createAccount(account);
      expect(id, greaterThan(0));

      final retrieved = await service.getAccount(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.code, '1000');
      expect(retrieved.name, 'Cash');
    });

    test('get accounts by type', () async {
      await service.createAccount(ChartOfAccount(code: '1000', name: 'Cash', type: 'ASSET'));
      await service.createAccount(ChartOfAccount(code: '4000', name: 'Revenue', type: 'REVENUE'));
      await service.createAccount(ChartOfAccount(code: '5000', name: 'Rent', type: 'EXPENSE'));

      final assets = await service.getAccounts(type: 'ASSET');
      final revenue = await service.getAccounts(type: 'REVENUE');

      expect(assets.length, 1);
      expect(revenue.length, 1);
    });

    test('update account', () async {
      final account = ChartOfAccount(code: '1000', name: 'Cash', type: 'ASSET');
      final id = await service.createAccount(account);

      final updated = ChartOfAccount(
        id: id,
        code: '1000',
        name: 'Operating Cash',
        type: 'ASSET',
      );
      await service.updateAccount(updated);

      final retrieved = await service.getAccount(id);
      expect(retrieved!.name, 'Operating Cash');
    });
  });

  group('Parties', () {
    test('create party', () async {
      final party = Party(
        name: 'Test Supplier',
        type: 'VENDOR',
      );

      final id = await service.createParty(party);
      expect(id, greaterThan(0));

      final retrieved = await service.getParty(id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, 'Test Supplier');
    });

    test('get parties by type', () async {
      await service.createParty(Party(name: 'Supplier A', type: 'VENDOR'));
      await service.createParty(Party(name: 'Customer B', type: 'CUSTOMER'));

      final suppliers = await service.getParties(type: 'VENDOR');
      final customers = await service.getParties(type: 'CUSTOMER');

      expect(suppliers.length, 1);
      expect(customers.length, 1);
    });

    test('get all parties', () async {
      await service.createParty(Party(name: 'Supplier A', type: 'VENDOR'));

      final parties = await service.getParties();
      expect(parties.length, greaterThan(0));
    });
  });

  group('Journal Entries', () {
    test('create journal entry', () async {
      final account = ChartOfAccount(code: '1000', name: 'Cash', type: 'ASSET');
      final accountId = await service.createAccount(account);

      final entry = JournalEntry(
        entryNumber: 'JE001',
        entryDate: DateTime.now().millisecondsSinceEpoch,
        narration: 'Test entry',
      );
      final entryId = await service.createJournalEntry(entry);
      expect(entryId, greaterThan(0));

      // Add lines
      final lineDebit = JournalEntryLine(
        entryId: entryId,
        accountId: accountId,
        debit: 1000.0,
      );
      final lineCredit = JournalEntryLine(
        entryId: entryId,
        accountId: accountId,
        credit: 1000.0,
      );

      await service.addJournalEntryLine(lineDebit);
      await service.addJournalEntryLine(lineCredit);

      final lines = await service.getJournalEntryLines(entryId);
      expect(lines.length, 2);
    });

    test('post journal entry', () async {
      final cashAccount = ChartOfAccount(code: '1000', name: 'Cash', type: 'ASSET');
      final assetAccountId = await service.createAccount(cashAccount);

      final entry = JournalEntry(
        entryNumber: 'JE003',
        entryDate: DateTime.now().millisecondsSinceEpoch,
        narration: 'Revenue entry',
      );
      final entryId = await service.createJournalEntry(entry);

      // Add a line
      await service.addJournalEntryLine(JournalEntryLine(
        entryId: entryId,
        accountId: assetAccountId,
        debit: 1000.0,
      ));

      // Post the entry
      final postedId = await service.postJournalEntry(entryId, 1);
      expect(postedId, entryId);
    });
  });

  group('Trial Balance', () {
    test('get trial balance', () async {
      final account = ChartOfAccount(code: '1000', name: 'Cash', type: 'ASSET', openingBalance: 10000.0);
      await service.createAccount(account);

      final trialBalance = await service.getTrialBalance(DateTime.now().millisecondsSinceEpoch);

      expect(trialBalance, isNotNull);
      expect(trialBalance['1000'], 10000.0);
    });
  });

  group('Profit and Loss', () {
    test('get profit and loss', () async {
      // Create accounts needed for P&L
      final revenueAccount = ChartOfAccount(code: '4000', name: 'Revenue', type: 'REVENUE');
      final expenseAccount = ChartOfAccount(code: '5000', name: 'Rent', type: 'EXPENSE');
      await service.createAccount(revenueAccount);
      await service.createAccount(expenseAccount);

      final now = DateTime.now().millisecondsSinceEpoch;
      final profitAndLoss = await service.getProfitAndLoss(now, now);

      expect(profitAndLoss, isNotNull);
      expect(profitAndLoss, isA<Map<String, double>>());
    });
  });

  group('Balance Sheet', () {
    test('get balance sheet', () async {
      await service.createAccount(ChartOfAccount(code: '1000', name: 'Cash', type: 'ASSET', openingBalance: 10000.0));
      await service.createAccount(ChartOfAccount(code: '2000', name: 'Liabilities', type: 'LIABILITY', openingBalance: 5000.0));
      await service.createAccount(ChartOfAccount(code: '3000', name: 'Equity', type: 'EQUITY', openingBalance: 5000.0));

      final balanceSheet = await service.getBalanceSheet(DateTime.now().millisecondsSinceEpoch);

      expect(balanceSheet, isNotNull);
      expect(balanceSheet['total_assets'], 10000.0);
      expect(balanceSheet['balanced'], isTrue);
    });
  });

  group('Aged Receivables/Payables', () {
    test('get aged receivables', () async {
      final result = await service.getAgedReceivables(DateTime.now().millisecondsSinceEpoch);
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test('get aged payables', () async {
      final result = await service.getAgedPayables(DateTime.now().millisecondsSinceEpoch);
      expect(result, isA<List<Map<String, dynamic>>>());
    });
  });
}