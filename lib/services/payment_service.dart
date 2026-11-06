// lib/services/payment_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/finance_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class PaymentService extends BaseRepository<Payment> {
  final Database db;
  final AuditService auditService;

  PaymentService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'payments',
          entityType: EntityTypes.payment,
          fromMap: (m) => Payment.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(Payment entity) => entity.toMap();

  @override
  int? getId(Payment entity) => entity.id;

  @override
  Payment setId(Payment entity, int id) => entity..id = id;

  Future<Payment?> getPayment(int id) async => getById(id);

  Future<List<Payment>> getPayments({
    String? type,
    int? partyId,
    int? invoiceId,
    int? fromDate,
    int? toDate,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = QueryBuilder.where();
    if (type != null) query.eq('type', type);
    if (partyId != null) query.eq('party_id', partyId);
    if (invoiceId != null) query.eq('invoice_id', invoiceId);
    if (fromDate != null) query.gte('payment_date', fromDate);
    if (toDate != null) query.lte('payment_date', toDate);
    query.orderBy('payment_date', descending: true);
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

  Future<int> createPayment(Payment payment, {int? userId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = payment.toMap();
    map['created_at'] = now;
    return await transaction((txn) async {
      final id = await txn.insert(tableName, map);
      await auditService.logInTransaction(
        txn,
        action: 'create_payment',
        detail: 'Created payment ${payment.paymentNumber} for ${payment.type}',
        entityType: EntityTypes.payment,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  Future<int> updatePaymentStatus(int id, String status, {int? userId}) async {
    return await transaction((txn) async {
      final count = await txn.update(tableName, {'status': status}, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('Payment not found');
      await auditService.logInTransaction(
        txn,
        action: 'update_payment_status',
        detail: 'Payment status changed to $status',
        entityType: EntityTypes.payment,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }
}

// Payment Allocation Service
class PaymentAllocationService extends BaseRepository<PaymentAllocation> {
  final Database db;
  final AuditService auditService;

  PaymentAllocationService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'payment_allocations',
          entityType: EntityTypes.paymentAllocation,
          fromMap: (m) => PaymentAllocation.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(PaymentAllocation entity) => entity.toMap();

  @override
  int? getId(PaymentAllocation entity) => entity.id;

  @override
  PaymentAllocation setId(PaymentAllocation entity, int id) => entity..id = id;

  Future<List<PaymentAllocation>> getAllocationsForPayment(int paymentId) async {
    final query = QueryBuilder.where().eq('payment_id', paymentId);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> createAllocation(PaymentAllocation allocation, {int? userId}) async {
    return await transaction((txn) async {
      final id = await txn.insert(tableName, allocation.toMap());
      await auditService.logInTransaction(
        txn,
        action: 'create_payment_allocation',
        detail: 'Allocated payment ${allocation.paymentId} to invoice ${allocation.invoiceId}',
        entityType: EntityTypes.paymentAllocation,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }
}