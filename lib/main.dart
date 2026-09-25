// lib/main.dart

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'screens/inventory_dashboard.dart';
import 'screens/item_form.dart';
import 'screens/finance_dashboard.dart';
import 'screens/logistics_dashboard.dart';
import 'screens/camera_counting_screen.dart';
import 'screens/gatepass_screen.dart';
import 'screens/barcode_scanner_screen.dart';
import 'services/inventory_service.dart';
import 'services/location_service.dart';
import 'services/temperature_service.dart';
import 'services/receiving_service.dart';
import 'services/picking_service.dart';
import 'services/dispatch_service.dart';
import 'services/sla_service.dart';
import 'services/finance_service.dart';
import 'services/logistics_service.dart';
import 'services/camera_ai_service.dart';
import 'services/gatepass_barcode_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final db = await _initDatabase();
  runApp(ColdStorageWMS(db: db));
}

Future<Database> _initDatabase() async {
  final path = join(await getDatabasesPath(), 'wms.db');
  return await openDatabase(
    path,
    version: 6,
    onCreate: (db, version) async {
      // Run all migrations in order
      await _runMigration001(db);
      await _runMigration002(db);
      await _runMigration003(db);
      await _runMigration004(db);
      await _runMigration005(db);
      await _runMigration006(db);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await _runMigration002(db);
      }
      if (oldVersion < 3) {
        await _runMigration003(db);
      }
      if (oldVersion < 4) {
        await _runMigration004(db);
      }
      if (oldVersion < 5) {
        await _runMigration005(db);
      }
      if (oldVersion < 6) {
        await _runMigration006(db);
      }
    },
  );
}

