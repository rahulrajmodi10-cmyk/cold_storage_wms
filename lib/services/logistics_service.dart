// lib/services/logistics_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/logistics_models.dart';
import 'audit_service.dart';

class LogisticsService {
  final Database db;
  final AuditService auditService;

  LogisticsService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db);

  // ============ Carriers ============

  Future<int> createCarrier(Carrier carrier, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = carrier.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('carriers', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_carrier',
        detail: 'Created carrier ${carrier.name}',
        entityType: 'carriers',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<Carrier?> getCarrier(int id) async {
    final maps = await db.query('carriers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Carrier.fromMap(maps.first);
  }

  Future<List<Carrier>> getCarriers({bool activeOnly = true}) async {
    return _getCarriers(activeOnly: activeOnly);
  }

  Future<List<Carrier>> _getCarriers({bool activeOnly = true}) async {
    final where = activeOnly ? 'is_active = 1' : null;
    final maps = await db.query('carriers', where: where, orderBy: 'name');
    return maps.map((m) => Carrier.fromMap(m)).toList();
  }

  Future<int> updateCarrier(Carrier carrier, {int? userId}) async {
    final map = carrier.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final count = await txn.update('carriers', map, where: 'id = ?', whereArgs: [carrier.id]);
      if (count == 0) throw StateError('Carrier not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_carrier',
        detail: 'Updated carrier ${carrier.name}',
        entityType: 'carriers',
        entityId: carrier.id,
        userId: userId,
      );
    });
    return carrier.id!;
  }

  // ============ Vehicles ============

  Future<int> createVehicle(Vehicle vehicle, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = vehicle.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('vehicles', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_vehicle',
        detail: 'Created vehicle ${vehicle.registrationNumber}',
        entityType: 'vehicles',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<Vehicle?> getVehicle(int id) async {
    final maps = await db.query('vehicles', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Vehicle.fromMap(maps.first);
  }

  Future<Vehicle?> getVehicleByRegistration(String registrationNumber) async {
    final maps = await db.query('vehicles', where: 'registration_number = ?', whereArgs: [registrationNumber]);
    if (maps.isEmpty) return null;
    return Vehicle.fromMap(maps.first);
  }

  Future<List<Vehicle>> getVehicles({
    String? status,
    int? carrierId,
    bool activeOnly = true,
  }) async {
    return _getVehicles(status: status, carrierId: carrierId, activeOnly: activeOnly);
  }

  Future<List<Vehicle>> _getVehicles({
    String? status,
    int? carrierId,
    bool activeOnly = true,
  }) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    if (carrierId != null) {
      where.add('carrier_id = ?');
      args.add(carrierId);
    }
    if (activeOnly) {
      where.add('is_active = 1');
    }
    final maps = await db.query(
      'vehicles',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'registration_number',
    );
    return maps.map((m) => Vehicle.fromMap(m)).toList();
  }

  Future<int> updateVehicle(Vehicle vehicle, {int? userId}) async {
    final map = vehicle.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final count = await txn.update('vehicles', map, where: 'id = ?', whereArgs: [vehicle.id]);
      if (count == 0) throw StateError('Vehicle not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_vehicle',
        detail: 'Updated vehicle ${vehicle.registrationNumber}',
        entityType: 'vehicles',
        entityId: vehicle.id,
        userId: userId,
      );
    });
    return vehicle.id!;
  }

  Future<int> updateVehicleStatus(int id, String status, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.update('vehicles', {
        'status': status,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Vehicle not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_vehicle_status',
        detail: 'Vehicle status changed to $status',
        entityType: 'vehicles',
        entityId: id,
        userId: userId,
      );
    });
    return id;
  }

  // ============ Routes ============

  Future<int> createRoute(Route route, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = route.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('routes', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_route',
        detail: 'Created route ${route.name}',
        entityType: 'routes',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<Route?> getRoute(int id) async {
    final maps = await db.query('routes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Route.fromMap(maps.first);
  }

  Future<List<Route>> getRoutes({bool activeOnly = true}) async {
    final where = activeOnly ? 'is_active = 1' : null;
    final maps = await db.query('routes', where: where, orderBy: 'name');
    return maps.map((m) => Route.fromMap(m)).toList();
  }

  Future<int> updateRoute(Route route, {int? userId}) async {
    final map = route.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final count = await txn.update('routes', map, where: 'id = ?', whereArgs: [route.id]);
      if (count == 0) throw StateError('Route not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_route',
        detail: 'Updated route ${route.name}',
        entityType: 'routes',
        entityId: route.id,
        userId: userId,
      );
    });
    return route.id!;
  }

  // ============ Route Stops ============

  Future<int> addRouteStop(RouteStop stop, {int? userId}) async {
    return await db.transaction((txn) async {
      final id = await txn.insert('route_stops', stop.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'add_route_stop',
        detail: 'Added stop to route ${stop.routeId}',
        entityType: 'route_stops',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<RouteStop>> getRouteStops(int routeId) async {
    final maps = await db.query('route_stops', where: 'route_id = ?', whereArgs: [routeId], orderBy: 'stop_order');
    return maps.map((m) => RouteStop.fromMap(m)).toList();
  }

  // ============ Shipments ============

  Future<int> createShipment(Shipment shipment, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = shipment.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('shipments', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_shipment',
        detail: 'Created shipment ${shipment.shipmentNumber}',
        entityType: 'shipments',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<Shipment?> getShipment(int id) async {
    final maps = await db.query('shipments', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Shipment.fromMap(maps.first);
  }

  Future<Shipment?> getShipmentByNumber(String shipmentNumber) async {
    final maps = await db.query('shipments', where: 'shipment_number = ?', whereArgs: [shipmentNumber]);
    if (maps.isEmpty) return null;
    return Shipment.fromMap(maps.first);
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
    final where = <String>[];
    final args = <dynamic>[];
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    if (carrierId != null) {
      where.add('carrier_id = ?');
      args.add(carrierId);
    }
    if (vehicleId != null) {
      where.add('vehicle_id = ?');
      args.add(vehicleId);
    }
    if (fromDate != null) {
      where.add('shipment_date >= ?');
      args.add(fromDate);
    }
    if (toDate != null) {
      where.add('shipment_date <= ?');
      args.add(toDate);
    }
    final maps = await db.query(
      'shipments',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'shipment_date DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => Shipment.fromMap(m)).toList();
  }

  Future<int> updateShipment(Shipment shipment, {int? userId}) async {
    final map = shipment.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final count = await txn.update('shipments', map, where: 'id = ?', whereArgs: [shipment.id]);
      if (count == 0) throw StateError('Shipment not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_shipment',
        detail: 'Updated shipment ${shipment.shipmentNumber}',
        entityType: 'shipments',
        entityId: shipment.id,
        userId: userId,
      );
    });
    return shipment.id!;
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
    await db.transaction((txn) async {
      final count = await txn.update('shipments', map, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Shipment not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_shipment_status',
        detail: 'Shipment status changed to $status',
        entityType: 'shipments',
        entityId: id,
        userId: userId,
      );
    });
    return id;
  }

  // ============ Shipment Items ============

  Future<int> addShipmentItem(ShipmentItem item, {int? userId}) async {
    return await db.transaction((txn) async {
      final id = await txn.insert('shipment_items', item.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'add_shipment_item',
        detail: 'Added item to shipment ${item.shipmentId}',
        entityType: 'shipment_items',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<ShipmentItem>> getShipmentItems(int shipmentId) async {
    final maps = await db.query('shipment_items', where: 'shipment_id = ?', whereArgs: [shipmentId]);
    return maps.map((m) => ShipmentItem.fromMap(m)).toList();
  }

  Future<int> updateShipmentItem(ShipmentItem item, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.update('shipment_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
      if (count == 0) throw StateError('Shipment item not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_shipment_item',
        detail: 'Updated shipment item',
        entityType: 'shipment_items',
        entityId: item.id,
        userId: userId,
      );
    });
    return item.id!;
  }

  Future<int> updateShipmentItemLoadedQuantity(int itemId, double loadedQuantity, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.update('shipment_items', {
        'loaded_quantity': loadedQuantity,
      }, where: 'id = ?', whereArgs: [itemId]);
      if (count == 0) throw StateError('Shipment item not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_shipment_item_loaded',
        detail: 'Updated loaded quantity to $loadedQuantity',
        entityType: 'shipment_items',
        entityId: itemId,
        userId: userId,
      );
    });
    return itemId;
  }

  Future<int> updateShipmentItemDeliveredQuantity(int itemId, double deliveredQuantity, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.update('shipment_items', {
        'delivered_quantity': deliveredQuantity,
      }, where: 'id = ?', whereArgs: [itemId]);
      if (count == 0) throw StateError('Shipment item not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_shipment_item_delivered',
        detail: 'Updated delivered quantity to $deliveredQuantity',
        entityType: 'shipment_items',
        entityId: itemId,
        userId: userId,
      );
    });
    return itemId;
  }

  // ============ Shipment Tracking ============

  Future<int> addTrackingPoint(ShipmentTracking tracking, {int? userId}) async {
    return await db.transaction((txn) async {
      final id = await txn.insert('shipment_tracking', tracking.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'add_tracking_point',
        detail: 'Added tracking point for shipment ${tracking.shipmentId}',
        entityType: 'shipment_tracking',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<ShipmentTracking>> getShipmentTracking(int shipmentId) async {
    final maps = await db.query('shipment_tracking', where: 'shipment_id = ?', whereArgs: [shipmentId], orderBy: 'timestamp');
    return maps.map((m) => ShipmentTracking.fromMap(m)).toList();
  }

  Future<ShipmentTracking?> getLatestTracking(int shipmentId) async {
    final maps = await db.query(
      'shipment_tracking',
      where: 'shipment_id = ?',
      whereArgs: [shipmentId],
      orderBy: 'timestamp DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return ShipmentTracking.fromMap(maps.first);
  }

  // ============ Load Plans ============

  Future<int> createLoadPlan(LoadPlan plan, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = plan.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('load_plans', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_load_plan',
        detail: 'Created load plan for shipment ${plan.shipmentId}',
        entityType: 'load_plans',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<LoadPlan?> getLoadPlan(int id) async {
    final maps = await db.query('load_plans', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return LoadPlan.fromMap(maps.first);
  }

  Future<LoadPlan?> getLoadPlanByShipment(int shipmentId) async {
    final maps = await db.query('load_plans', where: 'shipment_id = ?', whereArgs: [shipmentId], limit: 1);
    if (maps.isEmpty) return null;
    return LoadPlan.fromMap(maps.first);
  }

  Future<List<LoadPlan>> getLoadPlans({String? status, int? vehicleId}) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    if (vehicleId != null) {
      where.add('vehicle_id = ?');
      args.add(vehicleId);
    }
    final maps = await db.query('load_plans', where: where.isEmpty ? null : where.join(' AND '), whereArgs: args, orderBy: 'plan_date DESC');
    return maps.map((m) => LoadPlan.fromMap(m)).toList();
  }

  Future<int> updateLoadPlan(LoadPlan plan, {int? userId}) async {
    final map = plan.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final count = await txn.update('load_plans', map, where: 'id = ?', whereArgs: [plan.id]);
      if (count == 0) throw StateError('Load plan not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_load_plan',
        detail: 'Updated load plan',
        entityType: 'load_plans',
        entityId: plan.id,
        userId: userId,
      );
    });
    return plan.id!;
  }

  // ============ Load Plan Items ============

  Future<int> addLoadPlanItem(LoadPlanItem item, {int? userId}) async {
    return await db.transaction((txn) async {
      final id = await txn.insert('load_plan_items', item.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'add_load_plan_item',
        detail: 'Added item to load plan ${item.loadPlanId}',
        entityType: 'load_plan_items',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<LoadPlanItem>> getLoadPlanItems(int loadPlanId) async {
    final maps = await db.query('load_plan_items', where: 'load_plan_id = ?', whereArgs: [loadPlanId], orderBy: 'load_order');
    return maps.map((m) => LoadPlanItem.fromMap(m)).toList();
  }

  Future<int> updateLoadPlanItemStatus(int itemId, String status, {double? loadedQuantity, int? loadedAt, int? loadedBy, int? userId}) async {
    final Map<String, dynamic> map = {'status': status};
    if (loadedQuantity != null) map['loaded_quantity'] = loadedQuantity;
    if (loadedAt != null) map['loaded_at'] = loadedAt;
    if (loadedBy != null) map['loaded_by'] = loadedBy;
    await db.transaction((txn) async {
      final count = await txn.update('load_plan_items', map, where: 'id = ?', whereArgs: [itemId]);
      if (count == 0) throw StateError('Load plan item not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_load_plan_item_status',
        detail: 'Load plan item status changed to $status',
        entityType: 'load_plan_items',
        entityId: itemId,
        userId: userId,
      );
    });
    return itemId;
  }

  // ============ Freight Rates ============

  Future<int> createFreightRate(FreightRate rate, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = rate.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('freight_rates', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_freight_rate',
        detail: 'Created freight rate for route ${rate.routeId}',
        entityType: 'freight_rates',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<FreightRate>> getFreightRates({
    int? routeId,
    int? carrierId,
    String? vehicleType,
    int? effectiveDate,
  }) async {
    final where = <String>[];
    final args = <dynamic>[];
    where.add('is_active = 1');
    if (routeId != null) {
      where.add('route_id = ?');
      args.add(routeId);
    }
    if (carrierId != null) {
      where.add('carrier_id = ?');
      args.add(carrierId);
    }
    if (vehicleType != null) {
      where.add('vehicle_type = ?');
      args.add(vehicleType);
    }
    if (effectiveDate != null) {
      where.add('effective_from <= ?');
      args.add(effectiveDate);
      where.add('(effective_to IS NULL OR effective_to >= ?)');
      args.add(effectiveDate);
    }
    final maps = await db.query('freight_rates', where: where.join(' AND '), whereArgs: args);
    return maps.map((m) => FreightRate.fromMap(m)).toList();
  }

  Future<FreightRate?> getBestFreightRate(int routeId, String vehicleType, int date) async {
    final rates = await getFreightRates(routeId: routeId, vehicleType: vehicleType, effectiveDate: date);
    if (rates.isEmpty) return null;
    rates.sort((a, b) => a.baseRate.compareTo(b.baseRate));
    return rates.first;
  }

  // ============ Freight Bills ============

  Future<int> createFreightBill(FreightBill bill, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = bill.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('freight_bills', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_freight_bill',
        detail: 'Created freight bill ${bill.billNumber}',
        entityType: 'freight_bills',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<FreightBill?> getFreightBill(int id) async {
    final maps = await db.query('freight_bills', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return FreightBill.fromMap(maps.first);
  }

  Future<List<FreightBill>> getFreightBills({int? carrierId, String? status, int? fromDate, int? toDate}) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (carrierId != null) {
      where.add('carrier_id = ?');
      args.add(carrierId);
    }
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    if (fromDate != null) {
      where.add('bill_date >= ?');
      args.add(fromDate);
    }
    if (toDate != null) {
      where.add('bill_date <= ?');
      args.add(toDate);
    }
    final maps = await db.query('freight_bills', where: where.isEmpty ? null : where.join(' AND '), whereArgs: args, orderBy: 'bill_date DESC');
    return maps.map((m) => FreightBill.fromMap(m)).toList();
  }

  Future<int> updateFreightBillStatus(int id, String status, {int? verifiedBy, int? paidDate, int? userId}) async {
    final map = {'status': status, 'updated_at': DateTime.now().millisecondsSinceEpoch};
    if (verifiedBy != null) {
      map['verified_by'] = verifiedBy;
      map['verified_at'] = DateTime.now().millisecondsSinceEpoch;
    }
    if (paidDate != null) map['paid_date'] = paidDate;
    await db.transaction((txn) async {
      final count = await txn.update('freight_bills', map, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Freight bill not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_freight_bill_status',
        detail: 'Freight bill status changed to $status',
        entityType: 'freight_bills',
        entityId: id,
        userId: userId,
      );
    });
    return id;
  }

  // ============ Vehicle Maintenance ============

  Future<int> createMaintenance(VehicleMaintenance maintenance, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = maintenance.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('vehicle_maintenance', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_maintenance',
        detail: 'Created maintenance for vehicle ${maintenance.vehicleId}',
        entityType: 'vehicle_maintenance',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<VehicleMaintenance>> getVehicleMaintenance(int vehicleId, {String? status}) async {
    final where = <String>['vehicle_id = ?'];
    final args = <dynamic>[vehicleId];
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    final maps = await db.query('vehicle_maintenance', where: where.join(' AND '), whereArgs: args, orderBy: 'service_date DESC');
    return maps.map((m) => VehicleMaintenance.fromMap(m)).toList();
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

  // ============ Analytics ============
  // (Read-only methods unchanged)

  Future<Map<String, dynamic>> getShipmentSummary(int fromDate, int toDate) async {
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as total_shipments,
        SUM(CASE WHEN status = 'DELIVERED' THEN 1 ELSE 0 END) as delivered,
        SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) as cancelled,
        SUM(CASE WHEN status IN ('PLANNED', 'ASSIGNED', 'LOADED', 'IN_TRANSIT', 'ARRIVED', 'UNLOADING') THEN 1 ELSE 0 END) as in_progress,
        SUM(total_weight) as total_weight,
        SUM(total_volume) as total_volume,
        SUM(total_packages) as total_packages,
        SUM(total_freight) as total_freight
      FROM shipments
      WHERE shipment_date BETWEEN ? AND ?
    ''', [fromDate, toDate]);
    return result.isNotEmpty ? result.first : {};
  }

  Future<List<Map<String, dynamic>>> getCarrierPerformance(int fromDate, int toDate) async {
    return await db.rawQuery('''
      SELECT
        c.name as carrier_name,
        COUNT(s.id) as total_shipments,
        SUM(CASE WHEN s.status = 'DELIVERED' THEN 1 ELSE 0 END) as delivered,
        SUM(CASE WHEN s.status = 'CANCELLED' THEN 1 ELSE 0 END) as cancelled,
        AVG(CASE
          WHEN s.arrival_time IS NOT NULL AND s.departure_time IS NOT NULL
          THEN (s.arrival_time - s.departure_time) / (1000.0 * 60 * 60)
          ELSE NULL
        END) as avg_transit_hours,
        SUM(s.total_freight) as total_freight
      FROM shipments s
      JOIN carriers c ON s.carrier_id = c.id
      WHERE s.shipment_date BETWEEN ? AND ?
      GROUP BY c.id
      ORDER BY total_shipments DESC
    ''', [fromDate, toDate]);
  }

  Future<List<Map<String, dynamic>>> getVehicleUtilization(int fromDate, int toDate) async {
    return await db.rawQuery('''
      SELECT
        v.registration_number,
        v.vehicle_type,
        COUNT(s.id) as trips,
        SUM(s.total_weight) as total_weight,
        SUM(s.total_volume) as total_volume,
        AVG(s.total_weight / v.capacity_weight * 100) as avg_weight_utilization,
        AVG(s.total_volume / v.capacity_volume * 100) as avg_volume_utilization
      FROM shipments s
      JOIN vehicles v ON s.vehicle_id = v.id
      WHERE s.shipment_date BETWEEN ? AND ? AND s.status = 'DELIVERED'
      GROUP BY v.id
      ORDER BY trips DESC
    ''', [fromDate, toDate]);
  }
}