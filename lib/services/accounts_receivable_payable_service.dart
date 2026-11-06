// lib/services/accounts_receivable_payable_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/finance_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class AccountsReceivableService extends BaseRepository<AccountReceivable> {
  final Database db;
  final AuditService auditService;

  AccountsReceivableService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'accounts_receivable',
          entityType: EntityTypes.accountsReceivable,
          fromMap: (m) => AccountReceivable.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(AccountReceivable entity) => entity.toMap();

  @override
  int? getId(AccountReceivable entity) => entity.id;

  @override
  AccountReceivable setId(AccountReceivable entity, int id) => entity..id = id;

  Future<List<AccountReceivable>> getReceivables({int? partyId, String? status}) async {
    final query = QueryBuilder.where();
    if (partyId != null) query.eq('party_id', partyId);
    if (status != null) query.eq('status', status);
    query.orderBy('due_date');
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createReceivable(AccountReceivable ar, {int? userId}) async {
    return await create(ar,
        action: 'create_receivable',
        detail: 'Created receivable for party ${ar.partyId}',
        userId: userId);
  }

  Future<int> updateReceivable(AccountReceivable ar, {int? userId}) async {
    return await update(ar,
        action: 'update_receivable',
        detail: 'Updated receivable',
        userId: userId);
  }
}

class AccountsPayableService extends BaseRepository<AccountPayable> {
  final Database db;
  final AuditService auditService;

  AccountsPayableService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'accounts_payable',
          entityType: EntityTypes.accountsPayable,
          fromMap: (m) => AccountPayable.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(AccountPayable entity) => entity.toMap();

  @override
  int? getId(AccountPayable entity) => entity.id;

  @override
  AccountPayable setId(AccountPayable entity, int id) => entity..id = id;

  Future<List<AccountPayable>> getPayables({int? partyId, String? status}) async {
    final query = QueryBuilder.where();
    if (partyId != null) query.eq('party_id', partyId);
    if (status != null) query.eq('status', status);
    query.orderBy('due_date');
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createPayable(AccountPayable ap, {int? userId}) async {
    return await create(ap,
        action: 'create_payable',
        detail: 'Created payable for party ${ap.partyId}',
        userId: userId);
  }

  Future<int> updatePayable(AccountPayable ap, {int? userId}) async {
    return await update(ap,
        action: 'update_payable',
        detail: 'Updated payable',
        userId: userId);
  }
}