// Migration 001: Inventory Schema
Future<void> _runMigration001(Database db) async {
  await db.execute('''
    CREATE TABLE users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      username TEXT UNIQUE,
      password_hash TEXT,
      role TEXT,
      face_embedding BLOB
    )
  ''');
  await db.execute('''
    CREATE TABLE gatepass (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      item_id INTEGER,
      quantity INTEGER,
      operator_id INTEGER,
      recipient TEXT,
      vehicle_number TEXT,
      destination TEXT,
      status TEXT,
      created_at INTEGER,
      completed_at INTEGER,
      completed_by INTEGER
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
  await db.execute('''
    CREATE TABLE face_embeddings (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER,
      embedding BLOB,
      created_at INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE settings (
      key TEXT PRIMARY KEY,
      value TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE otps (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      phone TEXT,
      code TEXT,
      expires_at INTEGER,
      verified INTEGER DEFAULT 0
    )
  ''');
  await db.execute('''
    CREATE TABLE alert (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT,
      severity TEXT,
      message TEXT,
      target_id INTEGER,
      acknowledged INTEGER DEFAULT 0,
      created_at INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE inventory_item (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      sku TEXT UNIQUE,
      name TEXT,
      category TEXT,
      quantity INTEGER DEFAULT 0,
      unit TEXT,
      location_id INTEGER,
      expiry_date INTEGER,
      min_temp REAL,
      max_temp REAL,
      current_temp REAL,
      humidity REAL,
      status TEXT,
      created_at INTEGER,
      updated_at INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE storage_location (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      rack_id TEXT,
      shelf_id TEXT,
      bin_id TEXT,
      zone TEXT,
      capacity REAL,
      current_utilization REAL
    )
  ''');
  await db.execute('''
    CREATE TABLE temperature_log (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      item_id INTEGER,
      location_id INTEGER,
      temperature REAL,
      humidity REAL,
      timestamp INTEGER,
      sensor_id TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE transfer_record (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      item_id INTEGER,
      from_location INTEGER,
      to_location INTEGER,
      quantity INTEGER,
      operator_id INTEGER,
      timestamp INTEGER,
      reason TEXT
    )
  ''');
}

// Migration 002: Finance Schema
Future<void> _runMigration002(Database db) async {
  await db.execute('''
    CREATE TABLE chart_of_accounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT UNIQUE NOT NULL,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      parent_id INTEGER,
      is_active INTEGER DEFAULT 1,
      gst_applicable INTEGER DEFAULT 0,
      gst_rate REAL DEFAULT 0,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (parent_id) REFERENCES chart_of_accounts(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE parties (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      gstin TEXT,
      pan TEXT,
      address TEXT,
      city TEXT,
      state TEXT,
      pincode TEXT,
      phone TEXT,
      email TEXT,
      contact_person TEXT,
      credit_limit REAL DEFAULT 0,
      payment_terms INTEGER DEFAULT 30,
      opening_balance REAL DEFAULT 0,
      is_active INTEGER DEFAULT 1,
      created_at INTEGER,
      updated_at INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE tax_rates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      rate REAL NOT NULL,
      effective_from INTEGER,
      effective_to INTEGER,
      is_active INTEGER DEFAULT 1
    )
  ''');
  await db.execute('''
    CREATE TABLE invoices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_number TEXT UNIQUE NOT NULL,
      invoice_date INTEGER NOT NULL,
      due_date INTEGER,
      party_id INTEGER NOT NULL,
      type TEXT NOT NULL,
      status TEXT DEFAULT 'DRAFT',
      subtotal REAL DEFAULT 0,
      tax_amount REAL DEFAULT 0,
      discount_amount REAL DEFAULT 0,
      total_amount REAL DEFAULT 0,
      paid_amount REAL DEFAULT 0,
      balance_amount REAL DEFAULT 0,
      narration TEXT,
      reference_type TEXT,
      reference_id INTEGER,
      created_by INTEGER,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (party_id) REFERENCES parties(id),
      FOREIGN KEY (created_by) REFERENCES users(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE invoice_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER NOT NULL,
      item_id INTEGER,
      description TEXT,
      hsn_code TEXT,
      quantity REAL NOT NULL,
      unit TEXT,
      rate REAL NOT NULL,
      discount_percent REAL DEFAULT 0,
      discount_amount REAL DEFAULT 0,
      taxable_amount REAL NOT NULL,
      gst_rate REAL DEFAULT 0,
      cgst_amount REAL DEFAULT 0,
      sgst_amount REAL DEFAULT 0,
      igst_amount REAL DEFAULT 0,
      total_amount REAL NOT NULL,
      FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE,
      FOREIGN KEY (item_id) REFERENCES inventory_item(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE payments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      payment_number TEXT UNIQUE NOT NULL,
      payment_date INTEGER NOT NULL,
      party_id INTEGER NOT NULL,
      type TEXT NOT NULL,
      mode TEXT NOT NULL,
      bank_account_id INTEGER,
      cheque_number TEXT,
      cheque_date INTEGER,
      amount REAL NOT NULL,
      narration TEXT,
      reference_type TEXT,
      reference_id INTEGER,
      status TEXT DEFAULT 'POSTED',
      created_by INTEGER,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (party_id) REFERENCES parties(id),
      FOREIGN KEY (created_by) REFERENCES users(id),
      FOREIGN KEY (bank_account_id) REFERENCES chart_of_accounts(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE payment_allocations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      payment_id INTEGER NOT NULL,
      invoice_id INTEGER NOT NULL,
      allocated_amount REAL NOT NULL,
      created_at INTEGER,
      FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE,
      FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
    )
  ''');
  await db.execute('''
    CREATE TABLE accounts_receivable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER NOT NULL,
      party_id INTEGER NOT NULL,
      invoice_number TEXT,
      invoice_date INTEGER,
      due_date INTEGER,
      total_amount REAL,
      paid_amount REAL DEFAULT 0,
      outstanding_amount REAL,
      status TEXT DEFAULT 'OPEN',
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (invoice_id) REFERENCES invoices(id),
      FOREIGN KEY (party_id) REFERENCES parties(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE accounts_payable (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER NOT NULL,
      party_id INTEGER NOT NULL,
      invoice_number TEXT,
      invoice_date INTEGER,
      due_date INTEGER,
      total_amount REAL,
      paid_amount REAL DEFAULT 0,
      outstanding_amount REAL,
      status TEXT DEFAULT 'OPEN',
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (invoice_id) REFERENCES invoices(id),
      FOREIGN KEY (party_id) REFERENCES parties(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE journal_entries (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      entry_number TEXT UNIQUE NOT NULL,
      entry_date INTEGER NOT NULL,
      narration TEXT,
      reference_type TEXT,
      reference_id INTEGER,
      status TEXT DEFAULT 'DRAFT',
      posted_at INTEGER,
      posted_by INTEGER,
      created_by INTEGER,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (created_by) REFERENCES users(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE journal_entry_lines (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      entry_id INTEGER NOT NULL,
      account_id INTEGER NOT NULL,
      debit REAL DEFAULT 0,
      credit REAL DEFAULT 0,
      narration TEXT,
      FOREIGN KEY (entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE,
      FOREIGN KEY (account_id) REFERENCES chart_of_accounts(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE financial_periods (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      start_date INTEGER NOT NULL,
      end_date INTEGER NOT NULL,
      is_closed INTEGER DEFAULT 0,
      closed_at INTEGER,
      closed_by INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE bank_accounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      account_name TEXT NOT NULL,
      bank_name TEXT,
      account_number TEXT,
      ifsc_code TEXT,
      branch TEXT,
      account_type TEXT,
      opening_balance REAL DEFAULT 0,
      current_balance REAL DEFAULT 0,
      is_active INTEGER DEFAULT 1,
      created_at INTEGER,
      updated_at INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE gst_returns (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      return_type TEXT NOT NULL,
      period TEXT NOT NULL,
      status TEXT DEFAULT 'DRAFT',
      total_taxable_value REAL DEFAULT 0,
      total_cgst REAL DEFAULT 0,
      total_sgst REAL DEFAULT 0,
      total_igst REAL DEFAULT 0,
      total_cess REAL DEFAULT 0,
      filed_date INTEGER,
      acknowledgement_no TEXT,
      json_data TEXT,
      created_at INTEGER,
      updated_at INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE purchase_orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      po_number TEXT UNIQUE NOT NULL,
      po_date INTEGER NOT NULL,
      vendor_id INTEGER NOT NULL,
      expected_date INTEGER,
      status TEXT DEFAULT 'DRAFT',
      subtotal REAL DEFAULT 0,
      tax_amount REAL DEFAULT 0,
      total_amount REAL DEFAULT 0,
      narration TEXT,
      created_by INTEGER,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (vendor_id) REFERENCES parties(id),
      FOREIGN KEY (created_by) REFERENCES users(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE purchase_order_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      po_id INTEGER NOT NULL,
      item_id INTEGER,
      description TEXT,
      quantity REAL NOT NULL,
      unit TEXT,
      rate REAL NOT NULL,
      discount_percent REAL DEFAULT 0,
      tax_rate REAL DEFAULT 0,
      total_amount REAL NOT NULL,
      received_quantity REAL DEFAULT 0,
      FOREIGN KEY (po_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
      FOREIGN KEY (item_id) REFERENCES inventory_item(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE sales_orders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      so_number TEXT UNIQUE NOT NULL,
      so_date INTEGER NOT NULL,
      customer_id INTEGER NOT NULL,
      expected_date INTEGER,
      status TEXT DEFAULT 'DRAFT',
      subtotal REAL DEFAULT 0,
      tax_amount REAL DEFAULT 0,
      total_amount REAL DEFAULT 0,
      narration TEXT,
      created_by INTEGER,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (customer_id) REFERENCES parties(id),
      FOREIGN KEY (created_by) REFERENCES users(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE sales_order_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      so_id INTEGER NOT NULL,
      item_id INTEGER,
      description TEXT,
      quantity REAL NOT NULL,
      unit TEXT,
      rate REAL NOT NULL,
      discount_percent REAL DEFAULT 0,
      tax_rate REAL DEFAULT 0,
      total_amount REAL NOT NULL,
      delivered_quantity REAL DEFAULT 0,
      FOREIGN KEY (so_id) REFERENCES sales_orders(id) ON DELETE CASCADE,
      FOREIGN KEY (item_id) REFERENCES inventory_item(id)
    )
  ''');
}

// Migration 003: Logistics Schema
Future<void> _runMigration003(Database db) async {
  await db.execute('''
    CREATE TABLE carriers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      code TEXT UNIQUE,
      contact_person TEXT,
      phone TEXT,
      email TEXT,
      address TEXT,
      gstin TEXT,
      pan TEXT,
      license_number TEXT,
      rating REAL DEFAULT 0,
      is_active INTEGER DEFAULT 1,
      created_at INTEGER,
      updated_at INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE vehicles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      carrier_id INTEGER,
      registration_number TEXT UNIQUE NOT NULL,
      vehicle_type TEXT,
      capacity_weight REAL,
      capacity_volume REAL,
      capacity_pallets INTEGER,
      temperature_controlled INTEGER DEFAULT 0,
      min_temp REAL,
      max_temp REAL,
      gps_device_id TEXT,
      insurance_expiry INTEGER,
      fitness_expiry INTEGER,
      permit_expiry INTEGER,
      driver_name TEXT,
      driver_phone TEXT,
      driver_license TEXT,
      status TEXT DEFAULT 'AVAILABLE',
      is_active INTEGER DEFAULT 1,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (carrier_id) REFERENCES carriers(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE routes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      code TEXT UNIQUE NOT NULL,
      name TEXT NOT NULL,
      origin TEXT NOT NULL,
      destination TEXT NOT NULL,
      distance_km REAL,
      estimated_duration_minutes INTEGER,
      toll_charges REAL DEFAULT 0,
      route_description TEXT,
      is_active INTEGER DEFAULT 1,
      created_at INTEGER,
      updated_at INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE route_stops (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      route_id INTEGER NOT NULL,
      stop_order INTEGER NOT NULL,
      location_name TEXT NOT NULL,
      address TEXT,
      latitude REAL,
      longitude REAL,
      estimated_arrival INTEGER,
      estimated_departure INTEGER,
      stop_type TEXT,
      FOREIGN KEY (route_id) REFERENCES routes(id) ON DELETE CASCADE
    )
  ''');
  await db.execute('''
    CREATE TABLE shipments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      shipment_number TEXT UNIQUE NOT NULL,
      shipment_date INTEGER NOT NULL,
      reference_type TEXT,
      reference_id INTEGER,
      carrier_id INTEGER,
      vehicle_id INTEGER,
      route_id INTEGER,
      driver_name TEXT,
      driver_phone TEXT,
      origin_address TEXT,
      destination_address TEXT,
      origin_lat REAL,
      origin_lng REAL,
      dest_lat REAL,
      dest_lng REAL,
      status TEXT DEFAULT 'PLANNED',
      total_weight REAL DEFAULT 0,
      total_volume REAL DEFAULT 0,
      total_packages INTEGER DEFAULT 0,
      freight_charges REAL DEFAULT 0,
      additional_charges REAL DEFAULT 0,
      total_freight REAL DEFAULT 0,
      loading_start_time INTEGER,
      loading_end_time INTEGER,
      departure_time INTEGER,
      arrival_time INTEGER,
      unloading_start_time INTEGER,
      unloading_end_time INTEGER,
      proof_of_delivery TEXT,
      pod_timestamp INTEGER,
      pod_received_by TEXT,
      narration TEXT,
      created_by INTEGER,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (carrier_id) REFERENCES carriers(id),
      FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
      FOREIGN KEY (route_id) REFERENCES routes(id),
      FOREIGN KEY (created_by) REFERENCES users(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE shipment_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      shipment_id INTEGER NOT NULL,
      item_id INTEGER,
      description TEXT,
      quantity REAL NOT NULL,
      unit TEXT,
      weight REAL,
      volume REAL,
      packages INTEGER DEFAULT 1,
      temperature_required INTEGER DEFAULT 0,
      min_temp REAL,
      max_temp REAL,
      loaded_quantity REAL DEFAULT 0,
      delivered_quantity REAL DEFAULT 0,
      FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE,
      FOREIGN KEY (item_id) REFERENCES inventory_item(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE shipment_tracking (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      shipment_id INTEGER NOT NULL,
      latitude REAL,
      longitude REAL,
      address TEXT,
      speed REAL,
      heading REAL,
      status TEXT,
      temperature REAL,
      humidity REAL,
      battery_level REAL,
      signal_strength REAL,
      timestamp INTEGER,
      source TEXT,
      FOREIGN KEY (shipment_id) REFERENCES shipments(id) ON DELETE CASCADE
    )
  ''');
  await db.execute('''
    CREATE TABLE load_plans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      shipment_id INTEGER NOT NULL,
      vehicle_id INTEGER NOT NULL,
      plan_date INTEGER NOT NULL,
      total_weight REAL DEFAULT 0,
      total_volume REAL DEFAULT 0,
      total_packages INTEGER DEFAULT 0,
      weight_utilization REAL DEFAULT 0,
      volume_utilization REAL DEFAULT 0,
      pallet_count INTEGER DEFAULT 0,
      loading_sequence TEXT,
      status TEXT DEFAULT 'DRAFT',
      approved_by INTEGER,
      approved_at INTEGER,
      created_by INTEGER,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (shipment_id) REFERENCES shipments(id),
      FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
      FOREIGN KEY (approved_by) REFERENCES users(id),
      FOREIGN KEY (created_by) REFERENCES users(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE load_plan_items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      load_plan_id INTEGER NOT NULL,
      shipment_item_id INTEGER NOT NULL,
      load_order INTEGER,
      position_x REAL,
      position_y REAL,
      position_z REAL,
      stackable INTEGER DEFAULT 1,
      fragile INTEGER DEFAULT 0,
      temperature_zone TEXT,
      FOREIGN KEY (load_plan_id) REFERENCES load_plans(id) ON DELETE CASCADE,
      FOREIGN KEY (shipment_item_id) REFERENCES shipment_items(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE freight_rates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      carrier_id INTEGER,
      route_id INTEGER,
      vehicle_type TEXT,
      rate_type TEXT,
      base_rate REAL NOT NULL,
      min_charge REAL DEFAULT 0,
      fuel_surcharge_percent REAL DEFAULT 0,
      toll_included INTEGER DEFAULT 0,
      gst_rate REAL DEFAULT 0,
      effective_from INTEGER,
      effective_to INTEGER,
      is_active INTEGER DEFAULT 1,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (carrier_id) REFERENCES carriers(id),
      FOREIGN KEY (route_id) REFERENCES routes(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE freight_bills (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      bill_number TEXT UNIQUE NOT NULL,
      bill_date INTEGER NOT NULL,
      carrier_id INTEGER NOT NULL,
      shipment_id INTEGER,
      route_id INTEGER,
      vehicle_id INTEGER,
      distance_km REAL,
      weight_charged REAL,
      rate_applied REAL,
      base_freight REAL DEFAULT 0,
      fuel_surcharge REAL DEFAULT 0,
      toll_charges REAL DEFAULT 0,
      other_charges REAL DEFAULT 0,
      cgst_amount REAL DEFAULT 0,
      sgst_amount REAL DEFAULT 0,
      igst_amount REAL DEFAULT 0,
      total_amount REAL NOT NULL,
      status TEXT DEFAULT 'DRAFT',
      verified_by INTEGER,
      verified_at INTEGER,
      paid_date INTEGER,
      narration TEXT,
      created_by INTEGER,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (carrier_id) REFERENCES carriers(id),
      FOREIGN KEY (shipment_id) REFERENCES shipments(id),
      FOREIGN KEY (route_id) REFERENCES routes(id),
      FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
      FOREIGN KEY (verified_by) REFERENCES users(id),
      FOREIGN KEY (created_by) REFERENCES users(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE vehicle_maintenance (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      vehicle_id INTEGER NOT NULL,
      maintenance_type TEXT,
      description TEXT,
      cost REAL DEFAULT 0,
      service_date INTEGER,
      next_due_date INTEGER,
      odometer_reading INTEGER,
      service_provider TEXT,
      status TEXT DEFAULT 'SCHEDULED',
      created_by INTEGER,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (vehicle_id) REFERENCES vehicles(id),
      FOREIGN KEY (created_by) REFERENCES users(id)
    )
  ''');
}

// Migration 004: Camera AI Schema
Future<void> _runMigration004(Database db) async {
  await db.execute('''
    CREATE TABLE camera_devices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      code TEXT UNIQUE NOT NULL,
      device_type TEXT,
      location_id INTEGER,
      ip_address TEXT,
      port INTEGER,
      username TEXT,
      password_hash TEXT,
      rtsp_url TEXT,
      resolution_width INTEGER DEFAULT 1920,
      resolution_height INTEGER DEFAULT 1080,
      fps INTEGER DEFAULT 30,
      model_path TEXT,
      model_version TEXT,
      confidence_threshold REAL DEFAULT 0.5,
      iou_threshold REAL DEFAULT 0.45,
      detection_classes TEXT,
      count_direction TEXT,
      roi_coordinates TEXT,
      calibration_factor REAL DEFAULT 1.0,
      is_active INTEGER DEFAULT 1,
      last_heartbeat INTEGER,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (location_id) REFERENCES storage_location(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE counting_sessions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_number TEXT UNIQUE NOT NULL,
      camera_id INTEGER NOT NULL,
      reference_type TEXT,
      reference_id INTEGER,
      session_type TEXT NOT NULL,
      status TEXT DEFAULT 'IN_PROGRESS',
      expected_count INTEGER,
      ai_count INTEGER DEFAULT 0,
      manual_count INTEGER,
      verified_count INTEGER,
      discrepancy INTEGER DEFAULT 0,
      discrepancy_percent REAL DEFAULT 0,
      start_time INTEGER,
      end_time INTEGER,
      duration_seconds INTEGER,
      operator_id INTEGER,
      verified_by INTEGER,
      verified_at INTEGER,
      notes TEXT,
      created_at INTEGER,
      updated_at INTEGER,
      FOREIGN KEY (camera_id) REFERENCES camera_devices(id),
      FOREIGN KEY (operator_id) REFERENCES users(id),
      FOREIGN KEY (verified_by) REFERENCES users(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE detection_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id INTEGER NOT NULL,
      frame_timestamp INTEGER NOT NULL,
      track_id INTEGER,
      class_name TEXT,
      confidence REAL,
      bbox_x REAL,
      bbox_y REAL,
      bbox_width REAL,
      bbox_height REAL,
      centroid_x REAL,
      centroid_y REAL,
      direction TEXT,
      counted INTEGER DEFAULT 0,
      count_timestamp INTEGER,
      image_path TEXT,
      created_at INTEGER,
      FOREIGN KEY (session_id) REFERENCES counting_sessions(id) ON DELETE CASCADE
    )
  ''');
  await db.execute('''
    CREATE TABLE count_verifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      session_id INTEGER NOT NULL,
      verification_type TEXT,
      verifier_id INTEGER NOT NULL,
      original_count INTEGER,
      verified_count INTEGER,
      variance INTEGER,
      variance_percent REAL,
      status TEXT DEFAULT 'PENDING',
      verification_notes TEXT,
      evidence_images TEXT,
      started_at INTEGER,
      completed_at INTEGER,
      created_at INTEGER,
      FOREIGN KEY (session_id) REFERENCES counting_sessions(id) ON DELETE CASCADE,
      FOREIGN KEY (verifier_id) REFERENCES users(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE camera_calibrations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      camera_id INTEGER NOT NULL,
      calibration_type TEXT,
      reference_object TEXT,
      reference_size REAL,
      pixel_measurement REAL,
      calibration_factor REAL,
      accuracy_percent REAL,
      calibrated_by INTEGER,
      calibrated_at INTEGER,
      is_active INTEGER DEFAULT 1,
      notes TEXT,
      FOREIGN KEY (camera_id) REFERENCES camera_devices(id),
      FOREIGN KEY (calibrated_by) REFERENCES users(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE ml_models (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      version TEXT NOT NULL,
      model_type TEXT,
      framework TEXT,
      input_width INTEGER,
      input_height INTEGER,
      input_channels INTEGER DEFAULT 3,
      classes TEXT,
      model_file_path TEXT,
      label_file_path TEXT,
      metrics_json TEXT,
      training_data_info TEXT,
      is_active INTEGER DEFAULT 1,
      deployed_at INTEGER,
      created_at INTEGER,
      updated_at INTEGER
    )
  ''');
  await db.execute('''
    CREATE TABLE camera_alerts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      camera_id INTEGER NOT NULL,
      alert_type TEXT,
      severity TEXT,
      message TEXT,
      session_id INTEGER,
      detection_event_id INTEGER,
      acknowledged INTEGER DEFAULT 0,
      acknowledged_by INTEGER,
      acknowledged_at INTEGER,
      resolved INTEGER DEFAULT 0,
      resolved_by INTEGER,
      resolved_at INTEGER,
      created_at INTEGER,
      FOREIGN KEY (camera_id) REFERENCES camera_devices(id),
      FOREIGN KEY (session_id) REFERENCES counting_sessions(id),
      FOREIGN KEY (detection_event_id) REFERENCES detection_events(id),
      FOREIGN KEY (acknowledged_by) REFERENCES users(id),
      FOREIGN KEY (resolved_by) REFERENCES users(id)
    )
  ''');
}

// Migration 005: Gatepass & Barcode Schema
Future<void> _runMigration005(Database db) async {
  await db.execute('''
    CREATE TABLE gatepass_types (
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
    CREATE TABLE gatepass (
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
    CREATE TABLE gatepass_items (
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
    CREATE TABLE security_gates (
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
    CREATE TABLE gatepass_vehicle_log (
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
    CREATE TABLE gatepass_approvals (
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
    CREATE TABLE dispatch_schedules (
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
    CREATE TABLE loading_bays (
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
    CREATE TABLE barcode_definitions (
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
    CREATE TABLE barcodes (
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
      FOREIGN KEY (barcode_id) REFERENCES barcodes(id),
      FOREIGN KEY (location_id) REFERENCES storage_location(id),
      FOREIGN KEY (scanned_by) REFERENCES users(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE batch_scan_sessions (
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
      FOREIGN KEY (session_id) REFERENCES batch_scan_sessions(id) ON DELETE CASCADE,
      FOREIGN KEY (barcode_id) REFERENCES barcodes(id),
      FOREIGN KEY (item_id) REFERENCES inventory_item(id),
      FOREIGN KEY (verified_by) REFERENCES users(id)
    )
  ''');
  await db.execute('''
    CREATE TABLE label_print_jobs (
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
    CREATE TABLE printer_configs (
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

// Migration 006: Additional Tables
Future<void> _runMigration006(Database db) async {
  // Additional tables if needed
}

class ColdStorageWMS extends StatelessWidget {
  final Database db;

  const ColdStorageWMS({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final inventoryService = InventoryService(db);
    final locationService = LocationService(db);
    final temperatureService = TemperatureService(db);
    final receivingService = ReceivingService(db);
    final pickingService = PickingService(db);
    final dispatchService = DispatchService(db);
    final slaService = SLAService(db);
    final financeService = FinanceService(db);
    final logisticsService = LogisticsService(db);
    final cameraService = CameraAIService(db);
    final gatepassService = GatepassBarcodeService(db);

    return MaterialApp(
      title: 'Cold Storage WMS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: MainNavigationScreen(
        inventoryService: inventoryService,
        locationService: locationService,
        temperatureService: temperatureService,
        receivingService: receivingService,
        pickingService: pickingService,
        dispatchService: dispatchService,
        slaService: slaService,
        financeService: financeService,
        logisticsService: logisticsService,
        cameraService: cameraService,
        gatepassService: gatepassService,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final InventoryService inventoryService;
  final LocationService locationService;
  final TemperatureService temperatureService;
  final ReceivingService receivingService;
  final PickingService pickingService;
  final DispatchService dispatchService;
  final SLAService slaService;
  final FinanceService financeService;
  final LogisticsService logisticsService;
  final CameraAIService cameraService;
  final GatepassBarcodeService gatepassService;

  const MainNavigationScreen({
    super.key,
    required this.inventoryService,
    required this.locationService,
    required this.temperatureService,
    required this.receivingService,
    required this.pickingService,
    required this.dispatchService,
    required this.slaService,
    required this.financeService,
    required this.logisticsService,
    required this.cameraService,
    required this.gatepassService,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      InventoryDashboard(
        inventoryService: widget.inventoryService,
        locationService: widget.locationService,
      ),
      FinanceDashboard(financeService: widget.financeService),
      LogisticsDashboard(logisticsService: widget.logisticsService),
      CameraCountingScreen(
        cameraService: widget.cameraService,
        gatepassService: widget.gatepassService,
      ),
      GatepassScreen(
        gatepassService: widget.gatepassService,
        inventoryService: widget.inventoryService,
      ),
      BarcodeScannerScreen(barcodeService: widget.gatepassService),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inventory_2), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.account_balance), label: 'Finance'),
          NavigationDestination(icon: Icon(Icons.local_shipping), label: 'Logistics'),
          NavigationDestination(icon: Icon(Icons.videocam), label: 'AI Camera'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Gatepass'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Barcode'),
        ],
      ),
    );
  }
}