// lib/services/audit_service.dart

import 'package:sqflite/sqflite.dart';

class AuditService {
  final Database db;

  AuditService(this.db);

  Future<void> log({
    required String action,
    required String detail,
    required String entityType,
    int? entityId,
    int? userId,
  }) async {
    await db.insert('audit_log', {
      'user_id': userId,
      'action': action,
      'detail': detail,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'entity_type': entityType,
      'entity_id': entityId,
    });
  }

  Future<void> logInTransaction(
    Transaction txn, {
    required String action,
    required String detail,
    required String entityType,
    int? entityId,
    int? userId,
  }) async {
    await txn.insert('audit_log', {
      'user_id': userId,
      'action': action,
      'detail': detail,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'entity_type': entityType,
      'entity_id': entityId,
    });
  }
}