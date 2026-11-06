// lib/services/freight_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/logistics_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class FreightRateService extends BaseRepository<FreightRate> {
  final Database db;
  final AuditService auditService;

  FreightRateService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'freight_rates',
          entityType: EntityTypes.freightRate,
          fromMap: (m) => FreightRate.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(FreightRate entity) => entity.toMap();

  @override
  int? getId(FreightRate entity) => entity.id;

  @override
  FreightRate setId(FreightRate entity, int id) => entity..id = id;

  Future<List<FreightRate>> getFreightRates({
    int? routeId,
    int? carrierId,
    String? vehicleType,
    int? effectiveDate,
  }) async {
    final query = QueryBuilder.where();
    query.eq('is_active', 1);
    if (routeId != null) query.eq('route_id', routeId);
    if (carrierId != null) query.eq('carrier_id', carrierId);
    if (vehicleType != null) query.eq('vehicle_type', vehicleType);
    if (effectiveDate != null) {
      query.raw('effective_from <= ?', [effectiveDate]);
      query.raw('(effective_to IS NULL OR effective_to >= ?)', [effectiveDate]);
    }
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<FreightRate?> getBestFreightRate(int routeId, String vehicleType, int date) async {
    final rates = await getFreightRates(routeId: routeId, vehicleType: vehicleType, effectiveDate: date);
    if (rates.isEmpty) return null;
    rates.sort((a, b) => a.baseRate.compareTo(b.baseRate));
    return rates.first;
  }

  Future<int> createFreightRate(FreightRate rate, {int? userId}) async {
    return await create(rate,
        action: 'create_freight_rate',
        detail: 'Created freight rate for route ${rate.routeId}',
        userId: userId);
  }
}

class FreightBillService extends BaseRepository<FreightBill> {
  final Database db;
  final AuditService auditService;

  FreightBillService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'freight_bills',
          entityType: EntityTypes.freightBill,
          fromMap: (m) => FreightBill.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(FreightBill entity) => entity.toMap();

  @override
  int? getId(FreightBill entity) => entity.id;

  @override
  FreightBill setId(FreightBill entity, int id) => entity..id = id;

  Future<FreightBill?> getFreightBill(int id) async => getById(id);

