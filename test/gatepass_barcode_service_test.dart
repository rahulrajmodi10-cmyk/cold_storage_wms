// test/gatepass_barcode_service_test.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import '../lib/services/gatepass_barcode_service.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late GatepassBarcodeService service;

  setUp(() async {
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE gatepasses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            gatepass_number TEXT NOT NULL UNIQUE,
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
          CREATE TABLE batch_scan_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            barcode_value TEXT NOT NULL,
            barcode_id INTEGER,
            item_id INTEGER,
            expected_quantity INTEGER,
            actual_quantity INTEGER,
            scan_status TEXT,
            mismatch_reason TEXT,
            scanned_at INTEGER
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
    service = GatepassBarcodeService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Gatepasses', () {
    test('create gatepass', () async {
      final id = await service.createGatepass(
        gatepassNumber: 'GP001',
        type: 'Dispatch',
        itemDescription: 'Test Item',
        quantity: 10,
        destination: 'Zone A-01',
      );

      expect(id, greaterThan(0));

      final gp = await db.query('gatepasses', where: 'id = ?', whereArgs: [id]);
      expect(gp.first['gatepass_number'], 'GP001');
      expect(gp.first['status'], 'PENDING');
    });

    test('get gatepasses by status', () async {
      await db.insert('gatepasses', {
        'gatepass_number': 'GP001',
        'type': 'Dispatch',
        'status': 'PENDING',
        'item_description': 'Item 1',
        'quantity': 10,
      });
      await db.insert('gatepasses', {
        'gatepass_number': 'GP002',
        'type': 'Return',
        'status': 'COMPLETED',
        'item_description': 'Item 2',
        'quantity': 5,
      });

      final pending = await service.getGatepasses(status: 'PENDING');
      final completed = await service.getGatepasses(status: 'COMPLETED');

      expect(pending.length, 1);
      expect(completed.length, 1);
    });

    test('update gatepass status', () async {
      final id = await service.createGatepass(gatepassNumber: 'GP003', type: 'Dispatch', quantity: 10);

      await service.updateGatepassStatus(id, 'APPROVED');

      final gp = await db.query('gatepasses', where: 'id = ?', whereArgs: [id]);
      expect(gp.first['status'], 'APPROVED');
    });

    test('cancel gatepass', () async {
      final id = await service.createGatepass(gatepassNumber: 'GP004', type: 'Dispatch', quantity: 10);

      await service.cancelGatepass(id);

      final gp = await db.query('gatepasses', where: 'id = ?', whereArgs: [id]);
      expect(gp.first['status'], 'CANCELLED');
    });
  });

  group('Gatepass Types', () {
    test('get gatepass types', () async {
      await db.insert('gatepass_types', {'name': 'Dispatch', 'direction': 'OUT', 'requires_approval': 0});
      await db.insert('gatepass_types', {'name': 'Return', 'direction': 'IN', 'requires_approval': 1});

      final types = await service.getGatepassTypes();

      expect(types.length, 2);
    });
  });

  group('Barcode Scanning', () {
    test('record barcode scan', () async {
      final scanId = await service.recordBarcodeScan(
        barcodeValue: 'BARCODE123',
        scanType: 'DISPATCH',
        locationId: 1,
        scannedBy: 1,
        deviceId: 'CAMERA-001',
      );

      expect(scanId, greaterThan(0));

      final scan = await db.query('barcodes', where: 'barcode_value = ?', whereArgs: ['BARCODE123']);
      expect(scan.first['barcode_value'], 'BARCODE123');
    });

    test('lookup barcode', () async {
      await db.insert('barcodes', {
        'barcode_value': 'BARCODE123',
        'entity_type': 'inventory_item',
        'entity_id': 1,
      });

      final result = await service.lookupBarcode('BARCODE123');

      expect(result, isNotNull);
      expect(result!['barcode_value'], 'BARCODE123');
    });

    test('search barcodes by pattern', () async {
      await db.insert('barcodes', {'barcode_value': 'ITEM001', 'entity_type': 'inventory_item', 'entity_id': 1});
      await db.insert('barcodes', {'barcode_value': 'ITEM002', 'entity_type': 'inventory_item', 'entity_id': 2});

      final results = await service.searchBarcodes('ITEM00');

      expect(results.length, 2);
    });

    test('get scan history', () async {
      await db.insert('barcodes', {
        'barcode_value': 'BAR001',
        'entity_type': 'inventory_item',
        'entity_id': 1,
      });
      await db.insert('barcode_scans', {
        'barcode_value': 'BAR001',
        'barcode_id': 1,
        'scan_type': 'RECEIVING',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      final history = await service.getScanHistory();

      expect(history.length, greaterThan(0));
    });
  });

  group('Batch Scanning', () {
    test('create batch scan session', () async {
      final id = await service.createBatchScanSession(
        sessionType: 'RECEIVING',
        referenceId: 1,
        locationId: 1,
        expectedQuantity: 100,
      );

      expect(id, greaterThan(0));

      final session = await db.query('batch_scan_sessions', where: 'id = ?', whereArgs: [id]);
      expect(session.first['status'], 'ACTIVE');
    });

    test('add item to batch session', () async {
      final sessionId = await service.createBatchScanSession(
        sessionType: 'RECEIVING',
        expectedQuantity: 10,
      );

      await service.addItemToBatchSession(sessionId, 'BARCODE001', 1);

      final items = await db.query('batch_scan_items', where: 'session_id = ?', whereArgs: [sessionId]);
      expect(items.length, 1);
    });

    test('mark item as scanned in batch', () async {
      final sessionId = await service.createBatchScanSession(sessionType: 'RECEIVING');
      final itemId = await db.insert('batch_scan_items', {
        'session_id': sessionId,
        'barcode_value': 'BARCODE001',
      });

      await service.markItemScanned(sessionId, itemId, status: 'MATCHED');

      final item = await db.query('batch_scan_items', where: 'id = ?', whereArgs: [itemId]);
      expect(item.first['scan_status'], 'MATCHED');
    });

    test('complete batch session', () async {
      final sessionId = await service.createBatchScanSession(
        sessionType: 'RECEIVING',
        expectedQuantity: 10,
      );

      await service.completeBatchSession(sessionId);

      final session = await db.query('batch_scan_sessions', where: 'id = ?', whereArgs: [sessionId]);
      expect(session.first['status'], 'COMPLETED');
    });
  });

  group('Barcode Definitions', () {
    test('get barcode definitions', () async {
      await db.insert('barcode_definitions', {
        'name': 'Inventory Barcode',
        'entity_type': 'inventory_item',
        'prefix': '',
        'suffix': '',
        'length': 12,
      });

      final defs = await service.getBarcodeDefinitions();

      expect(defs.length, 1);
    });
  });

  group('Label Printing', () {
    test('create print job', () async {
      final defId = await db.insert('barcode_definitions', {
        'name': 'Label Def',
        'entity_type': 'inventory_item',
        'length': 12,
      });

      final jobId = await service.createPrintJob(
        definitionId: defId,
        labels: ['LABEL1', 'LABEL2'],
      );

      expect(jobId, greaterThan(0));

      final job = await db.query('label_print_jobs', where: 'id = ?', whereArgs: [jobId]);
      expect(job.first['labels'], '["LABEL1","LABEL2"]');
      expect(job.first['status'], 'PENDING');
    });

    test('cancel print job', () async {
      final defId = await db.insert('barcode_definitions', {'name': 'Label Def', 'entity_type': 'test', 'length': 12});
      final jobId = await service.createPrintJob(definitionId: defId, labels: ['LABEL1']);

      await service.cancelPrintJob(jobId);

      final job = await db.query('label_print_jobs', where: 'id = ?', whereArgs: [jobId]);
      expect(job.first['status'], 'CANCELLED');
    });

    test('get pending print jobs', () async {
      await db.insert('label_print_jobs', {'definition_id': 1, 'labels': '["L1"]', 'status': 'PENDING'});
      await db.insert('label_print_jobs', {'definition_id': 1, 'labels': '["L2"]', 'status': 'PRINTED'});

      final pending = await service.getPrintJobs(status: 'PENDING');

      expect(pending.length, 1);
    });
  });

  group('Printer Configurations', () {
    test('get printer configurations', () async {
      await db.insert('printer_configs', {
        'name': 'Zebra ZP 450',
        'type': 'ZPL',
        'connection_string': 'tcp://192.168.1.100:9100',
      });

      final configs = await service.getPrinterConfigs();

      expect(configs.length, 1);
      expect(configs.first['name'], 'Zebra ZP 450');
    });

    test('create printer configuration', () async {
      final id = await service.createPrinterConfig(
        name: 'New Printer',
        type: 'ZPL',
        connectionString: 'tcp://192.168.1.200:9100',
      );

      expect(id, greaterThan(0));
    });
  });
}