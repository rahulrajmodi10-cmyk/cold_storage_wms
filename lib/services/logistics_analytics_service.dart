// lib/services/logistics_analytics_service.dart

import 'package:sqflite/sqflite.dart';

class LogisticsAnalyticsService {
  final Database db;

  LogisticsAnalyticsService(this.db);

  // ============ Analytics (Read-only methods) ============

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