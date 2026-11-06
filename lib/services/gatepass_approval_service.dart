// lib/services/gatepass_approval_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class GatepassApprovalService extends BaseRepository<GatepassApproval> {
  final Database db;
  final AuditService auditService;

  GatepassApprovalService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'gatepass_approvals',
          entityType: EntityTypes.gatepassApproval,
          fromMap: (m) => GatepassApproval.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(GatepassApproval entity) => entity.toMap();

  @override
  int? getId(GatepassApproval entity) => entity.id;

  @override
  GatepassApproval setId(GatepassApproval entity, int id) => entity..id = id;

  Future<List<GatepassApproval>> getGatepassApprovals(int gatepassId) async {
    final query = QueryBuilder.where().eq('gatepass_id', gatepassId).orderBy('level');
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createGatepassApproval(GatepassApproval approval, {int? userId}) async {
    return await create(approval,
        action: 'create_gatepass_approval',
        detail: 'Created approval for gatepass ${approval.gatepassId}',
        userId: userId);
  }

  Future<int> processGatepassApproval(int approvalId, String status, int approverId, {String? comments, int? delegatedTo, int? userId}) async {
    final map = {
      'status': status,
      'approver_id': approverId,
      'action_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    if (comments != null) map['comments'] = comments;
    if (delegatedTo != null) map['delegated_to'] = delegatedTo;
    return await transaction((txn) async {
      final count = await txn.update(tableName, map, where: 'id = ?', whereArgs: [approvalId]);
      if (count == 0) throw StateError('Gatepass approval not found');
      await auditService.logInTransaction(
        txn,
        action: 'process_gatepass_approval',
        detail: 'Approval processed with status $status',
        entityType: EntityTypes.gatepassApproval,
        entityId: approvalId,
        userId: userId ?? approverId,
      );
      return approvalId;
    });
  }
}