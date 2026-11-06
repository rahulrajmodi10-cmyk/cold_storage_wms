// lib/db/migrations/migration_003_logistics.dart

import 'package:sqflite/sqflite.dart';

/// Migration 003: Logistics Schema
/// Creates carriers, vehicles, routes, route_stops, shipments, shipment_items,
/// shipment_tracking, load_plans, load_plan_items, freight_rates, freight_bills,
/// vehicle_maintenance tables
class Migration003Logistics {
  static const int version = 3;

  static Future<void> up(Database db) async {
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

  static Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS vehicle_maintenance');
    await db.execute('DROP TABLE IF EXISTS freight_bills');
    await db.execute('DROP TABLE IF EXISTS freight_rates');
    await db.execute('DROP TABLE IF EXISTS load_plan_items');
    await db.execute('DROP TABLE IF EXISTS load_plans');
    await db.execute('DROP TABLE IF EXISTS shipment_tracking');
    await db.execute('DROP TABLE IF EXISTS shipment_items');
    await db.execute('DROP TABLE IF EXISTS shipments');
    await db.execute('DROP TABLE IF EXISTS route_stops');
    await db.execute('DROP TABLE IF EXISTS routes');
    await db.execute('DROP TABLE IF EXISTS vehicles');
    await db.execute('DROP TABLE IF EXISTS carriers');
  }
}