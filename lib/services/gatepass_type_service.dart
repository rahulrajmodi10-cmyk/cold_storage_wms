// lib/services/gatepass_type_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class GatepassTypeService extends BaseRepository<GatepassType> {
  final Database db;
  final AuditService auditService;

  GatepassTypeService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'gatepass_types',
          entityType: EntityTypes.gatepassType,
          fromMap: (m) => GatepassType.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(GatepassType entity) => entity.toMap();

  @override
  int? getId(GatepassType entity) => entity.id;

  @override
  GatepassType setId(GatepassType entity, int id) => entity..id = id;

  Future<List<GatepassType>> getGatepassTypes({bool activeOnly = true}) async {
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

  Future<int> createGatepassType(GatepassType type, {int? userId}) async {
    return await create(type,
        action: 'create_gatepass_type',
        detail: 'Created gatepass type ${type.code} - ${type.name}',
        userId: userId);
  }

  Future<int> updateGatepassType(GatepassType type, {int? userId}) async {
    return await update(type,
        action: 'update_gatepass_type',
        detail: 'Updated gatepass type ${type.code}',
        userId: userId);
  }
}