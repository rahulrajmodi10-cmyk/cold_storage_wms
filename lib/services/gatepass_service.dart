// lib/services/gatepass_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class GatepassService extends BaseRepository<Gatepass> {
  final Database db;
  final AuditService auditService;

  GatepassService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'gatepass',
          entityType: EntityTypes.gatepass,
          fromMap: (m) => Gatepass.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(Gatepass entity) => entity.toMap();

  @override
  int? getId(Gatepass entity) => entity.id;

  @override
  Gatepass setId(Gatepass entity, int id) => entity..id = id;

  Future<Gatepass?> getGatepass(int id) async => getById(id);

  Future<Gatepass?> getGatepassByNumber(String gatepassNumber) async {
    final query = QueryBuilder.where().eq('gatepass_number', gatepassNumber);
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
    final query = QueryBuilder.where();
    if (status != null) query.eq('status', status);
    if (gatepassTypeId != null) query.eq('gatepass_type_id', gatepassTypeId);
    if (partyId != null) query.eq('party_id', partyId);
    if (vehicleId != null) query.eq('vehicle_id', vehicleId);
    if (fromDate != null) query.gte('requested_date', fromDate);
    if (toDate != null) query.lte('requested_date', toDate);
    query.orderBy('requested_date', descending: true);
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

  Future<int> createGatepass(Gatepass gatepass, {int? userId}) async {
    return await create(gatepass,
        action: 'create_gatepass',
        detail: 'Created gatepass ${gatepass.gatepassNumber}',
        userId: userId);
  }

  Future<int> updateGatepass(Gatepass gatepass, {int? userId}) async {
    return await update(gatepass,
        action: 'update_gatepass',
        detail: 'Updated gatepass ${gatepass.gatepassNumber}',
        userId: userId);
  }

  Future<int> updateGatepassStatus(int id, String status, {Map<String, dynamic>? extraFields, int? userId}) async {
    final Map<String, dynamic> map = {
      'status': status,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    if (extraFields != null) map.addAll(extraFields);
    return await transaction((txn) async {
      final count = await txn.update(tableName, map, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Gatepass not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_gatepass_status',
        detail: 'Gatepass status changed to $status',
        entityType: EntityTypes.gatepass,
        entityId: id,
        userId: userId,
      );
      return id;
    });
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
}