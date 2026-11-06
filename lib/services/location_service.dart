// lib/services/location_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/storage_location.dart';
import 'audit_service.dart';

class LocationService {
  final Database db;
  final AuditService auditService;

  LocationService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db);

  Future<int> createLocation(StorageLocation loc, {int? userId}) async {
    if (loc.capacity <= 0) throw ArgumentError('capacity must be positive');
    if (loc.currentUtilization < 0 || loc.currentUtilization > loc.capacity) {
      throw ArgumentError('current utilization must be between 0 and capacity');
    }

    return await db.transaction((txn) async {
      final id = await txn.insert('storage_location', loc.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'create_location',
        detail: 'Created location ${loc.displayName}',
        entityType: 'storage_location',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<StorageLocation?> getLocation(int id) async {
    final maps = await db.query('storage_location', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return StorageLocation.fromMap(maps.first);
  }

  Future<List<StorageLocation>> listLocations({String? zone}) async {
    final where = zone != null ? 'zone = ?' : null;
    final args = zone != null ? [zone] : null;
    final maps = await db.query('storage_location', where: where, whereArgs: args);
    return maps.map((m) => StorageLocation.fromMap(m)).toList();
  }

  Future<void> updateLocation(StorageLocation loc, {int? userId}) async {
    if (loc.id == null) throw ArgumentError('location id is required');
    if (loc.capacity <= 0) throw ArgumentError('capacity must be positive');
    if (loc.currentUtilization < 0 || loc.currentUtilization > loc.capacity) {
      throw ArgumentError('current utilization must be between 0 and capacity');
    }

    await db.transaction((txn) async {
      final count = await txn.update(
        'storage_location',
        loc.toMap(),
        where: 'id = ?',
        whereArgs: [loc.id],
      );
      if (count == 0) throw StateError('Location not found');

      await auditService.logInTransaction(
        txn,
        action: 'update_location',
        detail: 'Updated location ${loc.displayName}',
        entityType: 'storage_location',
        entityId: loc.id,
        userId: userId,
      );
    });
  }

  Future<void> deleteLocation(int id, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.delete('storage_location', where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Location not found');

      await auditService.logInTransaction(
        txn,
        action: 'delete_location',
        detail: 'Deleted location id=$id',
        entityType: 'storage_location',
        entityId: id,
        userId: userId,
      );
    });
  }

  Future<void> updateUtilization(int locationId, double newUtilization, {int? userId}) async {
    await db.transaction((txn) async {
      final maps = await txn.query('storage_location', where: 'id = ?', whereArgs: [locationId]);
      if (maps.isEmpty) throw StateError('Location not found');

      final capacity = (maps.first['capacity'] as num).toDouble();
      if (newUtilization < 0 || newUtilization > capacity) {
        throw ArgumentError('utilization must be between 0 and capacity');
      }

      final count = await txn.update(
        'storage_location',
        {'current_utilization': newUtilization},
        where: 'id = ?',
        whereArgs: [locationId],
      );
      if (count == 0) throw StateError('Location not found');

      await auditService.logInTransaction(
        txn,
        action: 'update_utilization',
        detail: 'Updated utilization for location $locationId to $newUtilization',
        entityType: 'storage_location',
        entityId: locationId,
        userId: userId,
      );
    });
  }
}