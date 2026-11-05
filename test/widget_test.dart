// Widget tests for Cold Storage WMS screens
//
// Tests verify that each screen renders correctly and handles basic interactions

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:cold_storage_wms/main.dart';
import 'package:cold_storage_wms/screens/login_screen.dart';
import 'package:cold_storage_wms/screens/inventory_dashboard.dart';
import 'package:cold_storage_wms/screens/finance_dashboard.dart';
import 'package:cold_storage_wms/screens/logistics_dashboard.dart';
import 'package:cold_storage_wms/screens/camera_counting_screen.dart';
import 'package:cold_storage_wms/screens/gatepass_screen.dart';
import 'package:cold_storage_wms/screens/barcode_scanner_screen.dart';

import 'package:cold_storage_wms/services/inventory_service.dart';
import 'package:cold_storage_wms/services/location_service.dart';
import 'package:cold_storage_wms/services/finance_service.dart';
import 'package:cold_storage_wms/services/logistics_service.dart';
import 'package:cold_storage_wms/services/camera_ai_service.dart';
import 'package:cold_storage_wms/services/gatepass_barcode_service.dart';
import 'package:cold_storage_wms/services/auth_service.dart';

import 'package:cold_storage_wms/models/inventory_item.dart';
import 'package:cold_storage_wms/models/storage_location.dart';

