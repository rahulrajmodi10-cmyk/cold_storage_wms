// lib/services/sales_order_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/finance_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class SalesOrderService extends BaseRepository<SalesOrder> {
  final Database db;
  final AuditService auditService;

  SalesOrderService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'sales_orders',
          entityType: EntityTypes.salesOrder,
          fromMap: (m) => SalesOrder.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(SalesOrder entity) => entity.toMap();

  @override
  int? getId(SalesOrder entity) => entity.id;

  @override
  SalesOrder setId(SalesOrder entity, int id) => entity..id = id;

  Future<SalesOrder?> getSalesOrder(int id) async => getById(id);

  Future<List<SalesOrder>> getSalesOrders({
    String? status,
    int? customerId,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = QueryBuilder.where();
    if (status != null) query.eq('status', status);
    if (customerId != null) query.eq('customer_id', customerId);
    query.orderBy('so_date', descending: true);
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

  Future<int> createSalesOrder(SalesOrder so, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = so.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await transaction((txn) async {
      final id = await txn.insert(tableName, map);
      await auditService.logInTransaction(
        txn,
        action: 'create_sales_order',
        detail: 'Created sales order ${so.soNumber}',
        entityType: EntityTypes.salesOrder,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<int> updateSalesOrder(SalesOrder so, {int? userId}) async {
    final map = so.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await transaction((txn) async {
      final count = await txn.update(tableName, map, where: 'id = ?', whereArgs: [so.id]);
      if (count == 0) throw StateError('Sales order not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_sales_order',
        detail: 'Updated sales order ${so.soNumber}',
        entityType: EntityTypes.salesOrder,
        entityId: so.id,
        userId: userId,
      );
      return so.id!;
    });
  }
}

class SalesOrderItemService extends BaseRepository<SalesOrderItem> {
  final Database db;
  final AuditService auditService;

  SalesOrderItemService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'sales_order_items',
          entityType: EntityTypes.salesOrderItem,
          fromMap: (m) => SalesOrderItem.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(SalesOrderItem entity) => entity.toMap();

  @override
  int? getId(SalesOrderItem entity) => entity.id;

  @override
  SalesOrderItem setId(SalesOrderItem entity, int id) => entity..id = id;

  Future<List<SalesOrderItem>> getSalesOrderItems(int soId) async {
    final query = QueryBuilder.where().eq('so_id', soId);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> addSalesOrderItem(SalesOrderItem item, {int? userId}) async {
    return await transaction((txn) async {
      final id = await txn.insert(tableName, item.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'add_sales_order_item',
        detail: 'Added item to SO ${item.soId}',
        entityType: EntityTypes.salesOrderItem,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<int> updateSalesOrderItem(SalesOrderItem item, {int? userId}) async {
    return await transaction((txn) async {
      final count = await txn.update(tableName, item.toMap(), where: 'id = ?', whereArgs: [item.id]);
      if (count == 0) throw StateError('Sales order item not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_sales_order_item',
        detail: 'Updated sales order item',
        entityType: EntityTypes.salesOrderItem,
        entityId: item.id,
        userId: userId,
      );
      return item.id!;
    });
  }
}