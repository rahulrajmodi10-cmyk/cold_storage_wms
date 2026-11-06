// lib/services/gst_return_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/finance_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class GSTReturnService extends BaseRepository<GSTReturn> {
  final Database db;
  final AuditService auditService;

  GSTReturnService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'gst_returns',
          entityType: EntityTypes.gstReturn,
          fromMap: (m) => GSTReturn.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(GSTReturn entity) => entity.toMap();

  @override
  int? getId(GSTReturn entity) => entity.id;

  @override
  GSTReturn setId(GSTReturn entity, int id) => entity..id = id;

  Future<GSTReturn?> getGSTReturn(int id) async => getById(id);

  Future<List<GSTReturn>> getGSTRReturns({
    String? returnType,
    String? period,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = QueryBuilder.where();
    if (returnType != null) query.eq('return_type', returnType);
    if (period != null) query.eq('period', period);
    query.orderBy('period', descending: true);
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

  Future<int> createGSTReturn(GSTReturn return_, {int? userId}) async {
    return await create(return_,
        action: 'create_gst_return',
        detail: 'Created GST return ${return_.returnType} for ${return_.period}',
        userId: userId);
  }

  Future<int> updateGSTReturn(GSTReturn return_, {int? userId}) async {
    return await update(return_,
        action: 'update_gst_return',
        detail: 'Updated GST return ${return_.returnType}',
        userId: userId);
  }

  Future<int> deleteGSTReturn(int id, {int? userId}) async {
    return await delete(id,
        action: 'delete_gst_return',
        detail: 'Deleted GST return $id',
        userId: userId);
  }
}