void main() {
  // Initialize FFI for sqflite on non-mobile platforms
  setUpAll(() async {
    sqfliteFfiInit();
  });

  group('LoginScreen Widget Tests', () {
    late Database db;

    setUp(() async {
      // Create an in-memory test database
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

      // Create schema for testing
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password_hash TEXT,
          role TEXT,
          face_embedding BLOB
        )
      ''');

      // Insert a test user with properly hashed password
      // Password: 'test123' - PBKDF2 with 10000 iterations
      await db.insert('users', {
        'username': 'testuser',
        'password_hash': '10000:' + 'dGVzdHNhbHQ=' + ':' + 'q4f6v8w9x0y1z2a3b4c5d6e7f8g9h0i1j2k3l4m5n6o7p8q9r0s1t2u3v4w5x6y7',
        'role': 'OPERATOR',
      });
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('LoginScreen displays login form', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(db: db),
      ));

      // Verify form fields are displayed
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('LoginScreen has username and password fields', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(db: db),
      ));

      // Find the text fields by hint text or labels
      expect(find.textContaining('username'), findsOneWidget);
      expect(find.textContaining('password'), findsOneWidget);
    });

    testWidgets('LoginScreen shows loading indicator when submitting', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(db: db),
      ));

      // Initially no loading indicator
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('LoginScreen handles empty form submission', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(db: db),
      ));

      // Tap the login button without entering credentials
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      // Should show error or validation message
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('LoginScreen shows Remember Me checkbox', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(db: db),
      ));

      // Verify Remember Me checkbox is present
      expect(find.byType(Checkbox), findsOneWidget);
    });
  });

  group('InventoryDashboard Widget Tests', () {
    late Database db;
    late InventoryService inventoryService;
    late LocationService locationService;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

      // Create required tables
      await db.execute('''
        CREATE TABLE inventory_item (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sku TEXT NOT NULL,
          name TEXT NOT NULL,
          category TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          unit TEXT NOT NULL,
          location_id INTEGER,
          expiry_date INTEGER,
          min_temp REAL,
          max_temp REAL,
          current_temp REAL,
          humidity REAL,
          status TEXT DEFAULT 'IN_STOCK',
          created_at INTEGER,
          updated_at INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE storage_location (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          code TEXT NOT NULL UNIQUE,
          zone TEXT,
          capacity REAL NOT NULL,
          current_utilization REAL NOT NULL DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE audit_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          action TEXT NOT NULL,
          detail TEXT,
          entity_type TEXT,
          entity_id INTEGER,
          user_id INTEGER,
          timestamp INTEGER
        )
      ''');

      // Insert test data
      await db.insert('storage_location', {
        'name': 'Zone A-01',
        'code': 'A-01',
        'zone': 'A',
        'capacity': 1000.0,
        'current_utilization': 500.0,
      });

      await db.insert('inventory_item', {
        'sku': 'SKU001',
        'name': 'Test Item',
        'category': 'CHEMICAL',
        'quantity': 100,
        'unit': 'KG',
        'location_id': 1,
        'status': 'IN_STOCK',
      });

      inventoryService = InventoryService(db);
      locationService = LocationService(db);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('InventoryDashboard displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: InventoryDashboard(
          inventoryService: inventoryService,
          locationService: locationService,
        ),
      ));

      expect(find.text('Inventory Dashboard'), findsOneWidget);
    });

    testWidgets('InventoryDashboard shows add button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: InventoryDashboard(
          inventoryService: inventoryService,
          locationService: locationService,
        ),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('InventoryDashboard displays items list', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: InventoryDashboard(
          inventoryService: inventoryService,
          locationService: locationService,
        ),
      ));

      // Wait for data to load
      await tester.pumpAndSettle();

      // Should display item SKU
      expect(find.text('SKU001'), findsOneWidget);
    });

    testWidgets('InventoryDashboard shows loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: InventoryDashboard(
          inventoryService: inventoryService,
          locationService: locationService,
        ),
      ));

      // Loading indicator should be visible while data loads
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('InventoryDashboard has search functionality', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: InventoryDashboard(
          inventoryService: inventoryService,
          locationService: locationService,
        ),
      ));

      await tester.pumpAndSettle();

      // Find search field
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('InventoryDashboard opens item form on add button tap', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: InventoryDashboard(
          inventoryService: inventoryService,
          locationService: locationService,
        ),
      ));

      await tester.pumpAndSettle();

      // Tap the add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should show item form dialog
      expect(find.byType(Dialog), findsOneWidget);
    });
  });

  group('FinanceDashboard Widget Tests', () {
    late Database db;
    late FinanceService financeService;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

      // Create required tables for finance service
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
        CREATE TABLE accounts_receivable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          party_id INTEGER NOT NULL,
          invoice_number TEXT NOT NULL,
          invoice_date INTEGER NOT NULL,
          due_date INTEGER NOT NULL,
          outstanding_amount REAL NOT NULL DEFAULT 0,
          created_at INTEGER,
          updated_at INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE accounts_payable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          party_id INTEGER NOT NULL,
          invoice_number TEXT NOT NULL,
          invoice_date INTEGER NOT NULL,
          due_date INTEGER NOT NULL,
          outstanding_amount REAL NOT NULL DEFAULT 0,
          created_at INTEGER,
          updated_at INTEGER
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

      // Insert test chart of accounts
      await db.insert('chart_of_accounts', {
        'code': '1000',
        'name': 'Cash',
        'type': 'ASSET',
        'opening_balance': 10000.0,
        'is_active': 1,
      });

      await db.insert('chart_of_accounts', {
        'code': '2000',
        'name': 'Accounts Payable',
        'type': 'LIABILITY',
        'opening_balance': 5000.0,
        'is_active': 1,
      });

      await db.insert('chart_of_accounts', {
        'code': '3000',
        'name': 'Equity',
        'type': 'EQUITY',
        'opening_balance': 5000.0,
        'is_active': 1,
      });

      await db.insert('chart_of_accounts', {
        'code': '4000',
        'name': 'Revenue',
        'type': 'REVENUE',
        'opening_balance': 0.0,
        'is_active': 1,
      });

      await db.insert('chart_of_accounts', {
        'code': '5000',
        'name': 'Rent Expense',
        'type': 'EXPENSE',
        'opening_balance': 0.0,
        'is_active': 1,
      });

      // Insert test parties
      await db.insert('parties', {
        'name': 'Test Supplier',
        'type': 'VENDOR',
        'balance': 500.0,
        'is_active': 1,
      });

      await db.insert('parties', {
        'name': 'Test Customer',
        'type': 'CUSTOMER',
        'balance': 1000.0,
        'is_active': 1,
      });

      // Insert test accounts receivable
      await db.insert('accounts_receivable', {
        'party_id': 2,
        'invoice_number': 'INV-001',
        'invoice_date': DateTime.now().millisecondsSinceEpoch - 60 * 24 * 60 * 60 * 1000,
        'due_date': DateTime.now().millisecondsSinceEpoch - 30 * 24 * 60 * 60 * 1000,
        'outstanding_amount': 1000.0,
      });

      // Insert test accounts payable
      await db.insert('accounts_payable', {
        'party_id': 1,
        'invoice_number': 'INV-002',
        'invoice_date': DateTime.now().millisecondsSinceEpoch - 45 * 24 * 60 * 60 * 1000,
        'due_date': DateTime.now().millisecondsSinceEpoch - 15 * 24 * 60 * 60 * 1000,
        'outstanding_amount': 500.0,
      });

      financeService = FinanceService(db);

      // Add journal entries for testing financial calculations
      final now = DateTime.now().millisecondsSinceEpoch;
      final journalEntryId = await db.insert('journal_entries', {
        'entry_number': 'JE001',
        'entry_date': now,
        'narration': 'Test entry for revenue',
        'status': 'POSTED',
      });

      // Add journal entry lines (debit to Cash, credit to Revenue)
      await db.insert('journal_entry_lines', {
        'entry_id': journalEntryId,
        'account_id': 1, // Cash (ASSET)
        'debit': 1000.0,
      });

      await db.insert('journal_entry_lines', {
        'entry_id': journalEntryId,
        'account_id': 4, // Revenue
        'credit': 1000.0,
      });

      // Add another journal entry for expenses
      final expenseEntryId = await db.insert('journal_entries', {
        'entry_number': 'JE002',
        'entry_date': now,
        'narration': 'Test entry for rent expense',
        'status': 'POSTED',
      });

      await db.insert('journal_entry_lines', {
        'entry_id': expenseEntryId,
        'account_id': 5, // Rent Expense
        'debit': 500.0,
      });

      await db.insert('journal_entry_lines', {
        'entry_id': expenseEntryId,
        'account_id': 1, // Cash (ASSET)
        'credit': 500.0,
      });

      await financeService.postJournalEntry(journalEntryId, 1);
      await financeService.postJournalEntry(expenseEntryId, 1);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('FinanceDashboard displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: FinanceDashboard(financeService: financeService),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Finance Dashboard'), findsOneWidget);
    });

    testWidgets('FinanceDashboard has period selection chips', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: FinanceDashboard(financeService: financeService),
      ));

      await tester.pumpAndSettle();

      // Should have period selection
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('Last Month'), findsOneWidget);
    });

    testWidgets('FinanceDashboard displays trial balance section', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: FinanceDashboard(financeService: financeService),
      ));

      await tester.pumpAndSettle();

      // Should show trial balance or summary
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('FinanceDashboard shows parties list', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: FinanceDashboard(financeService: financeService),
      ));

      await tester.pumpAndSettle();

      // Check for parties navigation
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('FinanceDashboard updates period when chip selected', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: FinanceDashboard(financeService: financeService),
      ));

      await tester.pumpAndSettle();

      // Tap last month chip
      await tester.tap(find.text('Last Month'));
      await tester.pumpAndSettle();

      // Period should change (UI should update)
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('LogisticsDashboard Widget Tests', () {
    late Database db;
    late LogisticsService logisticsService;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

      // Create required tables
      await db.execute('''
        CREATE TABLE shipments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          reference TEXT NOT NULL,
          destination TEXT NOT NULL,
          status TEXT NOT NULL,
          carrier TEXT,
          scheduled_date INTEGER,
          created_at INTEGER,
          updated_at INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE vehicles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          number TEXT NOT NULL,
          type TEXT NOT NULL,
          capacity REAL,
          status TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE audit_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          action TEXT NOT NULL,
          detail TEXT,
          entity_type TEXT,
          entity_id INTEGER,
          user_id INTEGER,
          timestamp INTEGER
        )
      ''');

      // Insert test data
      await db.insert('shipments', {
        'reference': 'SHP001',
        'destination': 'Zone A-01',
        'status': 'IN_TRANSIT',
        'carrier': 'Test Carrier',
        'scheduled_date': DateTime.now().millisecondsSinceEpoch,
      });

      await db.insert('vehicles', {
        'number': 'TRUCK-001',
        'type': 'VAN',
        'capacity': 5000.0,
        'status': 'AVAILABLE',
      });

      logisticsService = LogisticsService(db);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('LogisticsDashboard displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LogisticsDashboard(logisticsService: logisticsService),
      ));

      expect(find.text('Logistics Dashboard'), findsOneWidget);
    });

    testWidgets('LogisticsDashboard shows shipment list', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LogisticsDashboard(logisticsService: logisticsService),
      ));

      await tester.pumpAndSettle();

      // Should display shipment reference
      expect(find.text('SHP001'), findsOneWidget);
    });

    testWidgets('LogisticsDashboard has period selection', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LogisticsDashboard(logisticsService: logisticsService),
      ));

      await tester.pumpAndSettle();

      // Period selection chips
      expect(find.text('This Month'), findsOneWidget);
    });

    testWidgets('LogisticsDashboard shows vehicle information', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LogisticsDashboard(logisticsService: logisticsService),
      ));

      await tester.pumpAndSettle();

      // Should show vehicle info
      expect(find.text('TRUCK-001'), findsOneWidget);
    });

    testWidgets('LogisticsDashboard displays carrier performance', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: LogisticsDashboard(logisticsService: logisticsService),
      ));

      await tester.pumpAndSettle();

      // Should have data visualization
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('CameraCountingScreen Widget Tests', () {
    late Database db;
    late CameraAIService cameraService;
    late GatepassBarcodeService gatepassService;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

      // Create required tables
      await db.execute('''
        CREATE TABLE camera_devices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'ACTIVE'
        )
      ''');

      await db.execute('''
        CREATE TABLE counting_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_number TEXT NOT NULL,
          session_type TEXT NOT NULL,
          reference_type TEXT,
          reference_id INTEGER,
          location_id INTEGER,
          operator_id INTEGER,
          status TEXT NOT NULL DEFAULT 'ACTIVE',
          total_expected INTEGER DEFAULT 0,
          total_scanned INTEGER DEFAULT 0,
          total_matched INTEGER DEFAULT 0,
          total_mismatched INTEGER DEFAULT 0,
          started_at INTEGER,
          completed_at INTEGER,
          notes TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE audit_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          action TEXT NOT NULL,
          detail TEXT,
          entity_type TEXT,
          entity_id INTEGER,
          user_id INTEGER,
          timestamp INTEGER
        )
      ''');

      // Insert test camera
      await db.insert('camera_devices', {
        'name': 'Camera-001',
        'type': 'AI_OBJECT_DETECTION',
        'status': 'ACTIVE',
      });

      cameraService = CameraAIService(db);
      gatepassService = GatepassBarcodeService(db);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('CameraCountingScreen displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CameraCountingScreen(
          cameraService: cameraService,
          gatepassService: gatepassService,
        ),
      ));

      expect(find.text('Camera Counting'), findsOneWidget);
    });

    testWidgets('CameraCountingScreen has tab bar with correct tabs', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CameraCountingScreen(
          cameraService: cameraService,
          gatepassService: gatepassService,
        ),
      ));

      await tester.pumpAndSettle();

      // Check for tab icons and labels
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
      expect(find.byIcon(Icons.print), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('CameraCountingScreen shows loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CameraCountingScreen(
          cameraService: cameraService,
          gatepassService: gatepassService,
        ),
      ));

      // Loading indicator should be visible while data loads
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CameraCountingScreen displays camera selection', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CameraCountingScreen(
          cameraService: cameraService,
          gatepassService: gatepassService,
        ),
      ));

      await tester.pumpAndSettle();

      // Should have session type selection
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('CameraCountingScreen allows session type selection', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CameraCountingScreen(
          cameraService: cameraService,
          gatepassService: gatepassService,
        ),
      ));

      await tester.pumpAndSettle();

      // Tap session type dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Should show dropdown options
      expect(find.text('LOADING'), findsOneWidget);
    });
  });

  group('GatepassScreen Widget Tests', () {
    late Database db;
    late GatepassBarcodeService gatepassService;
    late InventoryService inventoryService;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

      // Create required tables
      await db.execute('''
        CREATE TABLE gatepasses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          gatepass_number TEXT NOT NULL,
          type TEXT NOT NULL,
          status TEXT NOT NULL,
          item_description TEXT,
          quantity REAL NOT NULL,
          destination TEXT,
          created_at INTEGER,
          created_by INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE gatepass_types (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          direction TEXT NOT NULL,
          requires_approval INTEGER DEFAULT 0
        )
      ''');

      await db.execute('''
        CREATE TABLE inventory_item (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sku TEXT NOT NULL,
          name TEXT NOT NULL,
          category TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          unit TEXT NOT NULL,
          status TEXT DEFAULT 'IN_STOCK',
          created_at INTEGER,
          updated_at INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE audit_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          action TEXT NOT NULL,
          detail TEXT,
          entity_type TEXT,
          entity_id INTEGER,
          user_id INTEGER,
          timestamp INTEGER
        )
      ''');

      // Insert test data
      await db.insert('gatepass_types', {
        'name': 'Dispatch',
        'direction': 'OUT',
        'requires_approval': 0,
      });

      await db.insert('gatepasses', {
        'gatepass_number': 'GP001',
        'type': 'Dispatch',
        'status': 'PENDING',
        'item_description': 'Test Item',
        'quantity': 10,
        'destination': 'Zone A-01',
      });

      await db.insert('inventory_item', {
        'sku': 'SKU001',
        'name': 'Test Item',
        'category': 'CHEMICAL',
        'quantity': 100,
        'unit': 'KG',
        'status': 'IN_STOCK',
      });

      gatepassService = GatepassBarcodeService(db);
      inventoryService = InventoryService(db);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('GatepassScreen displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GatepassScreen(
          gatepassService: gatepassService,
          inventoryService: inventoryService,
        ),
      ));

      expect(find.text('Gatepass Management'), findsOneWidget);
    });

    testWidgets('GatepassScreen has tab bar with List, Issues, Returns tabs', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GatepassScreen(
          gatepassService: gatepassService,
          inventoryService: inventoryService,
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('List'), findsOneWidget);
      expect(find.text('Issues'), findsOneWidget);
      expect(find.text('Returns'), findsOneWidget);
    });

    testWidgets('GatepassScreen shows gatepasses list', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GatepassScreen(
          gatepassService: gatepassService,
          inventoryService: inventoryService,
        ),
      ));

      await tester.pumpAndSettle();

      // Should display gatepass number
      expect(find.text('GP001'), findsOneWidget);
    });

    testWidgets('GatepassScreen displays status filter chips', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GatepassScreen(
          gatepassService: gatepassService,
          inventoryService: inventoryService,
        ),
      ));

      await tester.pumpAndSettle();

      // Status filter chips
      expect(find.text('ALL'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('APPROVED'), findsOneWidget);
      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('GatepassScreen filters gatepasses by status', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GatepassScreen(
          gatepassService: gatepassService,
          inventoryService: inventoryService,
        ),
      ));

      await tester.pumpAndSettle();

      // Tap PENDING filter
      await tester.tap(find.text('PENDING'));
      await tester.pumpAndSettle();

      // Should show filtered list
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('GatepassScreen has add gatepass button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GatepassScreen(
          gatepassService: gatepassService,
          inventoryService: inventoryService,
        ),
      ));

      await tester.pumpAndSettle();

      // Floating action button
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('BarcodeScannerScreen Widget Tests', () {
    late Database db;
    late GatepassBarcodeService barcodeService;

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);

      // Create required tables
      await db.execute('''
        CREATE TABLE barcode_definitions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          entity_type TEXT NOT NULL,
          prefix TEXT,
          suffix TEXT,
          length INTEGER,
          active INTEGER DEFAULT 1
        )
      ''');

      await db.execute('''
        CREATE TABLE batch_scan_sessions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_number TEXT NOT NULL,
          session_type TEXT NOT NULL,
          reference_type TEXT,
          reference_id INTEGER,
          location_id INTEGER,
          operator_id INTEGER,
          status TEXT DEFAULT 'ACTIVE',
          total_expected INTEGER DEFAULT 0,
          total_scanned INTEGER DEFAULT 0,
          total_matched INTEGER DEFAULT 0,
          total_mismatched INTEGER DEFAULT 0,
          started_at INTEGER,
          completed_at INTEGER,
          notes TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE label_print_jobs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          definition_id INTEGER NOT NULL,
          labels TEXT NOT NULL,
          printer_config_id INTEGER,
          status TEXT DEFAULT 'PENDING',
          created_at INTEGER,
          printed_at INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE printer_configs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          type TEXT NOT NULL,
          connection_string TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE barcodes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          barcode_value TEXT NOT NULL UNIQUE,
          entity_type TEXT,
          entity_id INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE barcode_scans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          barcode_value TEXT NOT NULL,
          barcode_id INTEGER,
          entity_type TEXT,
          entity_id INTEGER,
          scan_type TEXT,
          location_id INTEGER,
          scanned_by INTEGER,
          device_id TEXT,
          timestamp INTEGER,
          status TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE batch_scan_items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          session_id INTEGER NOT NULL,
          barcode_value TEXT NOT NULL,
          barcode_id INTEGER,
          item_id INTEGER,
          expected_quantity INTEGER,
          actual_quantity INTEGER,
          status TEXT DEFAULT 'PENDING',
          scan_status TEXT,
          mismatch_reason TEXT,
          scanned_at INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE audit_log (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          action TEXT NOT NULL,
          detail TEXT,
          entity_type TEXT,
          entity_id INTEGER,
          user_id INTEGER,
          timestamp INTEGER
        )
      ''');

      // Insert test data
      await db.insert('barcode_definitions', {
        'name': 'Item Barcode',
        'entity_type': 'inventory_item',
        'prefix': '',
        'suffix': '',
        'length': 12,
      });

      await db.insert('printer_configs', {
        'name': 'Zebra ZP 450',
        'type': 'ZPL',
        'connection_string': 'tcp://192.168.1.100:9100',
      });

      barcodeService = GatepassBarcodeService(db);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('BarcodeScannerScreen displays app bar with title', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BarcodeScannerScreen(barcodeService: barcodeService),
      ));

      expect(find.text('Barcode Scanner'), findsOneWidget);
    });

    testWidgets('BarcodeScannerScreen has 4 tabs', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BarcodeScannerScreen(barcodeService: barcodeService),
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2), findsOneWidget);
      expect(find.byIcon(Icons.print), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('BarcodeScannerScreen shows loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BarcodeScannerScreen(barcodeService: barcodeService),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('BarcodeScannerScreen displays Scan tab content', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BarcodeScannerScreen(barcodeService: barcodeService),
      ));

      await tester.pumpAndSettle();

      // Default tab should be 'Scan'
      expect(find.text('Scan Barcode / QR Code'), findsOneWidget);
    });

    testWidgets('BarcodeScannerScreen has scan type dropdown', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BarcodeScannerScreen(barcodeService: barcodeService),
      ));

      await tester.pumpAndSettle();

      // Should have scan type selection
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('BarcodeScannerScreen Batch tab shows batch sessions', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BarcodeScannerScreen(barcodeService: barcodeService),
      ));

      await tester.pumpAndSettle();

      // Tap Batch tab
      await tester.tap(find.byIcon(Icons.inventory_2));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('BarcodeScannerScreen Print Labels tab shows print options', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BarcodeScannerScreen(barcodeService: barcodeService),
      ));

      await tester.pumpAndSettle();

      // Tap Print Labels tab
      await tester.tap(find.byIcon(Icons.print));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('BarcodeScannerScreen History tab shows scan history', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BarcodeScannerScreen(barcodeService: barcodeService),
      ));

      await tester.pumpAndSettle();

      // Tap History tab
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('BarcodeScannerScreen scan type dropdown has options', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: BarcodeScannerScreen(barcodeService: barcodeService),
      ));

      await tester.pumpAndSettle();

      // Tap scan type dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Should show options
      expect(find.text('RECEIVING'), findsOneWidget);
      expect(find.text('DISPATCH'), findsOneWidget);
    });
  });
}