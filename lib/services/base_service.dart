import 'package:sqflite/sqflite.dart';

abstract class BaseService {
  final Database db;

  BaseService(this.db);

  /// Audit log entry for tracking actions
  Future<void> audit(String action, String detail, int entityId) async {
    await db.insert('audit_log', {
      'user_id': 0,
      'action': action,
      'detail': detail,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'entity_type': '',
      'entity_id': entityId,
    });
  }
}