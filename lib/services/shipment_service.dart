// lib/services/shipment_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/logistics_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class ShipmentService extends BaseRepository<Shipment> {
  final Database db;
  final AuditService auditService;

  ShipmentService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'shipments',
          entityType: EntityTypes.shipment,
          fromMap: (m) => Shipment.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(Shipment entity) => entity.toMap();

  @override
  int? getId(Shipment entity) => entity.id;

  @override
  Shipment setId(Shipment entity, int id) => entity..id = id;

  Future<Shipment?> getShipment(int id) async => getById(id);

  Future<Shipment?> getShipmentByNumber(String shipmentNumber) async {
    final query = QueryBuilder.where().eq('shipment_number', shipmentNumber);
    final queryMap = query.build();
    final results = await list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Shipment>> getShipments({
    String? status,
    int? carrierId,
    int? vehicleId,
    int? fromDate,
    int? toDate,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = QueryBuilder.where();
    if (status != null) query.eq('status', status);
    if (carrierId != null) query.eq('carrier_id', carrierId);
    if (vehicleId != null) query.eq('vehicle_id', vehicleId);
    if (fromDate != null) query.gte('shipment_date', fromDate);
    if (toDate != null) query.lte('shipment_date', toDate);
    query.orderBy('shipment_date', descending: true);
    query.limit(limit);
    query.offset(offset);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createShipment(Shipment shipment, {int? userId}) async {
    return await create(shipment,
        action: 'create_shipment',
        detail: 'Created shipment ${shipment.shipmentNumber}',
        userId: userId);
  }

  Future<int> updateShipment(Shipment shipment, {int? userId}) async {
    return await update(shipment,
        action: 'update_shipment',
        detail: 'Updated shipment ${shipment.shipmentNumber}',
        userId: userId);
  }

  Future<int> updateShipmentStatus(int id, String status, {int? timestamp, Map<String, dynamic>? extraFields, int? userId}) async {
    final Map<String, dynamic> map = {
      'status': status,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    if (timestamp != null) {
      switch (status) {
        case 'LOADED':
          map['loading_end_time'] = timestamp;
          break;
        case 'IN_TRANSIT':
          map['departure_time'] = timestamp;
          break;
        case 'ARRIVED':
          map['arrival_time'] = timestamp;
          break;
        case 'UNLOADED':
          map['unloading_end_time'] = timestamp;
          break;
        case 'DELIVERED':
          map['unloading_end_time'] = timestamp;
          break;
      }
    }
    if (extraFields != null) {
      map.addAll(extraFields);
    }
    return await transaction((txn) async {
      final count = await txn.update(tableName, map, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Shipment not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_shipment_status',
        detail: 'Shipment status changed to $status',
        entityType: EntityTypes.shipment,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }
}

class ShipmentItemService extends BaseRepository<ShipmentItem> {
  final Database db;
  final AuditService auditService;

  ShipmentItemService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'shipment_items',
          entityType: EntityTypes.shipmentItem,
          fromMap: (m) => ShipmentItem.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(ShipmentItem entity) => entity.toMap();

  @override
  int? getId(ShipmentItem entity) => entity.id;

  @override
  ShipmentItem setId(ShipmentItem entity, int id) => entity..id = id;

  Future<List<ShipmentItem>> getShipmentItems(int shipmentId) async {
    final query = QueryBuilder.where().eq('shipment_id', shipmentId);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> addShipmentItem(ShipmentItem item, {int? userId}) async {
    return await create(item,
        action: 'add_shipment_item',
        detail: 'Added item to shipment ${item.shipmentId}',
        userId: userId);
  }

  Future<int> updateShipmentItem(ShipmentItem item, {int? userId}) async {
    return await update(item,
        action: 'update_shipment_item',
        detail: 'Updated shipment item',
        userId: userId);
  }

  Future<int> updateShipmentItemLoadedQuantity(int itemId, double loadedQuantity, {int? userId}) async {
    final map = {'loaded_quantity': loadedQuantity, 'updated_at': DateTime.now().millisecondsSinceEpoch};
    return await transaction((txn) async {
      final count = await txn.update(tableName, map, where: 'id = ?', whereArgs: [itemId]);
      if (count == 0) throw StateError('Shipment item not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_shipment_item_loaded',
        detail: 'Updated loaded quantity to $loadedQuantity',
        entityType: EntityTypes.shipmentItem,
        entityId: itemId,
        userId: userId,
      );
      return itemId;
    });
  }

  Future<int> updateShipmentItemDeliveredQuantity(int itemId, double deliveredQuantity, {int? userId}) async {
    final map = {'delivered_quantity': deliveredQuantity, 'updated_at': DateTime.now().millisecondsSinceEpoch};
    return await transaction((txn) async {
      final count = await txn.update(tableName, map, where: 'id = ?', whereArgs: [itemId]);
      if (count == 0) throw StateError('Shipment item not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_shipment_item_delivered',
        detail: 'Updated delivered quantity to $deliveredQuantity',
        entityType: EntityTypes.shipmentItem,
        entityId: itemId,
        userId: userId,
      );
      return itemId;
    });
  }
}

class ShipmentTrackingService extends BaseRepository<ShipmentTracking> {
  final Database db;
  final AuditService auditService;

  ShipmentTrackingService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'shipment_tracking',
          entityType: EntityTypes.shipmentTracking,
          fromMap: (m) => ShipmentTracking.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(ShipmentTracking entity) => entity.toMap();

  @override
  int? getId(ShipmentTracking entity) => entity.id;

  @override
  ShipmentTracking setId(ShipmentTracking entity, int id) => entity..id = id;

  Future<List<ShipmentTracking>> getShipmentTracking(int shipmentId) async {
    final query = QueryBuilder.where().eq('shipment_id', shipmentId).orderBy('timestamp');
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<ShipmentTracking?> getLatestTracking(int shipmentId) async {
    final query = QueryBuilder.where().eq('shipment_id', shipmentId).orderBy('timestamp', descending: true).limit(1);
    final queryMap = query.build();
    final results = await list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> addTrackingPoint(ShipmentTracking tracking, {int? userId}) async {
    return await create(tracking,
        action: 'add_tracking_point',
        detail: 'Added tracking point for shipment ${tracking.shipmentId}',
        userId: userId);
  }
}