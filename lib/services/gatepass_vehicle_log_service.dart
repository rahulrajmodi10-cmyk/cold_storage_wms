// lib/services/gatepass_vehicle_log_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class GatepassVehicleLogService extends BaseRepository<GatepassVehicleLog> {
  final Database db;
  final AuditService auditService;

  GatepassVehicleLogService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'gatepass_vehicle_log',
          entityType: EntityTypes.gatepassVehicleLog,
          fromMap: (m) => GatepassVehicleLog.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(GatepassVehicleLog entity) => entity.toMap();

  @override
  int? getId(GatepassVehicleLog entity) => entity.id;

  @override
  GatepassVehicleLog setId(GatepassVehicleLog entity, int id) => entity..id = id;

  Future<List<GatepassVehicleLog>> getVehicleLogs(int gatepassId) async {
    final query = QueryBuilder.where().eq('gatepass_id', gatepassId).orderBy('timestamp');
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> logVehicleEntry(GatepassVehicleLog log, {int? userId}) async {
    return await create(log,
        action: 'log_vehicle_entry',
        detail: 'Logged vehicle entry for gatepass ${log.gatepassId}',
        userId: userId);
  }
}