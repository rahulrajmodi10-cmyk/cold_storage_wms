// lib/services/inventory_service.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/inventory_item.dart';

class InventoryService {
  final Database db;

  InventoryService(this.db);

  Future<int> createItem(InventoryItem item) async {
    if (item.quantity < 0) throw ArgumentError('quantity cannot be negative');
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await db.insert('inventory_item', {
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
    await audit('create_inventory', 'Created item ${item.sku}', id);
    return id;
  }

  Future<InventoryItem?> getItemById(int id) async {
    final maps = await db.query('inventory_item', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return InventoryItem.fromMap(maps.first);
  }

  Future<List<InventoryItem>> searchItems({String? query, String? category, String? status}) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (query != null && query.isNotEmpty) {
      where.add('(sku LIKE ? OR name LIKE ?)');
      args.addAll(['%$query%', '%$query%']);
    }
    if (category != null) {
      where.add('category = ?');
      args.add(category);
    }
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    final maps = await db.query('inventory_item', where: where.isEmpty ? null : where.join(' AND '), whereArgs: args);
    return maps.map((m) => InventoryItem.fromMap(m)).toList();
  }

  Future<void> updateItem(InventoryItem item) async {
    if (item.quantity < 0) throw ArgumentError('quantity cannot be negative');
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update('inventory_item', {
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
      'updated_at': now,
    }, where: 'id = ?', whereArgs: [item.id]);
    await audit('update_inventory', 'Updated item ${item.sku}', item.id!);
  }

  Future<void> deleteItem(int id) async {
    await db.delete('inventory_item', where: 'id = ?', whereArgs: [id]);
    await audit('delete_inventory', 'Deleted item id=$id', id);
  }

  Future<void> changeQuantity(int id, int delta, {required int operatorId}) async {
    await db.transaction((txn) async {
      final maps = await txn.query('inventory_item', where: 'id = ?', whereArgs: [id]);
      if (maps.isEmpty) throw StateError('Item not found');
      final current = maps.first['quantity'] as int;
      final updated = current + delta;
      if (updated < 0) throw ArgumentError('Resulting quantity would be negative');
      await txn.update('inventory_item', {'quantity': updated, 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [id]);
      await txn.insert('transfer_record', {
        'item_id': id,
        'from_location': null,
        'to_location': null,
        'quantity': delta,
        'operator_id': operatorId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'reason': 'quantity_change'
      });
    });
    await audit('quantity_change', 'Changed quantity for item id=$id by $delta', id);
  }

  Future<void> audit(String action, String detail, int? entityId) async {
    await db.insert('audit_log', {
      'user_id': null,
      'action': action,
      'detail': detail,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'entity_type': 'inventory_item',
      'entity_id': entityId
    });
  }
}
