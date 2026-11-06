// lib/services/batch_scan_session_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class BatchScanSessionService extends BaseRepository<BatchScanSession> {
  final Database db;
  final AuditService auditService;

  BatchScanSessionService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'batch_scan_sessions',
          entityType: EntityTypes.batchScanSession,
          fromMap: (m) => BatchScanSession.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(BatchScanSession entity) => entity.toMap();

  @override
  int? getId(BatchScanSession entity) => entity.id;

  @override
  BatchScanSession setId(BatchScanSession entity, int id) => entity..id = id;

  Future<BatchScanSession?> getBatchScanSession(int id) async => getById(id);

  Future<List<BatchScanSession>> getBatchScanSessions({
    String? status,
    int? userId,
    int? gatepassId,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = QueryBuilder.where();
    if (status != null) query.eq('status', status);
    if (userId != null) query.eq('user_id', userId);
    if (gatepassId != null) query.eq('gatepass_id', gatepassId);
    query.orderBy('started_at', descending: true);
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

  Future<int> createBatchScanSession(BatchScanSession session, {int? userId}) async {
    return await create(session,
        action: 'create_batch_scan_session',
        detail: 'Created batch scan session',
        userId: userId ?? session.operatorId);
  }

  Future<int> updateBatchScanSession(BatchScanSession session, {int? userId}) async {
    return await update(session,
        action: 'update_batch_scan_session',
        detail: 'Updated batch scan session',
        userId: userId);
  }

  Future<int> completeBatchScanSession(int id, {int? userId}) async {
    return await transaction((txn) async {
      final count = await txn.update(tableName, {
        'status': 'COMPLETED',
        'ended_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Batch scan session not found');
      await auditService.logInTransaction(
        txn,
        action: 'complete_batch_scan_session',
        detail: 'Batch scan session completed',
        entityType: EntityTypes.batchScanSession,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }
}