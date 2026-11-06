// lib/services/label_print_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class LabelPrintJobService extends BaseRepository<LabelPrintJob> {
  final Database db;
  final AuditService auditService;

  LabelPrintJobService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'label_print_jobs',
          entityType: EntityTypes.labelPrintJob,
          fromMap: (m) => LabelPrintJob.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(LabelPrintJob entity) => entity.toMap();

  @override
  int? getId(LabelPrintJob entity) => entity.id;

  @override
  LabelPrintJob setId(LabelPrintJob entity, int id) => entity..id = id;

  Future<LabelPrintJob?> getLabelPrintJob(int id) async => getById(id);

  Future<List<LabelPrintJob>> getLabelPrintJobs({String? status}) async {
    final query = QueryBuilder.where();
    if (status != null) query.eq('status', status);
    query.orderBy('requested_at', descending: true);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createLabelPrintJob(LabelPrintJob job, {int? userId}) async {
    return await create(job,
        action: 'create_label_print_job',
        detail: 'Created label print job ${job.jobNumber}',
        userId: userId);
  }

  Future<int> updateLabelPrintJobStatus(int id, String status, {int? printedCount, int? failedCount, String? errorLog, int? userId}) async {
    final map = {'status': status, 'updated_at': DateTime.now().millisecondsSinceEpoch};
    if (printedCount != null) map['printed_count'] = printedCount;
    if (failedCount != null) map['failed_count'] = failedCount;
    if (errorLog != null) map['error_log'] = errorLog;
    if (status == 'PRINTING') map['started_at'] = DateTime.now().millisecondsSinceEpoch;
    if (status == 'COMPLETED' || status == 'FAILED' || status == 'CANCELLED') map['completed_at'] = DateTime.now().millisecondsSinceEpoch;
    return await transaction((txn) async {
      final count = await txn.update(tableName, map, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Label print job not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_label_print_job_status',
        detail: 'Label print job status changed to $status',
        entityType: EntityTypes.labelPrintJob,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }
}