// lib/services/printer_config_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class PrinterConfigService extends BaseRepository<PrinterConfig> {
  final Database db;
  final AuditService auditService;

  PrinterConfigService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'printer_configs',
          entityType: EntityTypes.printerConfig,
          fromMap: (m) => PrinterConfig.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(PrinterConfig entity) => entity.toMap();

  @override
  int? getId(PrinterConfig entity) => entity.id;

  @override
  PrinterConfig setId(PrinterConfig entity, int id) => entity..id = id;

  Future<List<PrinterConfig>> getPrinterConfigs({bool activeOnly = true}) async {
    final query = QueryBuilder.where();
    if (activeOnly) query.eq('is_active', 1);
    query.orderBy('name');
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createPrinterConfig(PrinterConfig config, {int? userId}) async {
    return await create(config,
        action: 'create_printer_config',
        detail: 'Created printer config ${config.name}',
        userId: userId);
  }

  Future<int> updatePrinterConfig(PrinterConfig config, {int? userId}) async {
    return await update(config,
        action: 'update_printer_config',
        detail: 'Updated printer config ${config.name}',
        userId: userId);
  }

  Future<int> setDefaultPrinter(int id, {int? userId}) async {
    await transaction((txn) async {
      await txn.update(tableName, {'is_default': 0}, where: 'is_default = 1');
      await txn.update(tableName, {'is_default': 1}, where: 'id = ?', whereArgs: [id]);
      await auditService.logInTransaction(
        txn,
        action: 'set_default_printer',
        detail: 'Set printer as default',
        entityType: EntityTypes.printerConfig,
        entityId: id,
        userId: userId,
      );
    });
    return id;
  }
}