// lib/services/dispatch_service.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'inventory_service.dart';
import 'location_service.dart';

class DispatchService {
  final Database db;
  final InventoryService inventoryService;
  final LocationService locationService;

  DispatchService(this.db)
      : inventoryService = InventoryService(db),
        locationService = LocationService(db);

  /// Generate gatepass for dispatch
  Future<int> createDispatchGatepass({
    required int itemId,
    required int quantity,
    required int operatorId,
    required String recipient,
    String? vehicleNumber,
    String? destination,
  }) async {
    final item = await inventoryService.getItemById(itemId);
    if (item == null) throw StateError('Item not found');
    if (item.quantity < quantity) throw StateError('Insufficient stock');
    if (item.status != 'IN_STOCK') throw StateError('Item not available for dispatch');

    return await db.insert('gatepass', {
      'item_id': itemId,
      'quantity': quantity,
      'operator_id': operatorId,
      'recipient': recipient,
      'vehicle_number': vehicleNumber,
      'destination': destination,
      'status': 'PENDING',
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Complete dispatch: scan gatepass, reduce inventory, update location
  Future<void> completeDispatch(int gatepassId, {required int operatorId}) async {
    final maps = await db.query('gatepass', where: 'id = ?', whereArgs: [gatepassId]);
    if (maps.isEmpty) throw StateError('Gatepass not found');
    final gp = maps.first;

    if (gp['status'] == 'COMPLETED') throw StateError('Gatepass already completed');

    final item = await inventoryService.getItemById(gp['item_id'] as int);
    if (item == null) throw StateError('Item not found');

    await db.transaction((txn) async {
      // Update inventory
      await txn.update('inventory_item', {
        'quantity': item.quantity - (gp['quantity'] as int),
        'status': item.quantity - (gp['quantity'] as int) <= 0 ? 'DISPATCHED' : 'IN_STOCK',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ?', whereArgs: [item.id]);

      // Update location utilization
      if (item.locationId != null) {
        final loc = await locationService.getLocation(item.locationId!);
        if (loc != null) {
          await txn.update('storage_location', {
            'current_utilization': loc.currentUtilization - (gp['quantity'] as int),
          }, where: 'id = ?', whereArgs: [item.locationId!]);
        }
      }

      // Create dispatch transfer record
      await txn.insert('transfer_record', {
        'item_id': item.id,
        'from_location': item.locationId,
        'to_location': null,
        'quantity': -(gp['quantity'] as int),
        'operator_id': operatorId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'reason': 'dispatch',
      });

      // Update gatepass
      await txn.update('gatepass', {
        'status': 'COMPLETED',
        'completed_at': DateTime.now().millisecondsSinceEpoch,
        'completed_by': operatorId,
      }, where: 'id = ?', whereArgs: [gatepassId]);
    });

    await inventoryService.audit('dispatch_complete', 'Dispatched ${gp['quantity']} of ${item.sku} to ${gp['recipient']}', item.id);
  }
}