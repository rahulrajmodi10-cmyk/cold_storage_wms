// lib/services/loading_bay_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class LoadingBayService extends BaseRepository<LoadingBay> {
  final Database db;
  final AuditService auditService;

  LoadingBayService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'loading_bays',
          entityType: EntityTypes.loadingBay,
          fromMap: (m) => LoadingBay.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(LoadingBay entity) => entity.toMap();

  @override
  int? getId(LoadingBay entity) => entity.id;

  @override
  LoadingBay setId(LoadingBay entity, int id) => entity..id = id;

  Future<List<LoadingBay>> getLoadingBays({bool activeOnly = true}) async {
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

  Future<int> createLoadingBay(LoadingBay bay, {int? userId}) async {
    return await create(bay,
        action: 'create_loading_bay',
        detail: 'Created loading bay ${bay.code}',
        userId: userId);
  }
}