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

  Future<List<AuditAlert>> getRecentAlerts({int limit = 50}) async {
    final maps = await db.query(
      'audit_log',
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((map) {
      return AuditAlert(
        id: map['id'] as int? ?? 0,
        action: map['action'] as String? ?? '',
        detail: map['detail'] as String? ?? '',
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          map['timestamp'] as int? ?? 0,
        ),
        acknowledged: map['acknowledged'] as int? ?? 0,
        userId: map['user_id'] as int?,
      );
    }).toList();
  }

  Future<void> markAlertAcknowledged(int alertId) async {
    await db.update(
      'audit_log',
      {'acknowledged': 1},
      where: 'id = ?',
      whereArgs: [alertId],
    );
  }
}

class AuditAlert {
  final int id;
  final String action;
  final String detail;
  final DateTime timestamp;
  final int acknowledged;
  final int? userId;

  AuditAlert({
    required this.id,
    required this.action,
    required this.detail,
    required this.timestamp,
    required this.acknowledged,
    this.userId,
  });
}