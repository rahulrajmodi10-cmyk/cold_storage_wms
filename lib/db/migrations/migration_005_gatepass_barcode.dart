// lib/db/migrations/migration_005_gatepass_barcode.dart

import 'package:sqflite/sqflite.dart';

/// Migration 005: Gatepass & Barcode Schema
/// Creates gatepass_types, gatepass, gatepass_items, security_gates,
/// gatepass_vehicle_log, gatepass_approvals, dispatch_schedules, loading_bays,
/// barcode_definitions, barcodes, barcode_scans, batch_scan_sessions,
/// batch_scan_items, label_print_jobs, printer_configs tables
class Migration005GatepassBarcode {
  static const int version = 5;

  static Future<void> up(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS gatepass_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE NOT NULL,
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
      CREATE TABLE IF NOT EXISTS gatepass (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gatepass_number TEXT UNIQUE NOT NULL,
        gatepass_type_id INTEGER NOT NULL,
        reference_type TEXT,
        reference_id INTEGER,
        party_id INTEGER,
        status TEXT DEFAULT 'DRAFT',
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
        updated_at INTEGER,
        FOREIGN KEY (gatepass_type_id) REFERENCES gatepass_types(id),
        FOREIGN KEY (party_id) REFERENCES parties(id),
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
        FOREIGN KEY (security_officer_id) REFERENCES users(id),
        FOREIGN KEY (verified_by) REFERENCES users(id),
        FOREIGN KEY (approved_by) REFERENCES users(id),
        FOREIGN KEY (completed_by) REFERENCES users(id),
        FOREIGN KEY (created_by) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS gatepass_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gatepass_id INTEGER NOT NULL,
        item_id INTEGER,
        description TEXT,
        hsn_code TEXT,
        quantity REAL NOT NULL,
        unit TEXT,
        weight_per_unit REAL,
        total_weight REAL,
        packages INTEGER DEFAULT 1,
        package_type TEXT,
        temperature_required INTEGER DEFAULT 0,
        min_temp REAL,
        max_temp REAL,
        batch_number TEXT,
        expiry_date INTEGER,
        verified_quantity REAL DEFAULT 0,
        verified_weight REAL DEFAULT 0,
        verified_packages INTEGER DEFAULT 0,
        verification_status TEXT DEFAULT 'PENDING',
        verification_notes TEXT,
        FOREIGN KEY (gatepass_id) REFERENCES gatepass(id) ON DELETE CASCADE,
        FOREIGN KEY (item_id) REFERENCES inventory_item(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS security_gates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        gate_type TEXT,
        location_description TEXT,
        latitude REAL,
        longitude REAL,
        camera_id INTEGER,
        barrier_type TEXT,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (camera_id) REFERENCES camera_devices(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS gatepass_vehicle_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gatepass_id INTEGER NOT NULL,
        gate_id INTEGER NOT NULL,
        log_type TEXT NOT NULL,
        vehicle_number TEXT,
        driver_name TEXT,
        driver_verified INTEGER DEFAULT 0,
        seal_number TEXT,
        seal_verified INTEGER DEFAULT 0,
        seal_intact INTEGER DEFAULT 1,
        photos TEXT,
        officer_id INTEGER,
        timestamp INTEGER,
        notes TEXT,
        FOREIGN KEY (gatepass_id) REFERENCES gatepass(id) ON DELETE CASCADE,
        FOREIGN KEY (gate_id) REFERENCES security_gates(id),
        FOREIGN KEY (officer_id) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS gatepass_approvals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gatepass_id INTEGER NOT NULL,
        level INTEGER NOT NULL,
        approver_role TEXT,
        approver_id INTEGER,
        status TEXT DEFAULT 'PENDING',
        action_at INTEGER,
        comments TEXT,
        delegated_to INTEGER,
        FOREIGN KEY (gatepass_id) REFERENCES gatepass(id) ON DELETE CASCADE,
        FOREIGN KEY (approver_id) REFERENCES users(id),
        FOREIGN KEY (delegated_to) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dispatch_schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        schedule_number TEXT UNIQUE NOT NULL,
        schedule_date INTEGER NOT NULL,
        shift TEXT,
        gatepass_id INTEGER,
        shipment_id INTEGER,
        vehicle_id INTEGER,
        driver_id INTEGER,
        loading_bay_id INTEGER,
        scheduled_start INTEGER,
        scheduled_end INTEGER,
        actual_start INTEGER,
        actual_end INTEGER,
        status TEXT DEFAULT 'SCHEDULED',
        priority INTEGER DEFAULT 0,
        assigned_by INTEGER,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (gatepass_id) REFERENCES gatepass(id),
        FOREIGN KEY (shipment_id) REFERENCES shipments(id),
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
        FOREIGN KEY (driver_id) REFERENCES users(id),
        FOREIGN KEY (loading_bay_id) REFERENCES loading_bays(id),
        FOREIGN KEY (assigned_by) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS loading_bays (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        bay_type TEXT,
        dock_level INTEGER DEFAULT 0,
        max_vehicle_length REAL,
        max_vehicle_weight REAL,
        temperature_controlled INTEGER DEFAULT 0,
        min_temp REAL,
        max_temp REAL,
        camera_id INTEGER,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (camera_id) REFERENCES camera_devices(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS barcode_definitions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT UNIQUE NOT NULL,
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
      CREATE TABLE IF NOT EXISTS barcodes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode_value TEXT UNIQUE NOT NULL,
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
        updated_at INTEGER,
        FOREIGN KEY (barcode_type_id) REFERENCES barcode_definitions(id),
        FOREIGN KEY (printed_by) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS barcode_scans (
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
        FOREIGN KEY (barcode_id) REFERENCES barcodes(id),
        FOREIGN KEY (location_id) REFERENCES storage_location(id),
        FOREIGN KEY (scanned_by) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS batch_scan_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_number TEXT UNIQUE NOT NULL,
        session_type TEXT,
        reference_type TEXT,
        reference_id INTEGER,
        location_id INTEGER,
        operator_id INTEGER,
        status TEXT DEFAULT 'IN_PROGRESS',
        total_expected INTEGER,
        total_scanned INTEGER DEFAULT 0,
        total_matched INTEGER DEFAULT 0,
        total_mismatched INTEGER DEFAULT 0,
        started_at INTEGER,
        completed_at INTEGER,
        notes TEXT,
        created_at INTEGER,
        updated_at INTEGER,
        FOREIGN KEY (location_id) REFERENCES storage_location(id),
        FOREIGN KEY (operator_id) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS batch_scan_items (
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
        FOREIGN KEY (session_id) REFERENCES batch_scan_sessions(id) ON DELETE CASCADE,
        FOREIGN KEY (barcode_id) REFERENCES barcodes(id),
        FOREIGN KEY (item_id) REFERENCES inventory_item(id),
        FOREIGN KEY (verified_by) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS label_print_jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_number TEXT UNIQUE NOT NULL,
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
        FOREIGN KEY (barcode_definition_id) REFERENCES barcode_definitions(id),
        FOREIGN KEY (requested_by) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS printer_configs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
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
  }

  static Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS printer_configs');
    await db.execute('DROP TABLE IF EXISTS label_print_jobs');
    await db.execute('DROP TABLE IF EXISTS batch_scan_items');
    await db.execute('DROP TABLE IF EXISTS batch_scan_sessions');
    await db.execute('DROP TABLE IF EXISTS barcode_scans');
    await db.execute('DROP TABLE IF EXISTS barcodes');
    await db.execute('DROP TABLE IF EXISTS barcode_definitions');
    await db.execute('DROP TABLE IF EXISTS loading_bays');
    await db.execute('DROP TABLE IF EXISTS dispatch_schedules');
    await db.execute('DROP TABLE IF EXISTS gatepass_approvals');
    await db.execute('DROP TABLE IF EXISTS gatepass_vehicle_log');
    await db.execute('DROP TABLE IF EXISTS security_gates');
    await db.execute('DROP TABLE IF EXISTS gatepass_items');
    await db.execute('DROP TABLE IF EXISTS gatepass');
    await db.execute('DROP TABLE IF EXISTS gatepass_types');
  }
}