  Future<List<FreightBill>> getFreightBills({int? carrierId, String? status, int? fromDate, int? toDate}) async {
    final query = QueryBuilder.where();
    if (carrierId != null) query.eq('carrier_id', carrierId);
    if (status != null) query.eq('status', status);
    if (fromDate != null) query.gte('bill_date', fromDate);
    if (toDate != null) query.lte('bill_date', toDate);
    query.orderBy('bill_date', descending: true);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createFreightBill(FreightBill bill, {int? userId}) async {
    return await create(bill,
        action: 'create_freight_bill',
        detail: 'Created freight bill ${bill.billNumber}',
        userId: userId);
  }

  Future<int> updateFreightBillStatus(int id, String status, {int? verifiedBy, int? paidDate, int? userId}) async {
    final map = {'status': status, 'updated_at': DateTime.now().millisecondsSinceEpoch};
    if (verifiedBy != null) {
      map['verified_by'] = verifiedBy;
      map['verified_at'] = DateTime.now().millisecondsSinceEpoch;
    }
    if (paidDate != null) map['paid_date'] = paidDate;
    return await transaction((txn) async {
      final count = await txn.update(tableName, map, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Freight bill not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_freight_bill_status',
        detail: 'Freight bill status changed to $status',
        entityType: EntityTypes.freightBill,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }
}

class LoadPlanService extends BaseRepository<LoadPlan> {
  final Database db;
  final AuditService auditService;

  LoadPlanService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'load_plans',
          entityType: EntityTypes.loadPlan,
          fromMap: (m) => LoadPlan.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(LoadPlan entity) => entity.toMap();

  @override
  int? getId(LoadPlan entity) => entity.id;

  @override
  LoadPlan setId(LoadPlan entity, int id) => entity..id = id;

  Future<LoadPlan?> getLoadPlan(int id) async => getById(id);

  Future<LoadPlan?> getLoadPlanByShipment(int shipmentId) async {
    final query = QueryBuilder.where().eq('shipment_id', shipmentId).limit(1);
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

  Future<List<LoadPlan>> getLoadPlans({String? status, int? vehicleId}) async {
    final query = QueryBuilder.where();
    if (status != null) query.eq('status', status);
    if (vehicleId != null) query.eq('vehicle_id', vehicleId);
    query.orderBy('plan_date', descending: true);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createLoadPlan(LoadPlan plan, {int? userId}) async {
    return await create(plan,
        action: 'create_load_plan',
        detail: 'Created load plan for shipment ${plan.shipmentId}',
        userId: userId);
  }

  Future<int> updateLoadPlan(LoadPlan plan, {int? userId}) async {
    return await update(plan,
        action: 'update_load_plan',
        detail: 'Updated load plan',
        userId: userId);
  }
}

class LoadPlanItemService extends BaseRepository<LoadPlanItem> {
  final Database db;
  final AuditService auditService;

  LoadPlanItemService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'load_plan_items',
          entityType: EntityTypes.loadPlanItem,
          fromMap: (m) => LoadPlanItem.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(LoadPlanItem entity) => entity.toMap();

  @override
  int? getId(LoadPlanItem entity) => entity.id;

  @override
  LoadPlanItem setId(LoadPlanItem entity, int id) => entity..id = id;

  Future<List<LoadPlanItem>> getLoadPlanItems(int loadPlanId) async {
    final query = QueryBuilder.where().eq('load_plan_id', loadPlanId).orderBy('load_order');
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> addLoadPlanItem(LoadPlanItem item, {int? userId}) async {
    return await create(item,
        action: 'add_load_plan_item',
        detail: 'Added item to load plan ${item.loadPlanId}',
        userId: userId);
  }

  Future<int> updateLoadPlanItemStatus(int itemId, String status, {double? loadedQuantity, int? loadedAt, int? loadedBy, int? userId}) async {
    final Map<String, dynamic> map = {'status': status};
    if (loadedQuantity != null) map['loaded_quantity'] = loadedQuantity;
    if (loadedAt != null) map['loaded_at'] = loadedAt;
    if (loadedBy != null) map['loaded_by'] = loadedBy;
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await transaction((txn) async {
      final count = await txn.update(tableName, map, where: 'id = ?', whereArgs: [itemId]);
      if (count == 0) throw StateError('Load plan item not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_load_plan_item_status',
        detail: 'Load plan item status changed to $status',
        entityType: EntityTypes.loadPlanItem,
        entityId: itemId,
        userId: userId,
      );
      return itemId;
    });
  }
}

class VehicleMaintenanceService extends BaseRepository<VehicleMaintenance> {
  final Database db;
  final AuditService auditService;

  VehicleMaintenanceService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'vehicle_maintenance',
          entityType: EntityTypes.vehicleMaintenance,
          fromMap: (m) => VehicleMaintenance.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(VehicleMaintenance entity) => entity.toMap();

  @override
  int? getId(VehicleMaintenance entity) => entity.id;

  @override
  VehicleMaintenance setId(VehicleMaintenance entity, int id) => entity..id = id;

  Future<List<VehicleMaintenance>> getVehicleMaintenance(int vehicleId, {String? status}) async {
    final query = QueryBuilder.where().eq('vehicle_id', vehicleId);
    if (status != null) query.eq('status', status);
    query.orderBy('service_date', descending: true);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<List<VehicleMaintenance>> getUpcomingMaintenance(int daysAhead) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final future = now + (daysAhead * 24 * 60 * 60 * 1000);
    final maps = await db.rawQuery('''
      SELECT vm.*, v.registration_number
      FROM vehicle_maintenance vm
      JOIN vehicles v ON vm.vehicle_id = v.id
      WHERE vm.next_due_date BETWEEN ? AND ? AND vm.status != 'COMPLETED'
      ORDER BY vm.next_due_date
    ''', [now, future]);
    return maps.map((m) => VehicleMaintenance.fromMap(m)).toList();
  }

  Future<int> createMaintenance(VehicleMaintenance maintenance, {int? userId}) async {
    return await create(maintenance,
        action: 'create_maintenance',
        detail: 'Created maintenance for vehicle ${maintenance.vehicleId}',
        userId: userId);
  }
}