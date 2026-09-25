// lib/services/sla_service.dart

import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SlaService {
  final Database db;
  Timer? _timer;
  final Duration interval;

  SlaService(this.db, {this.interval = const Duration(minutes: 1)});

  void start() {
    _timer ??= Timer.periodic(interval, (_) => _checkSlas());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _checkSlas() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Receiving SLA: items logged within 30 minutes of arrival
    // For MVP we treat transfer_record with reason='receiving' and a 'requested_at' field (future)

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
      await db.insert('audit_log', {
        'user_id': null,
        'action': 'sla_breach',
        'detail': 'Pick request ${p['id']} exceeded 2 hours',
        'timestamp': now,
        'entity_type': 'transfer_record',
        'entity_id': p['id']
      });
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
      await db.insert('audit_log', {
        'user_id': null,
        'action': 'expiry_warning',
        'detail': 'Item ${e['sku']} expires within 48 hours',
        'timestamp': now,
        'entity_type': 'inventory_item',
        'entity_id': e['id']
      });
    }
  }
}
