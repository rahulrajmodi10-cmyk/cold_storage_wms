// lib/services/batch_scan_item_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class BatchScanItemService extends BaseRepository<BatchScanItem> {
  final Database db;
  final AuditService auditService;

  BatchScanItemService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'batch_scan_items',
          entityType: EntityTypes.batchScanItem,
          fromMap: (m) => BatchScanItem.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(BatchScanItem entity) => entity.toMap();

  @override
  int? getId(BatchScanItem entity) => entity.id;

  @override
  BatchScanItem setId(BatchScanItem entity, int id) => entity..id = id;

  Future<List<BatchScanItem>> getBatchScanItems(int sessionId) async {
    final query = QueryBuilder.where().eq('session_id', sessionId);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> addBatchScanItem(BatchScanItem item, {int? userId}) async {
    return await create(item,
        action: 'add_batch_scan_item',
        detail: 'Added item to batch scan session ${item.sessionId}',
        userId: userId);
  }

  Future<int> updateBatchScanItem(BatchScanItem item, {int? userId}) async {
    return await update(item,
        action: 'update_batch_scan_item',
        detail: 'Updated batch scan item',
        userId: userId);
  }
}