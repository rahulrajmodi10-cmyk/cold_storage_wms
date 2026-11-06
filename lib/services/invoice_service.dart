// lib/services/invoice_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/finance_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class InvoiceService extends BaseRepository<Invoice> {
  final Database db;
  final AuditService auditService;

  InvoiceService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'invoices',
          entityType: EntityTypes.invoice,
          fromMap: (m) => Invoice.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(Invoice entity) => entity.toMap();

  @override
  int? getId(Invoice entity) => entity.id;

  @override
  Invoice setId(Invoice entity, int id) => entity..id = id;

  Future<Invoice?> getInvoice(int id) async => getById(id);

  Future<Invoice?> getInvoiceByNumber(String invoiceNumber) async {
    final query = QueryBuilder.where().eq('invoice_number', invoiceNumber);
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

  Future<List<Invoice>> getInvoices({
    String? type,
    String? status,
    int? partyId,
    int? fromDate,
    int? toDate,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = QueryBuilder.where();
    if (type != null) query.eq('type', type);
    if (status != null) query.eq('status', status);
    if (partyId != null) query.eq('party_id', partyId);
    if (fromDate != null) query.gte('invoice_date', fromDate);
    if (toDate != null) query.lte('invoice_date', toDate);
    query.orderBy('invoice_date', descending: true);
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

  Future<int> createInvoice(Invoice invoice, {int? userId}) async {
    return await create(invoice,
        action: 'create_invoice',
        detail: 'Created invoice ${invoice.invoiceNumber} for ${invoice.type}',
        userId: userId);
  }

  Future<int> updateInvoice(Invoice invoice, {int? userId}) async {
    return await update(invoice,
        action: 'update_invoice',
        detail: 'Updated invoice ${invoice.invoiceNumber}',
        userId: userId);
  }

  Future<int> updateInvoiceStatus(int id, String status, {double? paidAmount, double? balanceAmount, int? userId}) async {
    final map = {'status': status, 'updated_at': DateTime.now().millisecondsSinceEpoch};
    if (paidAmount != null) map['paid_amount'] = paidAmount;
    if (balanceAmount != null) map['balance_amount'] = balanceAmount;
    return await transaction((txn) async {
      final count = await txn.update(tableName, map, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Invoice not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_invoice_status',
        detail: 'Invoice status changed to $status',
        entityType: EntityTypes.invoice,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }
}

// Separate service for Invoice Items
class InvoiceItemService extends BaseRepository<InvoiceItem> {
  final Database db;
  final AuditService auditService;

  InvoiceItemService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'invoice_items',
          entityType: EntityTypes.invoiceItem,
          fromMap: (m) => InvoiceItem.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(InvoiceItem entity) => entity.toMap();

  @override
  int? getId(InvoiceItem entity) => entity.id;

  @override
  InvoiceItem setId(InvoiceItem entity, int id) => entity..id = id;

  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    final query = QueryBuilder.where().eq('invoice_id', invoiceId);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> addInvoiceItem(InvoiceItem item, {int? userId}) async {
    return await create(item,
        action: 'add_invoice_item',
        detail: 'Added item to invoice ${item.invoiceId}',
        userId: userId);
  }

  Future<int> updateInvoiceItem(InvoiceItem item, {int? userId}) async {
    return await update(item,
        action: 'update_invoice_item',
        detail: 'Updated invoice item',
        userId: userId);
  }

  Future<void> deleteInvoiceItems(int invoiceId, {int? userId}) async {
    await deleteWhere('invoice_id = ?', [invoiceId],
        action: 'delete_invoice_items',
        detail: 'Deleted all items for invoice $invoiceId',
        userId: userId);
  }
}