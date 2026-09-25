// lib/services/logistics_service.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/logistics_models.dart';

class LogisticsService {
  final Database db;

  LogisticsService(this.db);

  // ============ Carriers ============

  Future<int> createCarrier(Carrier carrier) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = carrier.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('carriers', map);
  }

  Future<Carrier?> getCarrier(int id) async {
    final maps = await db.query('carriers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Carrier.fromMap(maps.first);
  }

  Future<List<Carrier>> getCarriers({bool activeOnly = true}) async {
    final where = activeOnly ? 'is_active = 1' : null;
    final maps = await db.query('carriers', where: where, orderBy: 'name');
    return maps.map((m) => Carrier.fromMap(m)).toList();
  }

  Future<int> updateCarrier(Carrier carrier) async {
    final map = carrier.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('carriers', map, where: 'id = ?', whereArgs: [carrier.id]);
  }

  // ============ Vehicles ============

  Future<int> createVehicle(Vehicle vehicle) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = vehicle.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('vehicles', map);
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

  Future<int> updateVehicle(Vehicle vehicle) async {
    final map = vehicle.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('vehicles', map, where: 'id = ?', whereArgs: [vehicle.id]);
  }

  Future<int> updateVehicleStatus(int id, String status) async {
    return await db.update('vehicles', {
      'status': status,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, where: 'id = ?', whereArgs: [id]);
  }

  // ============ Routes ============

  Future<int> createRoute(Route route) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = route.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('routes', map);
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

  Future<int> updateRoute(Route route) async {
    final map = route.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('routes', map, where: 'id = ?', whereArgs: [route.id]);
  }

  // ============ Route Stops ============

  Future<int> addRouteStop(RouteStop stop) async {
    return await db.insert('route_stops', stop.toMap());
  }

  Future<List<RouteStop>> getRouteStops(int routeId) async {
    final maps = await db.query('route_stops', where: 'route_id = ?', whereArgs: [routeId], orderBy: 'stop_order');
    return maps.map((m) => RouteStop.fromMap(m)).toList();
  }

  // ============ Shipments ============

  Future<int> createShipment(Shipment shipment) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = shipment.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('shipments', map);
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

  Future<int> updateShipment(Shipment shipment) async {
    final map = shipment.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('shipments', map, where: 'id = ?', whereArgs: [shipment.id]);
  }

  Future<int> updateShipmentStatus(int id, String status, {int? timestamp, Map<String, dynamic>? extraFields}) async {
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
    return await db.update('shipments', map, where: 'id = ?', whereArgs: [id]);
  }

  // ============ Shipment Items ============

  Future<int> addShipmentItem(ShipmentItem item) async {
    return await db.insert('shipment_items', item.toMap());
  }

  Future<List<ShipmentItem>> getShipmentItems(int shipmentId) async {
    final maps = await db.query('shipment_items', where: 'shipment_id = ?', whereArgs: [shipmentId]);
    return maps.map((m) => ShipmentItem.fromMap(m)).toList();
  }

  Future<int> updateShipmentItem(ShipmentItem item) async {
    return await db.update('shipment_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> updateShipmentItemLoadedQuantity(int itemId, double loadedQuantity) async {
    return await db.update('shipment_items', {
      'loaded_quantity': loadedQuantity,
    }, where: 'id = ?', whereArgs: [itemId]);
  }

  Future<int> updateShipmentItemDeliveredQuantity(int itemId, double deliveredQuantity) async {
    return await db.update('shipment_items', {
      'delivered_quantity': deliveredQuantity,
    }, where: 'id = ?', whereArgs: [itemId]);
  }

  // ============ Shipment Tracking ============

  Future<int> addTrackingPoint(ShipmentTracking tracking) async {
    return await db.insert('shipment_tracking', tracking.toMap());
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

  Future<int> createLoadPlan(LoadPlan plan) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = plan.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('load_plans', map);
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

  Future<int> updateLoadPlan(LoadPlan plan) async {
    final map = plan.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('load_plans', map, where: 'id = ?', whereArgs: [plan.id]);
  }

  // ============ Load Plan Items ============

  Future<int> addLoadPlanItem(LoadPlanItem item) async {
    return await db.insert('load_plan_items', item.toMap());
  }

  Future<List<LoadPlanItem>> getLoadPlanItems(int loadPlanId) async {
    final maps = await db.query('load_plan_items', where: 'load_plan_id = ?', whereArgs: [loadPlanId], orderBy: 'load_order');
    return maps.map((m) => LoadPlanItem.fromMap(m)).toList();
  }

  Future<int> updateLoadPlanItemStatus(int itemId, String status, {double? loadedQuantity, int? loadedAt, int? loadedBy}) async {
    final Map<String, dynamic> map = {'status': status};
    if (loadedQuantity != null) map['loaded_quantity'] = loadedQuantity;
    if (loadedAt != null) map['loaded_at'] = loadedAt;
    if (loadedBy != null) map['loaded_by'] = loadedBy;
    return await db.update('load_plan_items', map, where: 'id = ?', whereArgs: [itemId]);
  }

  // ============ Freight Rates ============

  Future<int> createFreightRate(FreightRate rate) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = rate.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('freight_rates', map);
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
    // Return rate with lowest base rate
    rates.sort((a, b) => a.baseRate.compareTo(b.baseRate));
    return rates.first;
  }

  // ============ Freight Bills ============

  Future<int> createFreightBill(FreightBill bill) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = bill.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('freight_bills', map);
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

  Future<int> updateFreightBillStatus(int id, String status, {int? verifiedBy, int? paidDate}) async {
    final map = {'status': status, 'updated_at': DateTime.now().millisecondsSinceEpoch};
    if (verifiedBy != null) {
      map['verified_by'] = verifiedBy;
      map['verified_at'] = DateTime.now().millisecondsSinceEpoch;
    }
    if (paidDate != null) map['paid_date'] = paidDate;
    return await db.update('freight_bills', map, where: 'id = ?', whereArgs: [id]);
  }

  // ============ Vehicle Maintenance ============

  Future<int> createMaintenance(VehicleMaintenance maintenance) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = maintenance.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('vehicle_maintenance', map);
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