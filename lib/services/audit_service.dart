// lib/services/audit_service.dart

import 'package:sqflite/sqflite.dart';

class AuditAlert {
  final int id;
  final String action;
  final String detail;
  final DateTime timestamp;
  final String entityType;
  final int? entityId;
  final bool acknowledged;

  AuditAlert({
    required this.id,
    required this.action,
    required this.detail,
    required this.timestamp,
    required this.entityType,
    this.entityId,
    this.acknowledged = false,
  });

  factory AuditAlert.fromMap(Map<String, dynamic> map) {
    return AuditAlert(
      id: map['id'] as int,
      action: map['action'] as String,
      detail: map['detail'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      entityType: map['entity_type'] as String,
      entityId: map['entity_id'] as int?,
      acknowledged: (map['acknowledged'] as int?) == 1,
    );
  }

  factory AuditAlert.fromAlert(Map<String, dynamic> map) {
    return AuditAlert(
      id: map['id'] as int,
      action: map['type'] as String,
      detail: map['message'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      entityType: 'alert',
      entityId: map['target_id'] as int?,
      acknowledged: (map['acknowledged'] as int?) == 1,
    );
  }
}

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

  Future<List<AuditAlert>> getRecentAlerts({int limit = 100}) async {
    final List<Map<String, dynamic>> maps = await db.query(
      'alert',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return maps.map((map) => AuditAlert.fromAlert(map)).toList();
  }

  Future<void> markAlertAcknowledged(int alertId) async {
    await db.update(
      'alert',
      {'acknowledged': 1},
      where: 'id = ?',
      whereArgs: [alertId],
    );
  }
}