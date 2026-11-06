// lib/services/gatepass_analytics_service.dart

import 'package:sqflite/sqflite.dart';

class GatepassAnalyticsService {
  final Database db;

  GatepassAnalyticsService(this.db);

  // ============ Analytics (Read-only methods) ============

  Future<Map<String, dynamic>> getGatepassSummary(int fromDate, int toDate) async {
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as total_gatepasses,
        SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) as active,
        SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) as cancelled,
        SUM(CASE WHEN status = 'REJECTED' THEN 1 ELSE 0 END) as rejected,
        SUM(total_quantity) as total_quantity,
        SUM(total_weight) as total_weight,
        SUM(total_packages) as total_packages
      FROM gatepass
      WHERE requested_date BETWEEN ? AND ?
    ''', [fromDate, toDate]);
    return result.isNotEmpty ? result.first : {};
  }

  Future<List<Map<String, dynamic>>> getGatepassByType(int fromDate, int toDate) async {
    return await db.rawQuery('''
      SELECT
        gt.name as type_name,
        gt.code as type_code,
        COUNT(g.id) as count,
        SUM(g.total_quantity) as total_quantity,
        SUM(g.total_weight) as total_weight
      FROM gatepass g
      JOIN gatepass_types gt ON g.gatepass_type_id = gt.id
      WHERE g.requested_date BETWEEN ? AND ?
      GROUP BY gt.id
      ORDER BY count DESC
    ''', [fromDate, toDate]);
  }

  Future<List<Map<String, dynamic>>> getBarcodeScanSummary(int fromDate, int toDate) async {
    return await db.rawQuery('''
      SELECT
        scan_type,
        COUNT(*) as total_scans,
        SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) as successful,
        SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END) as failed,
        SUM(CASE WHEN status = 'MISMATCH' THEN 1 ELSE 0 END) as mismatched,
        SUM(CASE WHEN status = 'DUPLICATE' THEN 1 ELSE 0 END) as duplicate
      FROM barcode_scans
      WHERE timestamp BETWEEN ? AND ?
      GROUP BY scan_type
      ORDER BY total_scans DESC
    ''', [fromDate, toDate]);
  }
}