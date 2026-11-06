// lib/services/gatepass_barcode_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'audit_service.dart';

class GatepassBarcodeService {
  final Database db;
  final AuditService auditService;

  GatepassBarcodeService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db);

  // ============ Gatepass Types ============

  Future<int> createGatepassType(GatepassType type, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = type.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('gatepass_types', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_gatepass_type',
        detail: 'Created gatepass type ${type.code} - ${type.name}',
        entityType: 'gatepass_types',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<GatepassType>> getGatepassTypes({bool activeOnly = true}) async {
    return _getGatepassTypes(activeOnly: activeOnly);
  }

  Future<List<GatepassType>> _getGatepassTypes({bool activeOnly = true}) async {
    final where = activeOnly ? 'is_active = 1' : null;
    final maps = await db.query('gatepass_types', where: where, orderBy: 'code');
    return maps.map((m) => GatepassType.fromMap(m)).toList();
  }

  Future<int> updateGatepassType(GatepassType type, {int? userId}) async {
    final map = type.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final count = await txn.update('gatepass_types', map, where: 'id = ?', whereArgs: [type.id]);
      if (count == 0) throw StateError('Gatepass type not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_gatepass_type',
        detail: 'Updated gatepass type ${type.code}',
        entityType: 'gatepass_types',
        entityId: type.id,
        userId: userId,
      );
    });
    return type.id!;
  }

  // ============ Gatepass ============

  Future<int> createGatepass(Gatepass gatepass, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = gatepass.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('gatepass', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_gatepass',
        detail: 'Created gatepass ${gatepass.gatepassNumber}',
        entityType: 'gatepass',
        entityId: id,
        userId: userId,
      );
      return id;
    });
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

  Future<int> updateGatepass(Gatepass gatepass, {int? userId}) async {
    final map = gatepass.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final count = await txn.update('gatepass', map, where: 'id = ?', whereArgs: [gatepass.id]);
      if (count == 0) throw StateError('Gatepass not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_gatepass',
        detail: 'Updated gatepass ${gatepass.gatepassNumber}',
        entityType: 'gatepass',
        entityId: gatepass.id,
        userId: userId,
      );
    });
    return gatepass.id!;
  }

  Future<int> updateGatepassStatus(int id, String status, {Map<String, dynamic>? extraFields, int? userId}) async {
    final Map<String, dynamic> map = {
      'status': status,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    if (extraFields != null) {
      map.addAll(extraFields);
    }
    await db.transaction((txn) async {
      final count = await txn.update('gatepass', map, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Gatepass not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_gatepass_status',
        detail: 'Gatepass status changed to $status',
        entityType: 'gatepass',
        entityId: id,
        userId: userId,
      );
    });
    return id;
  }

  Future<int> submitGatepass(int id, int userId) async {
    return await updateGatepassStatus(id, 'SUBMITTED', extraFields: {
      'approved_by': userId,
      'approved_at': DateTime.now().millisecondsSinceEpoch,
    }, userId: userId);
  }

  Future<int> approveGatepass(int id, int userId) async {
    return await updateGatepassStatus(id, 'APPROVED', extraFields: {
      'approved_by': userId,
      'approved_at': DateTime.now().millisecondsSinceEpoch,
      'valid_from': DateTime.now().millisecondsSinceEpoch,
    }, userId: userId);
  }

  Future<int> rejectGatepass(int id, int userId, String reason) async {
    return await updateGatepassStatus(id, 'REJECTED', extraFields: {
      'approved_by': userId,
      'approved_at': DateTime.now().millisecondsSinceEpoch,
      'rejection_reason': reason,
    }, userId: userId);
  }

  Future<int> activateGatepass(int id, int userId) async {
    return await updateGatepassStatus(id, 'ACTIVE', extraFields: {
      'actual_entry_time': DateTime.now().millisecondsSinceEpoch,
    }, userId: userId);
  }

  Future<int> completeGatepass(int id, int userId, {String? notes}) async {
    return await updateGatepassStatus(id, 'COMPLETED', extraFields: {
      'completed_by': userId,
      'completed_at': DateTime.now().millisecondsSinceEpoch,
      'actual_exit_time': DateTime.now().millisecondsSinceEpoch,
      'completion_notes': notes,
    }, userId: userId);
  }

  // ============ Gatepass Items ============

  Future<int> addGatepassItem(GatepassItem item, {int? userId}) async {
    return await db.transaction((txn) async {
      final id = await txn.insert('gatepass_items', item.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'add_gatepass_item',
        detail: 'Added item to gatepass ${item.gatepassId}',
        entityType: 'gatepass_items',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<GatepassItem>> getGatepassItems(int gatepassId) async {
    final maps = await db.query('gatepass_items', where: 'gatepass_id = ?', whereArgs: [gatepassId]);
    return maps.map((m) => GatepassItem.fromMap(m)).toList();
  }

  Future<int> updateGatepassItem(GatepassItem item, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.update('gatepass_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
      if (count == 0) throw StateError('Gatepass item not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_gatepass_item',
        detail: 'Updated gatepass item',
        entityType: 'gatepass_items',
        entityId: item.id,
        userId: userId,
      );
    });
    return item.id!;
  }

  Future<int> verifyGatepassItem(int itemId, {
    required double verifiedQuantity,
    required double verifiedWeight,
    required int verifiedPackages,
    required String verificationStatus,
    String? notes,
    int? verifiedBy,
  }) async {
    await db.transaction((txn) async {
      final count = await txn.update('gatepass_items', {
        'verified_quantity': verifiedQuantity,
        'verified_weight': verifiedWeight,
        'verified_packages': verifiedPackages,
        'verification_status': verificationStatus,
        'verification_notes': notes,
      }, where: 'id = ?', whereArgs: [itemId]);
      if (count == 0) throw StateError('Gatepass item not found');
      await auditService.logInTransaction(
        txn,
        action: 'verify_gatepass_item',
        detail: 'Verified item with status $verificationStatus',
        entityType: 'gatepass_items',
        entityId: itemId,
        userId: verifiedBy,
      );
    });
    return itemId;
  }

  // ============ Security Gates ============

  Future<int> createSecurityGate(SecurityGate gate, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = gate.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('security_gates', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_security_gate',
        detail: 'Created security gate ${gate.code}',
        entityType: 'security_gates',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<SecurityGate>> getSecurityGates({bool activeOnly = true}) async {
    final where = activeOnly ? 'is_active = 1' : null;
    final maps = await db.query('security_gates', where: where, orderBy: 'code');
    return maps.map((m) => SecurityGate.fromMap(m)).toList();
  }

  // ============ Gatepass Vehicle Log ============

  Future<int> logVehicleEntry(GatepassVehicleLog log, {int? userId}) async {
    return await db.transaction((txn) async {
      final id = await txn.insert('gatepass_vehicle_log', log.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'log_vehicle_entry',
        detail: 'Logged vehicle entry for gatepass ${log.gatepassId}',
        entityType: 'gatepass_vehicle_log',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<GatepassVehicleLog>> getVehicleLogs(int gatepassId) async {
    final maps = await db.query('gatepass_vehicle_log', where: 'gatepass_id = ?', whereArgs: [gatepassId], orderBy: 'timestamp');
    return maps.map((m) => GatepassVehicleLog.fromMap(m)).toList();
  }

  // ============ Gatepass Approvals ============

  Future<int> createGatepassApproval(GatepassApproval approval, {int? userId}) async {
    return await db.transaction((txn) async {
      final id = await txn.insert('gatepass_approvals', approval.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'create_gatepass_approval',
        detail: 'Created approval for gatepass ${approval.gatepassId}',
        entityType: 'gatepass_approvals',
        entityId: id,
        userId: userId,
      );
      return id;
    });
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
    await db.transaction((txn) async {
      final count = await txn.update('gatepass_approvals', map, where: 'id = ?', whereArgs: [approvalId]);
      if (count == 0) throw StateError('Gatepass approval not found');
      await auditService.logInTransaction(
        txn,
        action: 'process_gatepass_approval',
        detail: 'Approval processed with status $status',
        entityType: 'gatepass_approvals',
        entityId: approvalId,
        userId: approverId,
      );
    });
    return approvalId;
  }

  // ============ Dispatch Schedules ============

  Future<int> createDispatchSchedule(DispatchSchedule schedule, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = schedule.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('dispatch_schedules', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_dispatch_schedule',
        detail: 'Created dispatch schedule',
        entityType: 'dispatch_schedules',
        entityId: id,
        userId: userId,
      );
      return id;
    });
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
    return _getDispatchSchedules(
      date: date,
      status: status,
      vehicleId: vehicleId,
      gatepassId: gatepassId,
      shipmentId: shipmentId,
    );
  }

  Future<List<DispatchSchedule>> _getDispatchSchedules({
    int? date,
    String? status,
    int? vehicleId,
    int? gatepassId,
    int? shipmentId,
  }) async {
    final where = <String>[];
    final args = <dynamic>[];
    if (date != null) {
      where.add('scheduled_start = ?');
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

  Future<int> updateDispatchSchedule(DispatchSchedule schedule, {int? userId}) async {
    final map = schedule.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final count = await txn.update('dispatch_schedules', map, where: 'id = ?', whereArgs: [schedule.id]);
      if (count == 0) throw StateError('Dispatch schedule not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_dispatch_schedule',
        detail: 'Updated dispatch schedule',
        entityType: 'dispatch_schedules',
        entityId: schedule.id,
        userId: userId,
      );
    });
    return schedule.id!;
  }

  Future<int> startDispatchSchedule(int id, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.update('dispatch_schedules', {
        'status': 'IN_PROGRESS',
        'actual_start': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Dispatch schedule not found');
      await auditService.logInTransaction(
        txn,
        action: 'start_dispatch_schedule',
        detail: 'Dispatch schedule started',
        entityType: 'dispatch_schedules',
        entityId: id,
        userId: userId,
      );
    });
    return id;
  }

  Future<int> completeDispatchSchedule(int id, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.update('dispatch_schedules', {
        'status': 'COMPLETED',
        'actual_end': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Dispatch schedule not found');
      await auditService.logInTransaction(
        txn,
        action: 'complete_dispatch_schedule',
        detail: 'Dispatch schedule completed',
        entityType: 'dispatch_schedules',
        entityId: id,
        userId: userId,
      );
    });
    return id;
  }

  // ============ Loading Bays ============

  Future<int> createLoadingBay(LoadingBay bay, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = bay.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('loading_bays', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_loading_bay',
        detail: 'Created loading bay ${bay.code}',
        entityType: 'loading_bays',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<LoadingBay>> getLoadingBays({bool activeOnly = true}) async {
    return _getLoadingBays(activeOnly: activeOnly);
  }

  Future<List<LoadingBay>> _getLoadingBays({bool activeOnly = true}) async {
    final where = activeOnly ? 'is_active = 1' : null;
    final maps = await db.query('loading_bays', where: where, orderBy: 'code');
    return maps.map((m) => LoadingBay.fromMap(m)).toList();
  }

  // ============ QR Code Generation ============
  // (Unchanged - read-only)

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

  Future<int> createBarcodeDefinition(BarcodeDefinition def, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = def.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('barcode_definitions', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_barcode_definition',
        detail: 'Created barcode definition ${def.code}',
        entityType: 'barcode_definitions',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<BarcodeDefinition>> getBarcodeDefinitions({bool activeOnly = true}) async {
    return _getBarcodeDefinitions(activeOnly: activeOnly);
  }

  Future<List<BarcodeDefinition>> _getBarcodeDefinitions({bool activeOnly = true}) async {
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

  Future<int> createBarcode(Barcode barcode, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = barcode.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('barcodes', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_barcode',
        detail: 'Created barcode ${barcode.barcodeValue}',
        entityType: 'barcodes',
        entityId: id,
        userId: userId,
      );
      return id;
    });
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

  Future<int> updateBarcodePrintCount(int barcodeId, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.rawUpdate('''
        UPDATE barcodes
        SET print_count = print_count + 1,
            last_printed_at = ?,
            updated_at = ?
        WHERE id = ?
      ''', [DateTime.now().millisecondsSinceEpoch, DateTime.now().millisecondsSinceEpoch, barcodeId]);
      if (count == 0) throw StateError('Barcode not found');
      await auditService.logInTransaction(
        txn,
        action: 'print_barcode',
        detail: 'Incremented print count for barcode $barcodeId',
        entityType: 'barcodes',
        entityId: barcodeId,
        userId: userId,
      );
    });
    return barcodeId;
  }

  Future<void> voidBarcode(int barcodeId, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.update('barcodes', {'status': 'VOIDED', 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [barcodeId]);
      if (count == 0) throw StateError('Barcode not found');
      await auditService.logInTransaction(
        txn,
        action: 'void_barcode',
        detail: 'Voided barcode $barcodeId',
        entityType: 'barcodes',
        entityId: barcodeId,
        userId: userId,
      );
    });
  }

  // ============ Barcode Scans ============

  Future<int> logBarcodeScan(BarcodeScan scan, {int? userId}) async {
    return await db.transaction((txn) async {
      final id = await txn.insert('barcode_scans', scan.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'log_barcode_scan',
        detail: 'Logged barcode scan ${scan.barcodeValue}',
        entityType: 'barcode_scans',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<BarcodeScan>> getBarcodeScans({
    int? sessionId,
    String? barcodeValue,
    int? entityId,
    String? entityType,
    String? scanType,
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
    if (scanType != null) {
      where.add('scan_type = ?');
      args.add(scanType);
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

  Future<int> createBatchScanSession(BatchScanSession session, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = session.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('batch_scan_sessions', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_batch_scan_session',
        detail: 'Created batch scan session ${session.sessionType}',
        entityType: 'batch_scan_sessions',
        entityId: id,
        userId: userId,
      );
      return id;
    });
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
    return _getBatchScanSessions(
      sessionType: sessionType,
      referenceId: referenceId,
      status: status,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<List<BatchScanSession>> _getBatchScanSessions({
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

  Future<int> updateBatchScanSession(BatchScanSession session, {int? userId}) async {
    final map = session.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final count = await txn.update('batch_scan_sessions', map, where: 'id = ?', whereArgs: [session.id]);
      if (count == 0) throw StateError('Batch scan session not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_batch_scan_session',
        detail: 'Updated batch scan session',
        entityType: 'batch_scan_sessions',
        entityId: session.id,
        userId: userId,
      );
    });
    return session.id!;
  }

  Future<int> addBatchScanItem(BatchScanItem item, {int? userId}) async {
    return await db.transaction((txn) async {
      final id = await txn.insert('batch_scan_items', item.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'add_batch_scan_item',
        detail: 'Added item to batch scan session ${item.sessionId}',
        entityType: 'batch_scan_items',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<BatchScanItem>> getBatchScanItems(int sessionId) async {
    final maps = await db.query('batch_scan_items', where: 'session_id = ?', whereArgs: [sessionId]);
    return maps.map((m) => BatchScanItem.fromMap(m)).toList();
  }

  Future<int> updateBatchScanItem(BatchScanItem item, {int? userId}) async {
    await db.transaction((txn) async {
      final count = await txn.update('batch_scan_items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
      if (count == 0) throw StateError('Batch scan item not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_batch_scan_item',
        detail: 'Updated batch scan item',
        entityType: 'batch_scan_items',
        entityId: item.id,
        userId: userId,
      );
    });
    return item.id!;
  }

  // ============ Label Print Jobs ============

  Future<int> createLabelPrintJob(LabelPrintJob job, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = job.toMap();
    map['requested_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('label_print_jobs', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_label_print_job',
        detail: 'Created label print job',
        entityType: 'label_print_jobs',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<LabelPrintJob?> getLabelPrintJob(int id) async {
    final maps = await db.query('label_print_jobs', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return LabelPrintJob.fromMap(maps.first);
  }

  Future<List<LabelPrintJob>> getLabelPrintJobs({String? status}) async {
    return _getLabelPrintJobs(status: status);
  }

  Future<List<LabelPrintJob>> _getLabelPrintJobs({String? status}) async {
    final where = status != null ? 'status = ?' : null;
    final args = status != null ? [status] : null;
    final maps = await db.query('label_print_jobs', where: where, whereArgs: args, orderBy: 'requested_at DESC');
    return maps.map((m) => LabelPrintJob.fromMap(m)).toList();
  }

  Future<int> updateLabelPrintJobStatus(int id, String status, {int? printedCount, int? failedCount, String? errorLog, int? userId}) async {
    final map = {'status': status, 'updated_at': DateTime.now().millisecondsSinceEpoch};
    if (printedCount != null) map['printed_count'] = printedCount;
    if (failedCount != null) map['failed_count'] = failedCount;
    if (errorLog != null) map['error_log'] = errorLog;
    if (status == 'PRINTING') map['started_at'] = DateTime.now().millisecondsSinceEpoch;
    if (status == 'COMPLETED' || status == 'FAILED' || status == 'CANCELLED') map['completed_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      final count = await txn.update('label_print_jobs', map, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Label print job not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_label_print_job_status',
        detail: 'Label print job status changed to $status',
        entityType: 'label_print_jobs',
        entityId: id,
        userId: userId,
      );
    });
    return id;
  }

  // ============ Printer Configs ============

  Future<int> createPrinterConfig(PrinterConfig config, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = config.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await db.transaction((txn) async {
      final id = await txn.insert('printer_configs', map);
      await auditService.logInTransaction(
        txn,
        action: 'create_printer_config',
        detail: 'Created printer config ${config.name}',
        entityType: 'printer_configs',
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<List<PrinterConfig>> getPrinterConfigs({bool activeOnly = true}) async {
    return _getPrinterConfigs(activeOnly: activeOnly);
  }

  Future<List<PrinterConfig>> _getPrinterConfigs({bool activeOnly = true}) async {
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
  // (Read-only methods unchanged)

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