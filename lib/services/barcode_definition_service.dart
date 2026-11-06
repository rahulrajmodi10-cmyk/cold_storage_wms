// lib/services/barcode_definition_service.dart

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class BarcodeDefinitionService extends BaseRepository<BarcodeDefinition> {
  final Database db;
  final AuditService auditService;

  BarcodeDefinitionService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'barcode_definitions',
          entityType: EntityTypes.barcodeDefinition,
          fromMap: (m) => BarcodeDefinition.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(BarcodeDefinition entity) => entity.toMap();

  @override
  int? getId(BarcodeDefinition entity) => entity.id;

  @override
  BarcodeDefinition setId(BarcodeDefinition entity, int id) => entity..id = id;

  Future<List<BarcodeDefinition>> getBarcodeDefinitions({bool activeOnly = true}) async {
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

  Future<BarcodeDefinition?> getBarcodeDefinitionByCode(String code) async {
    final query = QueryBuilder.where().eq('code', code).limit(1);
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

  Future<int> createBarcodeDefinition(BarcodeDefinition def, {int? userId}) async {
    return await create(def,
        action: 'create_barcode_definition',
        detail: 'Created barcode definition ${def.code}',
        userId: userId);
  }

  Future<int> updateBarcodeDefinition(BarcodeDefinition def, {int? userId}) async {
    return await update(def,
        action: 'update_barcode_definition',
        detail: 'Updated barcode definition ${def.code}',
        userId: userId);
  }

  Future<int> deleteBarcodeDefinition(int id, {int? userId}) async {
    return await delete(id,
        action: 'delete_barcode_definition',
        detail: 'Deleted barcode definition',
        userId: userId);
  }

  Future<int> setDefaultDefinition(int definitionId, {int? userId}) async {
    await transaction((txn) async {
      await txn.update(tableName, {'is_default': 0}, where: 'is_default = 1');
      await txn.update(tableName, {'is_default': 1}, where: 'id = ?', whereArgs: [definitionId]);
      await auditService.logInTransaction(
        txn,
        action: 'set_default_barcode_definition',
        detail: 'Set barcode definition as default',
        entityType: EntityTypes.barcodeDefinition,
        entityId: definitionId,
        userId: userId,
      );
    });
    return definitionId;
  }
}