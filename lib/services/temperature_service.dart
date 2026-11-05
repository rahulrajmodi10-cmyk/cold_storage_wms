// lib/services/temperature_service.dart

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../models/temperature_log.dart';
import '../models/inventory_item.dart';
import 'audit_service.dart';

class TemperatureService {
  final Database db;
  final AuditService auditService;

  TemperatureService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db);

  Future<int> logTemperature(TemperatureLog log) async {
    final id = await db.insert('temperature_log', log.toJson());

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
    return maps.map((m) => TemperatureLog.fromJson(m)).toList();
  }

  Future<List<TemperatureLog>> getLogsForLocation(int locationId, {int? limit}) async {
    final maps = await db.query(
      'temperature_log',
      where: 'location_id = ?',
      whereArgs: [locationId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((m) => TemperatureLog.fromJson(m)).toList();
  }

  Future<void> _checkExcursion(int itemId, int locationId, double temp, double humidity) async {
    final itemMaps = await db.query('inventory_item', where: 'id = ?', whereArgs: [itemId]);
    if (itemMaps.isEmpty) return;

    final item = InventoryItem.fromJson(itemMaps.first);
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
    await auditService.log(
      action: 'temperature_alert',
      detail: message,
      entityType: 'inventory_item',
      entityId: targetId,
    );
  }

  Timer? _backgroundTimer;
  int _backgroundIntervalSeconds = 300; // 5 minutes

  Future<void> startBackgroundMonitoring() async {
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(
      Duration(seconds: _backgroundIntervalSeconds),
      (timer) async {
        try {
          final allLogs = await db.query(
            'temperature_log',
            orderBy: 'timestamp DESC',
          );
          final logs = allLogs.map((m) => TemperatureLog.fromJson(m)).toList();

          // Get all inventory items to check temperatures
          final itemIds = <int>{};
          for (final log in logs) {
            itemIds.add(log.itemId);
          }

          for (final itemId in itemIds) {
            final itemMaps = await db.query(
              'inventory_item',
              where: 'id = ?',
              whereArgs: [itemId],
            );
            if (itemMaps.isEmpty) continue;

            final item = InventoryItem.fromJson(itemMaps.first);
            if (item.minTemp != null) {
              final itemLogs = logs.where((l) => l.itemId == itemId);
              for (final log in itemLogs) {
                if (log.temperature < item.minTemp!) {
                  await _createAlert(
                    'TEMP_EXCURSION_LOW',
                    'Temperature ${log.temperature}°C below min ${item.minTemp}°C for item ${item.sku}',
                    'high',
                    itemId,
                  );
                }
              }
            }
            if (item.maxTemp != null) {
              final itemLogs = logs.where((l) => l.itemId == itemId);
              for (final log in itemLogs) {
                if (log.temperature > item.maxTemp!) {
                  await _createAlert(
                    'TEMP_EXCURSION_HIGH',
                    'Temperature ${log.temperature}°C above max ${item.maxTemp}°C for item ${item.sku}',
                    'high',
                    itemId,
                  );
                }
              }
            }
          }
        } catch (e) {
          // Silently handle background monitoring errors
        }
      },
    );
  }

  void stopBackgroundMonitoring() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
  }
}