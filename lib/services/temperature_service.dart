// lib/services/temperature_service.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/temperature_log.dart';
import '../models/inventory_item.dart';

class TemperatureService {
  final Database db;

  TemperatureService(this.db);

  Future<int> logTemperature(TemperatureLog log) async {
    final id = await db.insert('temperature_log', log.toMap());

    // Check for temperature excursion
    await _checkExcursion(log.itemId, log.locationId, log.temperature, log.humidity);

    return id;
  }

  Future<List<TemperatureLog>> getLogsForItem(int itemId, {int? limit}) async {
    final maps = await db.query(
      'temperature_log',
      where: 'item_id = ?',
      whereArgs: [itemId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((m) => TemperatureLog.fromMap(m)).toList();
  }

  Future<List<TemperatureLog>> getLogsForLocation(int locationId, {int? limit}) async {
    final maps = await db.query(
      'temperature_log',
      where: 'location_id = ?',
      whereArgs: [locationId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((m) => TemperatureLog.fromMap(m)).toList();
  }

  Future<void> _checkExcursion(int itemId, int locationId, double temp, double humidity) async {
    final itemMaps = await db.query('inventory_item', where: 'id = ?', whereArgs: [itemId]);
    if (itemMaps.isEmpty) return;

    final item = InventoryItem.fromMap(itemMaps.first);
    if (item.minTemp != null && temp < item.minTemp!) {
      await _createAlert('TEMP_EXCURSION_LOW', 'Temperature ${temp}°C below min ${item.minTemp}°C for item ${item.sku}', 'high', itemId);
    }
    if (item.maxTemp != null && temp > item.maxTemp!) {
      await _createAlert('TEMP_EXCURSION_HIGH', 'Temperature ${temp}°C above max ${item.maxTemp}°C for item ${item.sku}', 'high', itemId);
    }
  }

  Future<void> _createAlert(String type, String message, String severity, int targetId) async {
    await db.insert('alert', {
      'type': type,
      'severity': severity,
      'message': message,
      'target_id': targetId,
      'acknowledged': 0,
      'created_at': DateTime.now().millisecondsSinceEpoch
    });
    await db.insert('audit_log', {
      'user_id': null,
      'action': 'temperature_alert',
      'detail': message,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'entity_type': 'inventory_item',
      'entity_id': targetId
    });
  }
}