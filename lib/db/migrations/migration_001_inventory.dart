// lib/db/migrations/migration_001_inventory.dart

import 'package:sqflite/sqflite.dart';

/// Migration 001: Core Inventory Schema
/// Creates users, gatepass, audit_log, face_embeddings, settings, otps, alert,
/// inventory_item, storage_location, temperature_log, transfer_record tables
class Migration001Inventory {
  static const int version = 1;

  static Future<void> up(Database db) async {
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

  static Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS transfer_record');
    await db.execute('DROP TABLE IF EXISTS temperature_log');
    await db.execute('DROP TABLE IF EXISTS storage_location');
    await db.execute('DROP TABLE IF EXISTS inventory_item');
    await db.execute('DROP TABLE IF EXISTS alert');
    await db.execute('DROP TABLE IF EXISTS otps');
    await db.execute('DROP TABLE IF EXISTS settings');
    await db.execute('DROP TABLE IF EXISTS face_embeddings');
    await db.execute('DROP TABLE IF EXISTS audit_log');
    await db.execute('DROP TABLE IF EXISTS gatepass');
    await db.execute('DROP TABLE IF EXISTS users');
  }
}