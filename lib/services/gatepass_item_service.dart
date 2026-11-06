// lib/services/gatepass_item_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/gatepass_barcode_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class GatepassItemService extends BaseRepository<GatepassItem> {
  final Database db;
  final AuditService auditService;

  GatepassItemService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'gatepass_items',
          entityType: EntityTypes.gatepassItem,
          fromMap: (m) => GatepassItem.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(GatepassItem entity) => entity.toMap();

  @override
  int? getId(GatepassItem entity) => entity.id;

  @override
  GatepassItem setId(GatepassItem entity, int id) => entity..id = id;

  Future<List<GatepassItem>> getGatepassItems(int gatepassId) async {
    final query = QueryBuilder.where().eq('gatepass_id', gatepassId);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> addGatepassItem(GatepassItem item, {int? userId}) async {
    return await create(item,
        action: 'add_gatepass_item',
        detail: 'Added item to gatepass ${item.gatepassId}',
        userId: userId);
  }

  Future<int> updateGatepassItem(GatepassItem item, {int? userId}) async {
    return await update(item,
        action: 'update_gatepass_item',
        detail: 'Updated gatepass item',
        userId: userId);
  }

  Future<int> verifyGatepassItem(int itemId, {
    required double verifiedQuantity,
    required double verifiedWeight,
    required int verifiedPackages,
    required String verificationStatus,
    String? notes,
    int? verifiedBy,
  }) async {
    return await transaction((txn) async {
      final count = await txn.update(tableName, {
        'verified_quantity': verifiedQuantity,
        'verified_weight': verifiedWeight,
        'verified_packages': verifiedPackages,
        'verification_status': verificationStatus,
        'verification_notes': notes,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, where: 'id = ?', whereArgs: [itemId]);
      if (count == 0) throw StateError('Gatepass item not found');
      await auditService.logInTransaction(
        txn,
        action: 'verify_gatepass_item',
        detail: 'Verified item with status $verificationStatus',
        entityType: EntityTypes.gatepassItem,
        entityId: itemId,
        userId: verifiedBy,
      );
      return itemId;
    });
  }
}