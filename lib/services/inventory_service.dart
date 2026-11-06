// lib/services/inventory_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/inventory_item.dart';
import 'audit_service.dart';

class InventoryService {
  final Database db;
  final AuditService auditService;

  InventoryService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db);

  Future<int> createItem(InventoryItem item, {int? userId}) async {
    if (item.quantity < 0) throw ArgumentError('quantity cannot be negative');

    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.transaction((txn) async {
      final id = await txn.insert('inventory_item', {
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

      await auditService.logInTransaction(
        txn,
        action: 'create_inventory',
        detail: 'Created item ${item.sku}',
        entityType: 'inventory_item',
        entityId: id,
        userId: userId,
      );
      return id;
    });
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

    if (category != null && category.isNotEmpty) {
      where.add('category = ?');
      args.add(category);
    }

    if (status != null && status.isNotEmpty) {
      where.add('status = ?');
      args.add(status);
    }

    final maps = await db.query(
      'inventory_item',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
    );

    return maps.map((m) => InventoryItem.fromMap(m)).toList();
  }

  Future<void> updateItem(InventoryItem item, {int? userId}) async {
    if (item.id == null) throw ArgumentError('item id is required');
    if (item.quantity < 0) throw ArgumentError('quantity cannot be negative');

    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final count = await txn.update(
        'inventory_item',
        {
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
        },
        where: 'id = ?',
        whereArgs: [item.id],
      );
      if (count == 0) throw StateError('Item not found');

      await auditService.logInTransaction(
        txn,
        action: 'update_inventory',
        detail: 'Updated item ${item.sku}',
        entityType: 'inventory_item',
        entityId: item.id,
        userId: userId,
      );
    });
  }

  Future<void> deleteItem(int id, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.delete('inventory_item', where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Item not found');

      await auditService.logInTransaction(
        txn,
        action: 'delete_inventory',
        detail: 'Deleted item id=$id',
        entityType: 'inventory_item',
        entityId: id,
        userId: userId,
      );
    });
  }

  Future<void> changeQuantity(int id, int delta, {required int operatorId, int? userId}) async {
    if (delta == 0) return;

    await db.transaction((txn) async {
      final maps = await txn.query('inventory_item', where: 'id = ?', whereArgs: [id]);
      if (maps.isEmpty) throw StateError('Item not found');

      final current = (maps.first['quantity'] as num).toInt();
      final updated = current + delta;

      if (updated < 0) throw ArgumentError('Resulting quantity would be negative');

      await txn.update(
        'inventory_item',
        {
          'quantity': updated,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      await txn.insert('transfer_record', {
        'item_id': id,
        'from_location': null,
        'to_location': null,
        'quantity': delta,
        'operator_id': operatorId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'reason': 'quantity_change',
      });

      await auditService.logInTransaction(
        txn,
        action: 'quantity_change',
        detail: 'Changed quantity for item id=$id by $delta',
        entityType: 'inventory_item',
        entityId: id,
        userId: userId ?? operatorId,
      );
    });
  }

  Future<void> transferItem({
    required int itemId,
    required int fromLocationId,
    required int toLocationId,
    required int quantity,
    required int operatorId,
    int? userId,
  }) async {
    if (quantity <= 0) throw ArgumentError('quantity must be positive');

    await db.transaction((txn) async {
      final itemMaps = await txn.query('inventory_item', where: 'id = ?', whereArgs: [itemId]);
      if (itemMaps.isEmpty) throw StateError('Item not found');

      final item = InventoryItem.fromMap(itemMaps.first);
      if (item.quantity < quantity) throw StateError('Insufficient stock');
      if (item.locationId != fromLocationId) throw StateError('Item not at from_location');

      // Update item location and quantity
      await txn.update(
        'inventory_item',
        {
          'location_id': toLocationId,
          'quantity': item.quantity - quantity,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [itemId],
      );

      // Create transfer record
      await txn.insert('transfer_record', {
        'item_id': itemId,
        'from_location': fromLocationId,
        'to_location': toLocationId,
        'quantity': quantity,
        'operator_id': operatorId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'reason': 'transfer',
      });

      // Update utilization on both locations
      await _updateLocationUtilization(txn, fromLocationId, -quantity);
      await _updateLocationUtilization(txn, toLocationId, quantity);

      await auditService.logInTransaction(
        txn,
        action: 'transfer_item',
        detail: 'Transferred $quantity of item ${item.sku} from location $fromLocationId to $toLocationId',
        entityType: 'inventory_item',
        entityId: itemId,
        userId: userId ?? operatorId,
      );
    });
  }

  Future<void> _updateLocationUtilization(Transaction txn, int locationId, int delta) async {
    final maps = await txn.query('storage_location', where: 'id = ?', whereArgs: [locationId]);
    if (maps.isEmpty) return;

    final currentUtil = (maps.first['current_utilization'] as num).toDouble();
    final capacity = (maps.first['capacity'] as num).toDouble();
    final newUtil = currentUtil + delta;

    if (newUtil < 0 || newUtil > capacity) {
      throw StateError('Utilization would be out of bounds for location $locationId');
    }

    await txn.update(
      'storage_location',
      {'current_utilization': newUtil},
      where: 'id = ?',
      whereArgs: [locationId],
    );
  }
}