// lib/services/sla_service.dart

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'audit_service.dart';

class SLAService {
  final Database db;
  final AuditService auditService;
  Timer? _timer;
  final Duration interval;

  SLAService(this.db, {AuditService? auditService, this.interval = const Duration(minutes: 1)})
      : auditService = auditService ?? AuditService(db);

  void start() {
    _timer ??= Timer.periodic(interval, (_) => _checkSlas());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkSlas() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Picking SLA: pick requests older than 2 hours and not completed
    final twoHoursAgo = now - Duration(hours: 2).inMilliseconds;
    final picks = await db.query('transfer_record', where: "reason = ? AND timestamp < ?", whereArgs: ['pick_request', twoHoursAgo]);
    for (final p in picks) {
      await db.insert('alert', {
        'type': 'SLA_BREACH',
        'severity': 'high',
        'message': 'Pick request ${p['id']} breached SLA',
        'target_id': p['id'],
        'acknowledged': 0,
        'created_at': now
      });
      await auditService.log(
        action: 'sla_breach',
        detail: 'Pick request ${p['id']} exceeded 2 hours',
        entityType: 'transfer_record',
        entityId: p['id'] as int,
      );
    }

    // Expiry alerts: notify 48 hours before expiry
    final soon = now + Duration(hours: 48).inMilliseconds;
    final expiring = await db.query('inventory_item', where: 'expiry_date IS NOT NULL AND expiry_date < ?', whereArgs: [soon]);
    for (final e in expiring) {
      await db.insert('alert', {
        'type': 'EXPIRY_WARNING',
        'severity': 'medium',
        'message': 'Item ${e['sku']} expiring soon',
        'target_id': e['id'],
        'acknowledged': 0,
        'created_at': now
      });
      await auditService.log(
        action: 'expiry_warning',
        detail: 'Item ${e['sku']} expires within 48 hours',
        entityType: 'inventory_item',
        entityId: e['id'] as int,
      );
    }
  }
}