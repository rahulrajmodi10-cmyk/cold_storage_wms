// lib/services/barcode_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class BarcodeService extends BaseRepository<Barcode> {
  final Database db;
  final AuditService auditService;

  BarcodeService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'barcodes',
          entityType: EntityTypes.barcode,
          fromMap: (m) => Barcode.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(Barcode entity) => entity.toMap();

  @override
  int? getId(Barcode entity) => entity.id;

  @override
  Barcode setId(Barcode entity, int id) => entity..id = id;

  Future<Barcode?> getBarcode(int id) async => getById(id);

  Future<Barcode?> getBarcodeByValue(String value) async {
    final query = QueryBuilder.where().eq('barcode_value', value).limit(1);
    final queryMap = query.build();
    final results = await list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Barcode>> getBarcodesByEntity(String entityType, int entityId) async {
    final query = QueryBuilder.where()
        .eq('entity_type', entityType)
        .eq('entity_id', entityId);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createBarcode(Barcode barcode, {int? userId}) async {
    return await create(barcode,
        action: 'create_barcode',
        detail: 'Created barcode ${barcode.barcodeValue}',
        userId: userId);
  }

  Future<int> updateBarcode(Barcode barcode, {int? userId}) async {
    return await update(barcode,
        action: 'update_barcode',
        detail: 'Updated barcode ${barcode.barcodeValue}',
        userId: userId);
  }

  String generateGatepassQR(Gatepass gatepass) {
    final buffer = StringBuffer();
    buffer.writeln('GP:${gatepass.gatepassNumber}');
    buffer.writeln('Type:${gatepass.gatepassTypeId}');
    buffer.writeln('Vehicle:${gatepass.vehicleNumber ?? ''}');
    buffer.writeln('Driver:${gatepass.driverName ?? ''}');
    buffer.writeln('Date:${gatepass.requestedDate ?? DateTime.now().millisecondsSinceEpoch}');
    buffer.writeln('Status:${gatepass.status}');
    buffer.writeln('Items:${gatepass.totalItems}');
    buffer.writeln('Qty:${gatepass.totalQuantity}');
    buffer.writeln('Weight:${gatepass.totalWeight?.toStringAsFixed(1) ?? '0'}');
    return buffer.toString();
  }
}