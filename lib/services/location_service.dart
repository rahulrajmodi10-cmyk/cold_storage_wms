import 'package:sqflite/sqflite.dart';
import '../models/storage_location.dart';

class LocationService {
  final Database db;

  LocationService(this.db);

  Future<int> createLocation(StorageLocation loc) async {
    if (loc.capacity <= 0) throw ArgumentError('capacity must be positive');
    if (loc.currentUtilization < 0 || loc.currentUtilization > loc.capacity) {
      throw ArgumentError('current utilization must be between 0 and capacity');
    }

    final id = await db.insert(
      'storage_location',
      {
        'rack_id': loc.rackId,
        'shelf_id': loc.shelfId,
        'bin_id': loc.binId,
        'zone': loc.zone,
        'capacity': loc.capacity,
        'current_utilization': loc.currentUtilization,
      },
    );
    await _audit('create_location', 'Created location ${loc.displayName}', id);
    return id;
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

  Future<void> updateLocation(StorageLocation loc) async {
    if (loc.capacity <= 0) throw ArgumentError('capacity must be positive');
    if (loc.currentUtilization < 0 || loc.currentUtilization > loc.capacity) {
      throw ArgumentError('current utilization must be between 0 and capacity');
    }

    await db.update(
      'storage_location',
      {
        'rack_id': loc.rackId,
        'shelf_id': loc.shelfId,
        'bin_id': loc.binId,
        'zone': loc.zone,
        'capacity': loc.capacity,
        'current_utilization': loc.currentUtilization,
      },
      where: 'id = ?',
      whereArgs: [loc.id],
    );
    await _audit('update_location', 'Updated location ${loc.displayName}', loc.id!);
  }

  Future<void> deleteLocation(int id) async {
    await db.delete('storage_location', where: 'id = ?', whereArgs: [id]);
    await _audit('delete_location', 'Deleted location id=$id', id);
  }

  Future<void> updateUtilization(int locationId, double newUtilization) async {
    final existing = await getLocation(locationId);
    if (existing == null) throw StateError('Location not found');

    if (newUtilization < 0 || newUtilization > existing.capacity) {
      throw ArgumentError('utilization must be between 0 and capacity');
    }

    await db.update(
      'storage_location',
      {'current_utilization': newUtilization},
      where: 'id = ?',
      whereArgs: [locationId],
    );

    await _audit(
      'update_utilization',
      'Updated utilization for location $locationId to $newUtilization',
      locationId,
    );
  }

  Future<void> _audit(String action, String detail, int? entityId) async {
    await db.insert('audit_log', {
      'user_id': null,
      'action': action,
      'detail': detail,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'entity_type': 'storage_location',
      'entity_id': entityId,
    });
  }
}
