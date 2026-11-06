// lib/db/migrations/migration_registry.dart

import 'package:sqflite/sqflite.dart';
import 'migration_001_inventory.dart';
import 'migration_002_finance.dart';
import 'migration_003_logistics.dart';
import 'migration_004_camera_ai.dart';
import 'migration_005_gatepass_barcode.dart';

/// Migration registry - centralizes all database migrations
/// Each migration has an up() and down() method for forward/backward compatibility
class MigrationRegistry {
  /// List of all migrations in order of execution
  static final List<Migration> _migrations = [
    Migration(1, Migration001Inventory.up, Migration001Inventory.down),
    Migration(2, Migration002Finance.up, Migration002Finance.down),
    Migration(3, Migration003Logistics.up, Migration003Logistics.down),
    Migration(4, Migration004CameraAI.up, Migration004CameraAI.down),
    Migration(5, Migration005GatepassBarcode.up, Migration005GatepassBarcode.down),
  ];

  /// Get all migrations
  static List<Migration> get all => _migrations;

  /// Get current database version (highest migration version)
  static int get currentVersion => _migrations.last.version;

  /// Run migrations up to a specific version (for fresh installs)
  static Future<void> runMigrationsUpTo(Database db, int targetVersion) async {
    for (final migration in _migrations) {
      if (migration.version <= targetVersion) {
        await migration.up(db);
      }
    }
  }

  /// Run incremental migrations from oldVersion+1 to newVersion (for upgrades)
  static Future<void> runMigrationsFromTo(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (final migration in _migrations) {
      if (migration.version > oldVersion && migration.version <= newVersion) {
        await migration.up(db);
      }
    }
  }

  /// Rollback migrations from newVersion down to oldVersion+1
  static Future<void> rollbackMigrationsFromTo(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (final migration in _migrations.reversed) {
      if (migration.version > oldVersion && migration.version <= newVersion) {
        await migration.down(db);
      }
    }
  }
}

/// Represents a single database migration
class Migration {
  final int version;
  final Future<void> Function(Database) up;
  final Future<void> Function(Database) down;

  Migration(this.version, this.up, this.down);
}