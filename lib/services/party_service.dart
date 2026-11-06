// lib/services/party_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/finance_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class PartyService extends BaseRepository<Party> {
  final Database db;
  final AuditService auditService;

  PartyService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'parties',
          entityType: EntityTypes.party,
          fromMap: (m) => Party.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(Party entity) => entity.toMap();

  @override
  int? getId(Party entity) => entity.id;

  @override
  Party setId(Party entity, int id) => entity..id = id;

  Future<Party?> getParty(int id) async => getById(id);

  Future<List<Party>> getParties({String? type, bool activeOnly = true}) async {
    final query = QueryBuilder.where();
    if (type != null) query.eq('type', type);
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

  Future<int> createParty(Party party, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = party.toMap();
    map['created_at'] = now;
    map['updated_at'] = now;
    return await transaction((txn) async {
      final id = await txn.insert(tableName, map);
      await auditService.logInTransaction(
        txn,
        action: 'create_party',
        detail: 'Created party ${party.name} (${party.type})',
        entityType: EntityTypes.party,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<int> updateParty(Party party, {int? userId}) async {
    final map = party.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return await transaction((txn) async {
      final count = await txn.update(tableName, map, where: 'id = ?', whereArgs: [party.id]);
      if (count == 0) throw StateError('Party not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_party',
        detail: 'Updated party ${party.name}',
        entityType: EntityTypes.party,
        entityId: party.id,
        userId: userId,
      );
      return party.id!;
    });
  }

  Future<int> deleteParty(int id, {int? userId}) async {
    return await transaction((txn) async {
      final count = await txn.delete(tableName, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Party not found');
      await auditService.logInTransaction(
        txn,
        action: 'delete_party',
        detail: 'Deleted party $id',
        entityType: EntityTypes.party,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }
}