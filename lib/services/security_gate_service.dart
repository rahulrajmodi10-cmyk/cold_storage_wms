// lib/services/security_gate_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class SecurityGateService extends BaseRepository<SecurityGate> {
  final Database db;
  final AuditService auditService;

  SecurityGateService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'security_gates',
          entityType: EntityTypes.securityGate,
          fromMap: (m) => SecurityGate.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(SecurityGate entity) => entity.toMap();

  @override
  int? getId(SecurityGate entity) => entity.id;

  @override
  SecurityGate setId(SecurityGate entity, int id) => entity..id = id;

  Future<List<SecurityGate>> getSecurityGates({bool activeOnly = true}) async {
    final query = QueryBuilder.where();
    if (activeOnly) query.eq('is_active', 1);
    query.orderBy('code');
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createSecurityGate(SecurityGate gate, {int? userId}) async {
    return await create(gate,
        action: 'create_security_gate',
        detail: 'Created security gate ${gate.code}',
        userId: userId);
  }
}