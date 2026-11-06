// lib/services/chart_of_accounts_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/finance_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class ChartOfAccountsService extends BaseRepository<ChartOfAccount> {
  final Database db;
  final AuditService auditService;

  ChartOfAccountsService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'chart_of_accounts',
          entityType: EntityTypes.chartOfAccount,
          fromMap: (m) => ChartOfAccount.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(ChartOfAccount entity) => entity.toMap();

  @override
  int? getId(ChartOfAccount entity) => entity.id;

  @override
  ChartOfAccount setId(ChartOfAccount entity, int id) => entity..id = id;

  Future<ChartOfAccount?> getAccount(int id) async => getById(id);

  Future<List<ChartOfAccount>> getAccounts({
    String? type,
    int? parentId,
    bool activeOnly = true,
  }) async {
    final query = QueryBuilder.where();
    if (type != null) query.eq('type', type);
    if (parentId != null) query.eq('parent_id', parentId);
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

  Future<int> createAccount(ChartOfAccount account, {int? userId}) async {
    return await create(account,
        action: 'create_account',
        detail: 'Created account ${account.code} - ${account.name}',
        userId: userId);
  }

  Future<int> updateAccount(ChartOfAccount account, {int? userId}) async {
    return await update(account,
        action: 'update_account',
        detail: 'Updated account ${account.code} - ${account.name}',
        userId: userId);
  }

  Future<int> deleteAccount(int id, {int? userId}) async {
    return await delete(id,
        action: 'delete_account',
        detail: 'Deleted account $id',
        userId: userId);
  }
}