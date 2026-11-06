// lib/services/barcode_scan_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class BarcodeScanService extends BaseRepository<BarcodeScan> {
  final Database db;
  final AuditService auditService;

  BarcodeScanService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'barcode_scans',
          entityType: EntityTypes.barcodeScan,
          fromMap: (m) => BarcodeScan.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(BarcodeScan entity) => entity.toMap();

  @override
  int? getId(BarcodeScan entity) => entity.id;

  @override
  BarcodeScan setId(BarcodeScan entity, int id) => entity..id = id;

  Future<BarcodeScan?> getBarcodeScan(int id) async => getById(id);

  Future<List<BarcodeScan>> getBarcodeScans({
    String? scanType,
    String? status,
    int? definitionId,
    int? entityId,
    int? userId,
    int? fromDate,
    int? toDate,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = QueryBuilder.where();
    if (scanType != null) query.eq('scan_type', scanType);
    if (status != null) query.eq('status', status);
    if (definitionId != null) query.eq('barcode_definition_id', definitionId);
    if (entityId != null) query.eq('entity_id', entityId);
    if (userId != null) query.eq('user_id', userId);
    if (fromDate != null) query.gte('timestamp', fromDate);
    if (toDate != null) query.lte('timestamp', toDate);
    query.orderBy('timestamp', descending: true);
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

  Future<int> logScan(BarcodeScan scan, {int? userId}) async {
    return await create(scan,
        action: 'log_barcode_scan',
        detail: 'Logged scan ${scan.barcodeValue}',
        userId: userId ?? scan.scannedBy);
  }

  Future<int> logBarcodeScan(BarcodeScan scan, {int? userId}) async {
    return await logScan(scan, userId: userId);
  }
}