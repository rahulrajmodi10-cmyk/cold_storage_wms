import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';
import 'package:cold_storage_wms/services/gatepass_barcode_service.dart';
import 'package:cold_storage_wms/models/gatepass_barcode_models.dart';

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
          CREATE TABLE gatepass_types (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            description TEXT,
            workflow_type TEXT,
            requires_vehicle INTEGER DEFAULT 1,
            requires_driver INTEGER DEFAULT 1,
            requires_security_check INTEGER DEFAULT 1,
            validity_hours INTEGER DEFAULT 24,
            color_code TEXT,
            is_active INTEGER DEFAULT 1,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE gatepass (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            gatepass_number TEXT NOT NULL UNIQUE,
            gatepass_type_id INTEGER NOT NULL,
            reference_type TEXT,
            reference_id INTEGER,
            party_id INTEGER,
            status TEXT NOT NULL DEFAULT 'DRAFT',
            priority TEXT DEFAULT 'NORMAL',
            vehicle_id INTEGER,
            vehicle_number TEXT,
            vehicle_type TEXT,
            driver_name TEXT,
            driver_phone TEXT,
            driver_license TEXT,
            driver_photo_path TEXT,
            requested_date INTEGER,
            approved_date INTEGER,
            valid_from INTEGER,
            valid_to INTEGER,
            actual_entry_time INTEGER,
            actual_exit_time INTEGER,
            entry_gate_id INTEGER,
            exit_gate_id INTEGER,
            origin_location TEXT,
            destination_location TEXT,
            security_officer_id INTEGER,
            security_check_status TEXT,
            security_notes TEXT,
            seal_number TEXT,
            seal_intact INTEGER DEFAULT 1,
            qr_code_data TEXT,
            qr_code_image_path TEXT,
            qr_generated_at INTEGER,
            total_items INTEGER DEFAULT 0,
            total_quantity REAL DEFAULT 0,
            total_weight REAL DEFAULT 0,
            total_packages INTEGER DEFAULT 0,
            verified_by INTEGER,
            verified_at INTEGER,
            verification_method TEXT,
            discrepancy_notes TEXT,
            approved_by INTEGER,
            approved_at INTEGER,
            rejection_reason TEXT,
            completed_by INTEGER,
            completed_at INTEGER,
            completion_notes TEXT,
            created_by INTEGER,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE barcode_definitions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            symbology TEXT NOT NULL,
            prefix TEXT,
            suffix TEXT,
            format_template TEXT,
            width_mm REAL,
            height_mm REAL,
            module_width REAL,
            include_text INTEGER DEFAULT 1,
            font_size INTEGER,
            error_correction TEXT,
            is_active INTEGER DEFAULT 1,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE barcodes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            barcode_value TEXT NOT NULL UNIQUE,
            barcode_type_id INTEGER NOT NULL,
            entity_type TEXT NOT NULL,
            entity_id INTEGER NOT NULL,
            label_data TEXT,
            image_path TEXT,
            print_count INTEGER DEFAULT 0,
            last_printed_at INTEGER,
            printed_by INTEGER,
            status TEXT DEFAULT 'ACTIVE',
            expires_at INTEGER,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE barcode_scans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            scan_session_id INTEGER,
            barcode_value TEXT NOT NULL,
            barcode_id INTEGER,
            entity_type TEXT,
            entity_id INTEGER,
            scan_type TEXT,
            location_id INTEGER,
            scanned_by INTEGER,
            device_id TEXT,
            latitude REAL,
            longitude REAL,
            quantity REAL DEFAULT 1,
            unit TEXT,
            status TEXT DEFAULT 'SUCCESS',
            error_message TEXT,
            timestamp INTEGER,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE batch_scan_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_number TEXT NOT NULL,
            session_type TEXT,
            reference_type TEXT,
            reference_id INTEGER,
            location_id INTEGER,
            operator_id INTEGER,
            status TEXT DEFAULT 'IN_PROGRESS',
            total_expected INTEGER DEFAULT 0,
            total_scanned INTEGER DEFAULT 0,
            total_matched INTEGER DEFAULT 0,
            total_mismatched INTEGER DEFAULT 0,
            started_at INTEGER,
            completed_at INTEGER,
            notes TEXT,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE batch_scan_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            barcode_value TEXT,
            barcode_id INTEGER,
            item_id INTEGER,
            expected_quantity REAL,
            scanned_quantity REAL DEFAULT 0,
            matched INTEGER DEFAULT 0,
            mismatch_reason TEXT,
            status TEXT DEFAULT 'PENDING',
            scanned_at INTEGER,
            verified_by INTEGER,
            verified_at INTEGER,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE label_print_jobs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            job_number TEXT,
            barcode_definition_id INTEGER NOT NULL,
            entity_type TEXT NOT NULL,
            entity_ids TEXT,
            label_data_json TEXT,
            copies INTEGER DEFAULT 1,
            printer_name TEXT,
            printer_type TEXT,
            label_width_mm REAL,
            label_height_mm REAL,
            status TEXT DEFAULT 'QUEUED',
            printed_count INTEGER DEFAULT 0,
            failed_count INTEGER DEFAULT 0,
            error_log TEXT,
            requested_by INTEGER,
            requested_at INTEGER,
            started_at INTEGER,
            completed_at INTEGER,
            created_at INTEGER,
            updated_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE printer_configs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            printer_type TEXT,
            connection_type TEXT,
            ip_address TEXT,
            port INTEGER,
            usb_vid_pid TEXT,
            bluetooth_mac TEXT,
            serial_port TEXT,
            baud_rate INTEGER,
            paper_width_mm REAL,
            paper_height_mm REAL,
            print_speed INTEGER,
            print_density INTEGER,
            is_default INTEGER DEFAULT 0,
            is_active INTEGER DEFAULT 1,
            test_print_command TEXT,
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
      },
    );
    service = GatepassBarcodeService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Gatepass Types', () {
    test('createGatepassType inserts a gatepass type', () async {
      final type = GatepassType(
        code: 'DRP',
        name: 'Dispatch',
        description: 'Outbound dispatch gatepass',
        isActive: 1,
      );

      final id = await service.createGatepassType(type);

      expect(id, greaterThan(0));

      final maps = await db.query('gatepass_types', where: 'id = ?', whereArgs: [id]);
      expect(maps.first['code'], 'DRP');
      expect(maps.first['name'], 'Dispatch');
      expect(maps.first['is_active'], 1);
    });

    test('getGatepassTypes returns active gatepass types', () async {
      await db.insert('gatepass_types', {
        'code': 'DRP',
        'name': 'Dispatch',
        'is_active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      await db.insert('gatepass_types', {
        'code': 'RET',
        'name': 'Return',
        'is_active': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      final types = await service.getGatepassTypes(activeOnly: true);

      expect(types.length, 1);
      expect(types.first.code, 'DRP');
    });

    test('getGatepassTypes returns all types when activeOnly is false', () async {
      await db.insert('gatepass_types', {
        'code': 'DRP',
        'name': 'Dispatch',
        'is_active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      await db.insert('gatepass_types', {
        'code': 'RET',
        'name': 'Return',
        'is_active': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      final types = await service.getGatepassTypes(activeOnly: false);

      expect(types.length, 2);
    });
  });

  group('Gatepass', () {
    test('createGatepass inserts a gatepass', () async {
      final gatepass = Gatepass(
        gatepassNumber: 'GP-001',
        gatepassTypeId: 1,
        status: 'DRAFT',
        totalQuantity: 10,
      );

      final id = await service.createGatepass(gatepass);

      expect(id, greaterThan(0));

      final maps = await db.query('gatepass', where: 'id = ?', whereArgs: [id]);
      expect(maps.first['gatepass_number'], 'GP-001');
      expect(maps.first['status'], 'DRAFT');
    });

    test('getGatepass returns gatepass by id', () async {
      await db.insert('gatepass', {
        'gatepass_number': 'GP-001',
        'gatepass_type_id': 1,
        'status': 'DRAFT',
        'requested_date': DateTime.now().millisecondsSinceEpoch,
      });

      final gatepass = await service.getGatepass(1);

      expect(gatepass, isNotNull);
      expect(gatepass!.gatepassNumber, 'GP-001');
    });

    test('getGatepassByNumber returns gatepass by number', () async {
      await db.insert('gatepass', {
        'gatepass_number': 'GP-001',
        'gatepass_type_id': 1,
        'status': 'DRAFT',
        'requested_date': DateTime.now().millisecondsSinceEpoch,
      });

      final gatepass = await service.getGatepassByNumber('GP-001');

      expect(gatepass, isNotNull);
      expect(gatepass!.gatepassNumber, 'GP-001');
    });

    test('getGatepasses returns list filtered by status', () async {
      await db.insert('gatepass', {
        'gatepass_number': 'GP-001',
        'gatepass_type_id': 1,
        'status': 'PENDING',
        'requested_date': DateTime.now().millisecondsSinceEpoch,
      });
      await db.insert('gatepass', {
        'gatepass_number': 'GP-002',
        'gatepass_type_id': 1,
        'status': 'COMPLETED',
        'requested_date': DateTime.now().millisecondsSinceEpoch,
      });

      final pending = await service.getGatepasses(status: 'PENDING');
      final completed = await service.getGatepasses(status: 'COMPLETED');

      expect(pending.length, 1);
      expect(pending.first.gatepassNumber, 'GP-001');
      expect(completed.length, 1);
      expect(completed.first.gatepassNumber, 'GP-002');
    });

    test('updateGatepassStatus changes gatepass status', () async {
      await db.insert('gatepass', {
        'gatepass_number': 'GP-001',
        'gatepass_type_id': 1,
        'status': 'DRAFT',
        'requested_date': DateTime.now().millisecondsSinceEpoch,
      });

      await service.updateGatepassStatus(1, 'SUBMITTED');

      final maps = await db.query('gatepass', where: 'id = ?', whereArgs: [1]);
      expect(maps.first['status'], 'SUBMITTED');
    });

    test('approveGatepass sets status to APPROVED', () async {
      await db.insert('gatepass', {
        'gatepass_number': 'GP-001',
        'gatepass_type_id': 1,
        'status': 'SUBMITTED',
        'requested_date': DateTime.now().millisecondsSinceEpoch,
      });

      await service.approveGatepass(1, 1);

      final maps = await db.query('gatepass', where: 'id = ?', whereArgs: [1]);
      expect(maps.first['status'], 'APPROVED');
      expect(maps.first['approved_by'], 1);
    });

    test('completeGatepass sets status to COMPLETED', () async {
      await db.insert('gatepass', {
        'gatepass_number': 'GP-001',
        'gatepass_type_id': 1,
        'status': 'ACTIVE',
        'requested_date': DateTime.now().millisecondsSinceEpoch,
      });

      await service.completeGatepass(1, 1, notes: 'Shipment delivered');

      final maps = await db.query('gatepass', where: 'id = ?', whereArgs: [1]);
      expect(maps.first['status'], 'COMPLETED');
      expect(maps.first['completed_by'], 1);
    });

    test('cancelGatepass sets status to CANCELLED', () async {
      await db.insert('gatepass', {
        'gatepass_number': 'GP-001',
        'gatepass_type_id': 1,
        'status': 'PENDING',
        'requested_date': DateTime.now().millisecondsSinceEpoch,
      });

      await service.updateGatepassStatus(1, 'CANCELLED');

      final maps = await db.query('gatepass', where: 'id = ?', whereArgs: [1]);
      expect(maps.first['status'], 'CANCELLED');
    });
  });

  group('Barcode Definitions', () {
    test('createBarcodeDefinition inserts a barcode definition', () async {
      final def = BarcodeDefinition(
        code: 'INV',
        name: 'Inventory Barcode',
        symbology: 'CODE128',
        prefix: 'INV-',
        suffix: '',
        includeText: 1,
      );

      final id = await service.createBarcodeDefinition(def);

      expect(id, greaterThan(0));

      final maps = await db.query('barcode_definitions', where: 'id = ?', whereArgs: [id]);
      expect(maps.first['code'], 'INV');
      expect(maps.first['name'], 'Inventory Barcode');
    });

    test('getBarcodeDefinitions returns active definitions', () async {
      await db.insert('barcode_definitions', {
        'code': 'INV',
        'name': 'Inventory Barcode',
        'symbology': 'CODE128',
        'is_active': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      final defs = await service.getBarcodeDefinitions(activeOnly: true);

      expect(defs.length, 1);
      expect(defs.first.code, 'INV');
    });
  });

  group('Barcodes', () {
    test('createBarcode inserts a barcode', () async {
      final barcode = Barcode(
        barcodeValue: 'BARCODE123',
        barcodeTypeId: 1,
        entityType: 'inventory_item',
        entityId: 1,
      );

      final id = await service.createBarcode(barcode);

      expect(id, greaterThan(0));

      final maps = await db.query('barcodes', where: 'id = ?', whereArgs: [id]);
      expect(maps.first['barcode_value'], 'BARCODE123');
      expect(maps.first['status'], 'ACTIVE');
    });

    test('getBarcodeByValue returns barcode by value', () async {
      await db.insert('barcodes', {
        'barcode_value': 'BARCODE123',
        'barcode_type_id': 1,
        'entity_type': 'inventory_item',
        'entity_id': 1,
        'status': 'ACTIVE',
      });

      final barcode = await service.getBarcodeByValue('BARCODE123');

      expect(barcode, isNotNull);
      expect(barcode!.barcodeValue, 'BARCODE123');
    });

    test('getBarcodeByEntity returns barcode by entity', () async {
      await db.insert('barcodes', {
        'barcode_value': 'BARCODE123',
        'barcode_type_id': 1,
        'entity_type': 'inventory_item',
        'entity_id': 1,
        'status': 'ACTIVE',
      });

      final barcode = await service.getBarcodeByEntity('inventory_item', 1);

      expect(barcode, isNotNull);
      expect(barcode!.barcodeValue, 'BARCODE123');
    });
  });

  group('Barcode Scans', () {
    test('logBarcodeScan records a barcode scan', () async {
      final scan = BarcodeScan(
        barcodeValue: 'BARCODE123',
        entityType: 'inventory_item',
        entityId: 1,
        scanType: 'RECEIVING',
        locationId: 1,
        scannedBy: 1,
        deviceId: 'CAMERA-001',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      final id = await service.logBarcodeScan(scan);

      expect(id, greaterThan(0));

      final maps = await db.query('barcode_scans', where: 'id = ?', whereArgs: [id]);
      expect(maps.first['barcode_value'], 'BARCODE123');
      expect(maps.first['status'], 'SUCCESS');
    });

    test('getBarcodeScans returns scans filtered by criteria', () async {
      await db.insert('barcode_scans', {
        'barcode_value': 'BAR001',
        'scan_type': 'RECEIVING',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'status': 'SUCCESS',
      });
      await db.insert('barcode_scans', {
        'barcode_value': 'BAR002',
        'scan_type': 'DISPATCH',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'status': 'SUCCESS',
      });

      final receivingScans = await service.getBarcodeScans(scanType: 'RECEIVING');
      final dispatchScans = await service.getBarcodeScans(scanType: 'DISPATCH');

      expect(receivingScans.length, 1);
      expect(dispatchScans.length, 1);
    });
  });

  group('Batch Scan Sessions', () {
    test('createBatchScanSession creates a new session', () async {
      final session = BatchScanSession(
        sessionNumber: 'BATCH-001',
        sessionType: 'RECEIVING',
        totalExpected: 100,
        startedAt: DateTime.now().millisecondsSinceEpoch,
      );

      final id = await service.createBatchScanSession(session);

      expect(id, greaterThan(0));

      final maps = await db.query('batch_scan_sessions', where: 'id = ?', whereArgs: [id]);
      expect(maps.first['session_number'], 'BATCH-001');
      expect(maps.first['status'], 'IN_PROGRESS');
    });

    test('getBatchScanSession returns session by id', () async {
      await db.insert('batch_scan_sessions', {
        'session_number': 'BATCH-001',
        'session_type': 'RECEIVING',
        'status': 'IN_PROGRESS',
        'started_at': DateTime.now().millisecondsSinceEpoch,
      });

      final session = await service.getBatchScanSession(1);

      expect(session, isNotNull);
      expect(session!.sessionNumber, 'BATCH-001');
    });

    test('addBatchScanItem adds item to session', () async {
      final sessionId = await service.createBatchScanSession(
        BatchScanSession(
          sessionNumber: 'BATCH-001',
          sessionType: 'RECEIVING',
          startedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final item = BatchScanItem(
        sessionId: sessionId,
        barcodeValue: 'BARCODE001',
        expectedQuantity: 10,
      );

      final itemId = await service.addBatchScanItem(item);

      expect(itemId, greaterThan(0));

      final items = await db.query('batch_scan_items', where: 'session_id = ?', whereArgs: [sessionId]);
      expect(items.length, 1);
      expect(items.first['barcode_value'], 'BARCODE001');
    });

    test('updateBatchScanItem updates item status', () async {
      final sessionId = await service.createBatchScanSession(
        BatchScanSession(
          sessionNumber: 'BATCH-001',
          sessionType: 'RECEIVING',
          startedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final itemId = await db.insert('batch_scan_items', {
        'session_id': sessionId,
        'barcode_value': 'BARCODE001',
        'expected_quantity': 10,
        'status': 'PENDING',
      });

      final item = BatchScanItem(
        id: itemId,
        sessionId: sessionId,
        barcodeValue: 'BARCODE001',
        expectedQuantity: 10,
        scannedQuantity: 10,
        status: 'VERIFIED',
      );

      await service.updateBatchScanItem(item);

      final maps = await db.query('batch_scan_items', where: 'id = ?', whereArgs: [itemId]);
      expect(maps.first['status'], 'VERIFIED');
    });

    test('getBatchScanItems returns items for session', () async {
      final sessionId = await service.createBatchScanSession(
        BatchScanSession(
          sessionNumber: 'BATCH-001',
          sessionType: 'RECEIVING',
          startedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      await db.insert('batch_scan_items', {
        'session_id': sessionId,
        'barcode_value': 'BAR001',
        'expected_quantity': 10,
        'status': 'VERIFIED',
      });

      final items = await service.getBatchScanItems(sessionId);

      expect(items.length, 1);
    });

    test('updateBatchScanSession sets status to COMPLETED', () async {
      final sessionId = await service.createBatchScanSession(
        BatchScanSession(
          sessionNumber: 'BATCH-001',
          sessionType: 'RECEIVING',
          startedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      await service.updateBatchScanSession(
        BatchScanSession(
          id: sessionId,
          sessionNumber: 'BATCH-001',
          sessionType: 'RECEIVING',
          status: 'COMPLETED',
          completedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final maps = await db.query('batch_scan_sessions', where: 'id = ?', whereArgs: [sessionId]);
      expect(maps.first['status'], 'COMPLETED');
    });
  });

  group('Label Print Jobs', () {
    test('createLabelPrintJob creates a print job', () async {
      final defId = await db.insert('barcode_definitions', {
        'code': 'INV',
        'name': 'Inventory Label',
        'symbology': 'CODE128',
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      final job = LabelPrintJob(
        jobNumber: 'JOB-001',
        barcodeDefinitionId: defId,
        entityType: 'inventory_item',
        copies: 2,
      );

      final id = await service.createLabelPrintJob(job);

      expect(id, greaterThan(0));

      final maps = await db.query('label_print_jobs', where: 'id = ?', whereArgs: [id]);
      expect(maps.first['job_number'], 'JOB-001');
      expect(maps.first['copies'], 2);
      expect(maps.first['status'], 'QUEUED');
    });

    test('getLabelPrintJobs returns jobs filtered by status', () async {
      await db.insert('label_print_jobs', {
        'job_number': 'JOB-001',
        'barcode_definition_id': 1,
        'entity_type': 'inventory_item',
        'status': 'QUEUED',
        'requested_at': DateTime.now().millisecondsSinceEpoch,
      });
      await db.insert('label_print_jobs', {
        'job_number': 'JOB-002',
        'barcode_definition_id': 1,
        'entity_type': 'inventory_item',
        'status': 'COMPLETED',
        'requested_at': DateTime.now().millisecondsSinceEpoch,
      });

      final queued = await service.getLabelPrintJobs(status: 'QUEUED');
      final completed = await service.getLabelPrintJobs(status: 'COMPLETED');

      expect(queued.length, 1);
      expect(completed.length, 1);
    });

    test('updateLabelPrintJobStatus changes job status', () async {
      final jobId = await db.insert('label_print_jobs', {
        'job_number': 'JOB-001',
        'barcode_definition_id': 1,
        'entity_type': 'inventory_item',
        'status': 'QUEUED',
        'requested_at': DateTime.now().millisecondsSinceEpoch,
      });

      await service.updateLabelPrintJobStatus(jobId, 'PRINTING');

      final maps = await db.query('label_print_jobs', where: 'id = ?', whereArgs: [jobId]);
      expect(maps.first['status'], 'PRINTING');
      expect(maps.first['started_at'], greaterThan(0));
    });

    test('cancelLabelPrintJob sets job status to CANCELLED', () async {
      final jobId = await db.insert('label_print_jobs', {
        'job_number': 'JOB-001',
        'barcode_definition_id': 1,
        'entity_type': 'inventory_item',
        'status': 'QUEUED',
        'requested_at': DateTime.now().millisecondsSinceEpoch,
      });

      await service.updateLabelPrintJobStatus(jobId, 'CANCELLED');

      final maps = await db.query('label_print_jobs', where: 'id = ?', whereArgs: [jobId]);
      expect(maps.first['status'], 'CANCELLED');
    });
  });

  group('Printer Configs', () {
    test('getPrinterConfigs returns active printer configs', () async {
      await db.insert('printer_configs', {
        'name': 'Zebra ZP 450',
        'printer_type': 'ZPL',
        'ip_address': '192.168.1.100',
        'port': 9100,
        'is_active': 1,
        'is_default': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      final configs = await service.getPrinterConfigs(activeOnly: true);

      expect(configs.length, 1);
      expect(configs.first.name, 'Zebra ZP 450');
      expect(configs.first.printerType, 'ZPL');
    });

    test('createPrinterConfig inserts a printer config', () async {
      final config = PrinterConfig(
        name: 'New Printer',
        printerType: 'ZPL',
        ipAddress: '192.168.1.200',
        port: 9100,
      );

      final id = await service.createPrinterConfig(config);

      expect(id, greaterThan(0));

      final maps = await db.query('printer_configs', where: 'id = ?', whereArgs: [id]);
      expect(maps.first['name'], 'New Printer');
      expect(maps.first['printer_type'], 'ZPL');
    });

    test('getDefaultPrinter returns default printer', () async {
      await db.insert('printer_configs', {
        'name': 'Default Printer',
        'printer_type': 'ZPL',
        'is_active': 1,
        'is_default': 1,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      final printer = await service.getDefaultPrinter();

      expect(printer, isNotNull);
      expect(printer!.name, 'Default Printer');
    });
  });
}