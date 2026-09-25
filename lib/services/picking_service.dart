// lib/services/picking_service.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'inventory_service.dart';
import 'location_service.dart';
import '../models/transfer_record.dart';

class PickingService {
  final Database db;
  final InventoryService inventoryService;
  final LocationService locationService;

  PickingService(this.db)
      : inventoryService = InventoryService(db),
        locationService = LocationService(db);

  /// Create a pick request (SLA tracked)
  Future<int> createPickRequest({
    required int itemId,
    required int quantity,
    required int operatorId,
    String? notes,
  }) async {
    final item = await inventoryService.getItemById(itemId);
    if (item == null) throw StateError('Item not found');
    if (item.quantity < quantity) throw StateError('Insufficient stock');
    if (item.status == 'QUARANTINED') throw StateError('Item is quarantined');

    // Create transfer record as pick request
    return await db.insert('transfer_record', {
      'item_id': itemId,
      'from_location': item.locationId,
      'to_location': null,
      'quantity': quantity,
      'operator_id': operatorId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'reason': 'pick_request',
    });
  }

  /// Complete a pick request
  Future<void> completePick(int pickRequestId, {required int operatorId}) async {
    final maps = await db.query('transfer_record', where: 'id = ?', whereArgs: [pickRequestId]);
    if (maps.isEmpty) throw StateError('Pick request not found');
    final record = TransferRecord.fromMap(maps.first);
    if (record.reason != 'pick_request') throw StateError('Not a pick request');

    final item = await inventoryService.getItemById(record.itemId);
    if (item == null) throw StateError('Item not found');

    await db.transaction((txn) async {
      // Update inventory quantity
      await txn.update('inventory_item', {
        'quantity': item.quantity - record.quantity,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ?', whereArgs: [item.id]);

      // Update location utilization
      if (item.locationId != null) {
        final loc = await locationService.getLocation(item.locationId!);
        if (loc != null) {
          await txn.update('storage_location', {
            'current_utilization': loc.currentUtilization - record.quantity,
          }, where: 'id = ?', whereArgs: [item.locationId!]);
        }
      }

      // Create completion transfer record
      await txn.insert('transfer_record', {
        'item_id': item.id,
        'from_location': item.locationId,
        'to_location': null,
        'quantity': -record.quantity,
        'operator_id': operatorId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'reason': 'pick_complete',
      });

      // Mark original request as completed
      await txn.update('transfer_record', {
        'reason': 'pick_completed',
      }, where: 'id = ?', whereArgs: [pickRequestId]);
    });

    await inventoryService.audit('pick_complete', 'Picked ${record.quantity} of ${item.sku}', item.id);
  }

  Future<List<TransferRecord>> getPendingPicks() async {
    final maps = await db.query('transfer_record', where: 'reason = ?', whereArgs: ['pick_request']);
    return maps.map((m) => TransferRecord.fromMap(m)).toList();
  }
}