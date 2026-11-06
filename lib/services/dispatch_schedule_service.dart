// lib/services/dispatch_schedule_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class DispatchScheduleService extends BaseRepository<DispatchSchedule> {
  final Database db;
  final AuditService auditService;

  DispatchScheduleService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'dispatch_schedules',
          entityType: EntityTypes.dispatchSchedule,
          fromMap: (m) => DispatchSchedule.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(DispatchSchedule entity) => entity.toMap();

  @override
  int? getId(DispatchSchedule entity) => entity.id;

  @override
  DispatchSchedule setId(DispatchSchedule entity, int id) => entity..id = id;

  Future<DispatchSchedule?> getDispatchSchedule(int id) async => getById(id);

  Future<List<DispatchSchedule>> getDispatchSchedules({
    int? date,
    String? status,
    int? vehicleId,
    int? gatepassId,
    int? shipmentId,
  }) async {
    final query = QueryBuilder.where();
    if (date != null) query.eq('schedule_date', date);
    if (status != null) query.eq('status', status);
    if (vehicleId != null) query.eq('vehicle_id', vehicleId);
    if (gatepassId != null) query.eq('gatepass_id', gatepassId);
    if (shipmentId != null) query.eq('shipment_id', shipmentId);
    query.orderBy('scheduled_start');
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createDispatchSchedule(DispatchSchedule schedule, {int? userId}) async {
    return await create(schedule,
        action: 'create_dispatch_schedule',
        detail: 'Created dispatch schedule ${schedule.scheduleNumber}',
        userId: userId);
  }

  Future<int> updateDispatchSchedule(DispatchSchedule schedule, {int? userId}) async {
    return await update(schedule,
        action: 'update_dispatch_schedule',
        detail: 'Updated dispatch schedule',
        userId: userId);
  }

  Future<int> startDispatchSchedule(int id, {int? userId}) async {
    return await transaction((txn) async {
      final count = await txn.update(tableName, {
        'status': 'IN_PROGRESS',
        'actual_start': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Dispatch schedule not found');
      await auditService.logInTransaction(
        txn,
        action: 'start_dispatch_schedule',
        detail: 'Dispatch schedule started',
        entityType: EntityTypes.dispatchSchedule,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<int> completeDispatchSchedule(int id, {int? userId}) async {
    return await transaction((txn) async {
      final count = await txn.update(tableName, {
        'status': 'COMPLETED',
        'actual_end': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Dispatch schedule not found');
      await auditService.logInTransaction(
        txn,
        action: 'complete_dispatch_schedule',
        detail: 'Dispatch schedule completed',
        entityType: EntityTypes.dispatchSchedule,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }
}