// lib/db/migrations/migration_004_camera_ai.dart

import 'package:sqflite/sqflite.dart';

/// Migration 004: Camera AI Schema
/// Creates camera_devices, counting_sessions, detection_events, count_verifications,
/// camera_calibrations, ml_models, camera_alerts tables
class Migration004CameraAI {
  static const int version = 4;

  static Future<void> up(Database db) async {
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

  static Future<void> down(Database db) async {
    await db.execute('DROP TABLE IF EXISTS camera_alerts');
    await db.execute('DROP TABLE IF EXISTS ml_models');
    await db.execute('DROP TABLE IF EXISTS camera_calibrations');
    await db.execute('DROP TABLE IF EXISTS count_verifications');
    await db.execute('DROP TABLE IF EXISTS detection_events');
    await db.execute('DROP TABLE IF EXISTS counting_sessions');
    await db.execute('DROP TABLE IF EXISTS camera_devices');
  }
}