// lib/services/receiving_service.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'inventory_service.dart';
import 'location_service.dart';
import 'temperature_service.dart';
import '../models/inventory_item.dart';
import '../models/temperature_log.dart';

class ReceivingService {
  final Database db;
  final InventoryService inventoryService;
  final LocationService locationService;
  final TemperatureService temperatureService;

  ReceivingService(this.db)
      : inventoryService = InventoryService(db),
        locationService = LocationService(db),
        temperatureService = TemperatureService(db);

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
  }) async {
    // Validate location exists and has capacity
    final location = await locationService.getLocation(locationId);
    if (location == null) throw StateError('Location not found');
    if (location.currentUtilization + quantity > location.capacity) {
      throw StateError('Location capacity exceeded');
    }

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
    final itemId = await inventoryService.createItem(item);

    // Update location utilization
    await locationService.updateUtilization(locationId, location.currentUtilization + quantity);

    // Log temperature
    final tempLog = TemperatureLog(
      itemId: itemId,
      locationId: locationId,
      temperature: temperature,
      humidity: humidity,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      sensorId: 'manual_receiving',
    );
    await temperatureService.logTemperature(tempLog);

    // Create transfer record for receiving
    await db.insert('transfer_record', {
      'item_id': itemId,
      'from_location': null,
      'to_location': locationId,
      'quantity': quantity,
      'operator_id': operatorId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'reason': 'receiving',
    });

    // Link to gatepass if provided
    if (gatepassId != null) {
      await db.insert('audit_log', {
        'user_id': operatorId,
        'action': 'receiving_complete',
        'detail': 'Received $quantity $unit of $sku via gatepass $gatepassId',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'entity_type': 'gatepass',
        'entity_id': int.tryParse(gatepassId),
      });
    }

    return itemId;
  }
}