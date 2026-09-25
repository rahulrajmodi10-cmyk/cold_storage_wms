// lib/services/gatepass_barcode_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/gatepass_barcode_models.dart';

class GatepassBarcodeService {
  final Database db;

  GatepassBarcodeService(this.db);

  // ============ Gatepass Types ============

  Future<int> createGatepassType(GatepassType type) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = type.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('gatepass_types', map);
  }

  Future<List<GatepassType>> getGatepassTypes({bool activeOnly = true}) async {
    final where = activeOnly ? 'is_active = 1' : null;
    final maps = await db.query('gatepass_types', where: where, orderBy: 'code');
    return maps.map((m) => GatepassType.fromMap(m)).toList();
  }

  Future<int> updateGatepassType(GatepassType type) async {
    final map = type.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('gatepass_types', map, where: 'id = ?', whereArgs: [type.id]);
  }

  // ============ Gatepass ============

  Future<int> createGatepass(Gatepass gatepass) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = gatepass.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('gatepass', map);
  }

  Future<Gatepass?> getGatepass(int id) async {
    final maps = await db.query('gatepass', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Gatepass.fromMap(maps.first);
  }

  Future<Gatepass?> getGatepassByNumber(String gatepassNumber) async {
    final maps = await db.query('gatepass', where: 'gatepass_number = ?', whereArgs: [gatepassNumber]);
    if (maps.isEmpty) return null;
    return Gatepass.fromMap(maps.first);
  }

  Future<List<Gatepass>> getGatepasses({
    String? status,
    int? gatepassTypeId,
    int? partyId,
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
    if (gatepassTypeId != null) {
      where.add('gatepass_type_id = ?');
      args.add(gatepassTypeId);
    }
    if (partyId != null) {
      where.add('party_id = ?');
      args.add(partyId);
    }
    if (vehicleId != null) {
      where.add('vehicle_id = ?');
      args.add(vehicleId);
    }
    if (fromDate != null) {
      where.add('requested_date >= ?');
      args.add(fromDate);
    }
    if (toDate != null) {
      where.add('requested_date <= ?');
      args.add(toDate);
    }
    final maps = await db.query(
      'gatepass',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'requested_date DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => Gatepass.fromMap(m)).toList();
  }

  Future<int> updateGatepass(Gatepass gatepass) async {
    final map = gatepass.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('gatepass', map, where: 'id = ?', whereArgs: [gatepass.id]);
  }

  Future<int> updateGatepassStatus(int id, String status, {Map<String, dynamic>? extraFields}) async {
    final Map<String, dynamic> map = {
      'status': status,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    if (extraFields != null) {
      map.addAll(extraFields);
    }
    return await db.update('gatepass', map, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> submitGatepass(int id, int userId) async {
    return await updateGatepassStatus(id, 'SUBMITTED', extraFields: {
      'approved_by': userId,
      'approved_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<int> approveGatepass(int id, int userId) async {
    return await updateGatepassStatus(id, 'APPROVED', extraFields: {
      'approved_by': userId,
      'approved_at': DateTime.now().millisecondsSinceEpoch,
      'valid_from': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<int> rejectGatepass(int id, int userId, String reason) async {
    return await updateGatepassStatus(id, 'REJECTED', extraFields: {
      'approved_by': userId,
      'approved_at': DateTime.now().millisecondsSinceEpoch,
      'rejection_reason': reason,
    });
  }

  Future<int> activateGatepass(int id, int userId) async {
    return await updateGatepassStatus(id, 'ACTIVE', extraFields: {
      'actual_entry_time': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<int> completeGatepass(int id, int userId, {String? notes}) async {
    return await updateGatepassStatus(id, 'COMPLETED', extraFields: {
      'completed_by': userId,
      'completed_at': DateTime.now().millisecondsSinceEpoch,
      'actual_exit_time': DateTime.now().millisecondsSinceEpoch,
      'completion_notes': notes,
    });
  }

  // ============ Gatepass Items ============

  Future<int> addGatepassItem(GatepassItem item) async {
    return await db.insert('gatepass_items', item.toMap());
  }

  Future<List<GatepassItem>> getGatepassItems(int gatepassId) async {
    final maps = await db.query('gatepass_items', where: 'gatepass_id = ?', whereArgs: [gatepassId]);
    return maps.map((m) => GatepassItem.fromMap(m)).toList();
  }

  Future<int> updateGatepassItem(GatepassItem item) async {
    return await db.update('gatepass_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> verifyGatepassItem(int itemId, {
    required double verifiedQuantity,
    required double verifiedWeight,
    required int verifiedPackages,
    required String verificationStatus,
    String? notes,
    int? verifiedBy,
  }) async {
    return await db.update('gatepass_items', {
      'verified_quantity': verifiedQuantity,
      'verified_weight': verifiedWeight,
      'verified_packages': verifiedPackages,
      'verification_status': verificationStatus,
      'verification_notes': notes,
    }, where: 'id = ?', whereArgs: [itemId]);
  }

  // ============ Security Gates ============

  Future<int> createSecurityGate(SecurityGate gate) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = gate.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('security_gates', map);
  }

  Future<List<SecurityGate>> getSecurityGates({bool activeOnly = true}) async {
    final where = activeOnly ? 'is_active = 1' : null;
    final maps = await db.query('security_gates', where: where, orderBy: 'code');
    return maps.map((m) => SecurityGate.fromMap(m)).toList();
  }

  // ============ Gatepass Vehicle Log ============

  Future<int> logVehicleEntry(GatepassVehicleLog log) async {
    return await db.insert('gatepass_vehicle_log', log.toMap());
  }

  Future<List<GatepassVehicleLog>> getVehicleLogs(int gatepassId) async {
    final maps = await db.query('gatepass_vehicle_log', where: 'gatepass_id = ?', whereArgs: [gatepassId], orderBy: 'timestamp');
    return maps.map((m) => GatepassVehicleLog.fromMap(m)).toList();
  }

  // ============ Gatepass Approvals ============

  Future<int> createGatepassApproval(GatepassApproval approval) async {
    return await db.insert('gatepass_approvals', approval.toMap());
  }

  Future<List<GatepassApproval>> getGatepassApprovals(int gatepassId) async {
    final maps = await db.query('gatepass_approvals', where: 'gatepass_id = ?', whereArgs: [gatepassId], orderBy: 'level');
    return maps.map((m) => GatepassApproval.fromMap(m)).toList();
  }

  Future<int> processGatepassApproval(int approvalId, String status, int approverId, {String? comments, int? delegatedTo}) async {
    final map = {
      'status': status,
      'approver_id': approverId,
      'action_at': DateTime.now().millisecondsSinceEpoch,
    };
    if (comments != null) map['comments'] = comments;
    if (delegatedTo != null) map['delegated_to'] = delegatedTo;
    return await db.update('gatepass_approvals', map, where: 'id = ?', whereArgs: [approvalId]);
  }

  // ============ Dispatch Schedules ============

  Future<int> createDispatchSchedule(DispatchSchedule schedule) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = schedule.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('dispatch_schedules', map);
  }

  Future<DispatchSchedule?> getDispatchSchedule(int id) async {
    final maps = await db.query('dispatch_schedules', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return DispatchSchedule.fromMap(maps.first);
  }

  Future<List<DispatchSchedule>> getDispatchSchedules({
    int? date,
    String? status,
    int? vehicleId,
    int? gatepassId,
    int? shipmentId,
  }) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (date != null) {
      where.add('schedule_date = ?');
      args.add(date);
    }
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    if (vehicleId != null) {
      where.add('vehicle_id = ?');
      args.add(vehicleId);
    }
    if (gatepassId != null) {
      where.add('gatepass_id = ?');
      args.add(gatepassId);
    }
    if (shipmentId != null) {
      where.add('shipment_id = ?');
      args.add(shipmentId);
    }
    final maps = await db.query('dispatch_schedules', where: where.isEmpty ? null : where.join(' AND '), whereArgs: args, orderBy: 'scheduled_start');
    return maps.map((m) => DispatchSchedule.fromMap(m)).toList();
  }

  Future<int> updateDispatchSchedule(DispatchSchedule schedule) async {
    final map = schedule.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('dispatch_schedules', map, where: 'id = ?', whereArgs: [schedule.id]);
  }

  Future<int> startDispatchSchedule(int id) async {
    return await db.update('dispatch_schedules', {
      'status': 'IN_PROGRESS',
      'actual_start': DateTime.now().millisecondsSinceEpoch,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> completeDispatchSchedule(int id) async {
    return await db.update('dispatch_schedules', {
      'status': 'COMPLETED',
      'actual_end': DateTime.now().millisecondsSinceEpoch,
    }, where: 'id = ?', whereArgs: [id]);
  }

  // ============ Loading Bays ============

  Future<int> createLoadingBay(LoadingBay bay) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = bay.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('loading_bays', map);
  }

  Future<List<LoadingBay>> getLoadingBays({bool activeOnly = true}) async {
    final where = activeOnly ? 'is_active = 1' : null;
    final maps = await db.query('loading_bays', where: where, orderBy: 'code');
    return maps.map((m) => LoadingBay.fromMap(m)).toList();
  }

  // ============ QR Code Generation ============

  String generateGatepassQR(Gatepass gatepass) {
    final data = {
      'type': 'GATEPASS',
      'number': gatepass.gatepassNumber,
      'id': gatepass.id,
      'status': gatepass.status,
      'vehicle': gatepass.vehicleNumber,
      'driver': gatepass.driverName,
      'valid_from': gatepass.validFrom,
      'valid_to': gatepass.validTo,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(data);
  }

  String generateItemQR(Barcode barcode) {
    final data = {
      'type': barcode.entityType,
      'id': barcode.entityId,
      'value': barcode.barcodeValue,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    return jsonEncode(data);
  }

  // ============ Barcode Definitions ============

  Future<int> createBarcodeDefinition(BarcodeDefinition def) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = def.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('barcode_definitions', map);
  }

  Future<List<BarcodeDefinition>> getBarcodeDefinitions({bool activeOnly = true}) async {
    final where = activeOnly ? 'is_active = 1' : null;
    final maps = await db.query('barcode_definitions', where: where, orderBy: 'code');
    return maps.map((m) => BarcodeDefinition.fromMap(m)).toList();
  }

  Future<BarcodeDefinition?> getBarcodeDefinitionByCode(String code) async {
    final maps = await db.query('barcode_definitions', where: 'code = ?', whereArgs: [code], limit: 1);
    if (maps.isEmpty) return null;
    return BarcodeDefinition.fromMap(maps.first);
  }

  // ============ Barcodes ============

  Future<int> createBarcode(Barcode barcode) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = barcode.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('barcodes', map);
  }

  Future<Barcode?> getBarcodeByValue(String value) async {
    final maps = await db.query('barcodes', where: 'barcode_value = ?', whereArgs: [value], limit: 1);
    if (maps.isEmpty) return null;
    return Barcode.fromMap(maps.first);
  }

  Future<Barcode?> getBarcodeByEntity(String entityType, int entityId) async {
    final maps = await db.query(
      'barcodes',
      where: 'entity_type = ? AND entity_id = ? AND status = ?',
      whereArgs: [entityType, entityId, 'ACTIVE'],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Barcode.fromMap(maps.first);
  }

  Future<int> updateBarcodePrintCount(int barcodeId) async {
    return await db.rawUpdate('''
      UPDATE barcodes
      SET print_count = print_count + 1,
          last_printed_at = ?,
          updated_at = ?
      WHERE id = ?
    ''', [DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch, barcodeId]);
  }

  Future<void> voidBarcode(int barcodeId) async {
    await db.update('barcodes', {'status': 'VOIDED', 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [barcodeId]);
  }

  // ============ Barcode Scans ============

  Future<int> logBarcodeScan(BarcodeScan scan) async {
    return await db.insert('barcode_scans', scan.toMap());
  }

  Future<List<BarcodeScan>> getBarcodeScans({
    int? sessionId,
    String? barcodeValue,
    int? entityId,
    String? entityType,
    int? fromDate,
    int? toDate,
  }) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (sessionId != null) {
      where.add('scan_session_id = ?');
      args.add(sessionId);
    }
    if (barcodeValue != null) {
      where.add('barcode_value = ?');
      args.add(barcodeValue);
    }
    if (entityId != null) {
      where.add('entity_id = ?');
      args.add(entityId);
    }
    if (entityType != null) {
      where.add('entity_type = ?');
      args.add(entityType);
    }
    if (fromDate != null) {
      where.add('timestamp >= ?');
      args.add(fromDate);
    }
    if (toDate != null) {
      where.add('timestamp <= ?');
      args.add(toDate);
    }
    final maps = await db.query('barcode_scans', where: where.isEmpty ? null : where.join(' AND '), whereArgs: args, orderBy: 'timestamp DESC');
    return maps.map((m) => BarcodeScan.fromMap(m)).toList();
  }

  // ============ Batch Scan Sessions ============

  Future<int> createBatchScanSession(BatchScanSession session) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = session.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('batch_scan_sessions', map);
  }

  Future<BatchScanSession?> getBatchScanSession(int id) async {
    final maps = await db.query('batch_scan_sessions', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return BatchScanSession.fromMap(maps.first);
  }

  Future<List<BatchScanSession>> getBatchScanSessions({
    String? sessionType,
    int? referenceId,
    String? status,
    int? fromDate,
    int? toDate,
  }) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (sessionType != null) {
      where.add('session_type = ?');
      args.add(sessionType);
    }
    if (referenceId != null) {
      where.add('reference_id = ?');
      args.add(referenceId);
    }
    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    if (fromDate != null) {
      where.add('started_at >= ?');
      args.add(fromDate);
    }
    if (toDate != null) {
      where.add('started_at <= ?');
      args.add(toDate);
    }
    final maps = await db.query('batch_scan_sessions', where: where.isEmpty ? null : where.join(' AND '), whereArgs: args, orderBy: 'started_at DESC');
    return maps.map((m) => BatchScanSession.fromMap(m)).toList();
  }

  Future<int> updateBatchScanSession(BatchScanSession session) async {
    final map = session.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('batch_scan_sessions', map, where: 'id = ?', whereArgs: [session.id]);
  }

  Future<int> addBatchScanItem(BatchScanItem item) async {
    return await db.insert('batch_scan_items', item.toMap());
  }

  Future<List<BatchScanItem>> getBatchScanItems(int sessionId) async {
    final maps = await db.query('batch_scan_items', where: 'session_id = ?', whereArgs: [sessionId]);
    return maps.map((m) => BatchScanItem.fromMap(m)).toList();
  }

  Future<int> updateBatchScanItem(BatchScanItem item) async {
    return await db.update('batch_scan_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  // ============ Label Print Jobs ============

  Future<int> createLabelPrintJob(LabelPrintJob job) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = job.toMap();
    map['requested_at'] = now;
    return await db.insert('label_print_jobs', map);
  }

  Future<LabelPrintJob?> getLabelPrintJob(int id) async {
    final maps = await db.query('label_print_jobs', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return LabelPrintJob.fromMap(maps.first);
  }

  Future<List<LabelPrintJob>> getLabelPrintJobs({String? status}) async {
    final where = status != null ? 'status = ?' : null;
    final args = status != null ? [status] : null;
    final maps = await db.query('label_print_jobs', where: where, whereArgs: args, orderBy: 'requested_at DESC');
    return maps.map((m) => LabelPrintJob.fromMap(m)).toList();
  }

  Future<int> updateLabelPrintJobStatus(int id, String status, {int? printedCount, int? failedCount, String? errorLog}) async {
    final map = {'status': status, 'updated_at': DateTime.now().millisecondsSinceEpoch};
    if (printedCount != null) map['printed_count'] = printedCount;
    if (failedCount != null) map['failed_count'] = failedCount;
    if (errorLog != null) map['error_log'] = errorLog;
    if (status == 'PRINTING') map['started_at'] = DateTime.now().millisecondsSinceEpoch;
    if (status == 'COMPLETED' || status == 'FAILED' || status == 'CANCELLED') map['completed_at'] = DateTime.now().millisecondsSinceEpoch;
    return await db.update('label_print_jobs', map, where: 'id = ?', whereArgs: [id]);
  }

  // ============ Printer Configs ============

  Future<int> createPrinterConfig(PrinterConfig config) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = config.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.insert('printer_configs', map);
  }

  Future<List<PrinterConfig>> getPrinterConfigs({bool activeOnly = true}) async {
    final where = activeOnly ? 'is_active = 1' : null;
    final maps = await db.query('printer_configs', where: where, orderBy: 'name');
    return maps.map((m) => PrinterConfig.fromMap(m)).toList();
  }

  Future<PrinterConfig?> getDefaultPrinter() async {
    final maps = await db.query('printer_configs', where: 'is_default = 1 AND is_active = 1', limit: 1);
    if (maps.isEmpty) return null;
    return PrinterConfig.fromMap(maps.first);
  }

  // ============ Analytics ============

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