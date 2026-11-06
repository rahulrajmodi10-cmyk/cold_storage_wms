// lib/services/purchase_order_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/finance_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class PurchaseOrderService extends BaseRepository<PurchaseOrder> {
  final Database db;
  final AuditService auditService;

  PurchaseOrderService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'purchase_orders',
          entityType: EntityTypes.purchaseOrder,
          fromMap: (m) => PurchaseOrder.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(PurchaseOrder entity) => entity.toMap();

  @override
  int? getId(PurchaseOrder entity) => entity.id;

  @override
  PurchaseOrder setId(PurchaseOrder entity, int id) => entity..id = id;

  Future<PurchaseOrder?> getPurchaseOrder(int id) async => getById(id);

  Future<List<PurchaseOrder>> getPurchaseOrders({
    String? status,
    int? vendorId,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = QueryBuilder.where();
    if (status != null) query.eq('status', status);
    if (vendorId != null) query.eq('vendor_id', vendorId);
    query.orderBy('po_date', descending: true);
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

  Future<int> createPurchaseOrder(PurchaseOrder po, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = po.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await transaction((txn) async {
      final id = await txn.insert(tableName, map);
      await auditService.logInTransaction(
        txn,
        action: 'create_purchase_order',
        detail: 'Created purchase order ${po.poNumber}',
        entityType: EntityTypes.purchaseOrder,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<int> updatePurchaseOrder(PurchaseOrder po, {int? userId}) async {
    final map = po.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await transaction((txn) async {
      final count = await txn.update(tableName, map, where: 'id = ?', whereArgs: [po.id]);
      if (count == 0) throw StateError('Purchase order not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_purchase_order',
        detail: 'Updated purchase order ${po.poNumber}',
        entityType: EntityTypes.purchaseOrder,
        entityId: po.id,
        userId: userId,
      );
      return po.id!;
    });
  }
}

class PurchaseOrderItemService extends BaseRepository<PurchaseOrderItem> {
  final Database db;
  final AuditService auditService;

  PurchaseOrderItemService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'purchase_order_items',
          entityType: EntityTypes.purchaseOrderItem,
          fromMap: (m) => PurchaseOrderItem.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(PurchaseOrderItem entity) => entity.toMap();

  @override
  int? getId(PurchaseOrderItem entity) => entity.id;

  @override
  PurchaseOrderItem setId(PurchaseOrderItem entity, int id) => entity..id = id;

  Future<List<PurchaseOrderItem>> getPurchaseOrderItems(int poId) async {
    final query = QueryBuilder.where().eq('po_id', poId);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> addPurchaseOrderItem(PurchaseOrderItem item, {int? userId}) async {
    return await transaction((txn) async {
      final id = await txn.insert(tableName, item.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'add_purchase_order_item',
        detail: 'Added item to PO ${item.poId}',
        entityType: EntityTypes.purchaseOrderItem,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<int> updatePurchaseOrderItem(PurchaseOrderItem item, {int? userId}) async {
    return await transaction((txn) async {
      final count = await txn.update(tableName, item.toMap(), where: 'id = ?', whereArgs: [item.id]);
      if (count == 0) throw StateError('Purchase order item not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_purchase_order_item',
        detail: 'Updated purchase order item',
        entityType: EntityTypes.purchaseOrderItem,
        entityId: item.id,
        userId: userId,
      );
      return item.id!;
    });
  }
}