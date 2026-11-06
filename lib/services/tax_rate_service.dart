// lib/services/tax_rate_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/finance_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class TaxRateService extends BaseRepository<TaxRate> {
  final Database db;
  final AuditService auditService;

  TaxRateService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'tax_rates',
          entityType: 'TAX_RATE',
          fromMap: (m) => TaxRate.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(TaxRate entity) => entity.toMap();

  @override
  int? getId(TaxRate entity) => entity.id;

  @override
  TaxRate setId(TaxRate entity, int id) => entity..id = id;

  Future<List<TaxRate>> getTaxRates({bool activeOnly = true, int? effectiveDate}) async {
    final query = QueryBuilder.where();
    if (activeOnly) query.eq('is_active', 1);
    if (effectiveDate != null) {
      query.raw('effective_from <= ?', [effectiveDate]);
      query.raw('(effective_to IS NULL OR effective_to >= ?)', [effectiveDate]);
    }
    query.orderBy('type');
    query.orderBy('rate');
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createTaxRate(TaxRate taxRate, {int? userId}) async {
    return await create(taxRate,
        action: 'create_tax_rate',
        detail: 'Created tax rate ${taxRate.type} ${taxRate.rate}%',
        userId: userId);
  }

  Future<int> updateTaxRate(TaxRate taxRate, {int? userId}) async {
    return await update(taxRate,
        action: 'update_tax_rate',
        detail: 'Updated tax rate ${taxRate.type} ${taxRate.rate}%',
        userId: userId);
  }

  Future<int> deleteTaxRate(int id, {int? userId}) async {
    return await delete(id,
        action: 'delete_tax_rate',
        detail: 'Deleted tax rate $id',
        userId: userId);
  }
}