// lib/services/receiving_service.dart

import 'package:sqflite/sqflite.dart';
import 'inventory_service.dart';
import 'location_service.dart'
import 'temperature_service.dart';
import 'audit_service.dart';
import '../models/inventory_item.dart';
import '../models/temperature_log.dart';

class ReceivingService {
  final Database db;
  final InventoryService inventoryService;
  final LocationService locationService;
  final TemperatureService temperatureService;
  final AuditService auditService;

  ReceivingService(this.db)
      : inventoryService = InventoryService(db),
        locationService = LocationService(db),
        temperatureService = TemperatureService(db),
        auditService = AuditService(db);

  /// Process receiving: validate gatepass, check temp, assign location, create inventory
  Future<int> processReceiving({
    required String sku,
    required String name,
    required String category,
    required int quantity,
    required String unit,
    required int locationId,
    required double temperature,
    required double humidity,
    required int operatorId,
    int? expiryDate,
    double? minTemp,
    double? maxTemp,
    String? gatepassId,
    int? userId,
  }) async {
    // Validate location exists and has capacity
    final location = await locationService.getLocation(locationId);
    if (location == null) throw StateError('Location not found');
    if (location.currentUtilization + quantity > location.capacity) {
      throw StateError('Location capacity exceeded');
    }

    return await db.transaction((txn) async {
      // Create inventory item
      final item = InventoryItem(
        sku: sku,
        name: name,
        category: category,
        quantity: quantity,
        unit: unit,
        locationId: locationId,
        expiryDate: expiryDate,
        minTemp: minTemp,
        maxTemp: maxTemp,
        currentTemp: temperature,
        humidity: humidity,
        status: 'IN_STOCK',
      );
      final now = DateTime.now().millisecondsSinceEpoch;
      final itemId = await txn.insert('inventory_item', {
        'sku': item.sku,
        'name': item.name,
        'category': item.category,
        'quantity': item.quantity,
        'unit': item.unit,
        'location_id': item.locationId,
        'expiry_date': item.expiryDate,
        'min_temp': item.minTemp,
        'max_temp': item.maxTemp,
        'current_temp': item.currentTemp,
        'humidity': item.humidity,
        'status': item.status,
        'created_at': now,
        'updated_at': now,
      });

      // Update location utilization
      await txn.update(
        'storage_location',
        {'current_utilization': location.currentUtilization + quantity},
        where: 'id = ?',
        whereArgs: [locationId],
      );

      // Log temperature
      final tempLog = TemperatureLog(
        itemId: itemId,
        locationId: locationId,
        temperature: temperature,
        humidity: humidity,
        timestamp: now,
        sensorId: 'manual_receiving',
      );
      await txn.insert('temperature_log', tempLog.toMap());

      // Create transfer record for receiving
      await txn.insert('transfer_record', {
        'item_id': itemId,
        'from_location': null,
        'to_location': locationId,
        'quantity': quantity,
        'operator_id': operatorId,
        'timestamp': now,
        'reason': 'receiving',
      });

      // Link to gatepass if provided
      if (gatepassId != null) {
        await txn.insert('audit_log', {
          'user_id': operatorId,
          'action': 'receiving_complete',
          'detail': 'Received $quantity $unit of $sku via gatepass $gatepassId',
          'timestamp': now,
          'entity_type': 'gatepass',
          'entity_id': int.tryParse(gatepassId),
        });
      }

      await auditService.logInTransaction(
        txn,
        action: 'receiving_complete',
        detail: 'Received $quantity $unit of $sku at location $locationId',
        entityType: 'inventory_item',
        entityId: itemId,
        userId: userId ?? operatorId,
      );

      return itemId;
    });
  }
}