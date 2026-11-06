// lib/services/base_repository.dart

import 'package:sqflite/sqflite.dart';
import 'audit_service.dart';

/// Base class for all repository services providing common CRUD operations,
/// audit logging, and transaction handling.
abstract class BaseRepository<T> {
  final Database db;
  final AuditService auditService;
  final String tableName;
  final String entityType;
  final T Function(Map<String, dynamic>) fromMap;

  BaseRepository({
    required this.db,
    required this.tableName,
    required this.entityType,
    required this.fromMap,
    AuditService? auditService,
  }) : auditService = auditService ?? AuditService(db);

  /// Convert entity to map for database operations
  Map<String, dynamic> toMap(T entity);

  /// Get the primary key value from entity
  int? getId(T entity);

  /// Set the primary key on entity (after insert)
  T setId(T entity, int id);

  /// Create a new entity
  Future<int> create(T entity, {int? userId, String? action, String? detail}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final map = _addTimestamps(toMap(entity), now, now);

    return await db.transaction((txn) async {
      final id = await txn.insert(tableName, map);
      await auditService.logInTransaction(
        txn,
        action: action ?? 'create_$entityType',
        detail: detail ?? 'Created $entityType id=$id',
        entityType: entityType,
        entityId: id,
        userId: userId,
      );
      return id;
    });
  }

  /// Get entity by primary key
  Future<T?> getById(int id) async {
    final maps = await db.query(tableName, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return fromMap(maps.first);
  }

  /// Update an existing entity
  Future<int> update(T entity, {int? userId, String? action, String? detail}) async {
    final id = getId(entity);
    if (id == null) throw ArgumentError('entity id is required');

    final now = DateTime.now().millisecondsSinceEpoch;
    final map = _addTimestamps(toMap(entity), null, now);

    await db.transaction((txn) async {
      final count = await txn.update(
        tableName,
        map,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (count == 0) throw StateError('$entityType not found');

      await auditService.logInTransaction(
        txn,
        action: action ?? 'update_$entityType',
        detail: detail ?? 'Updated $entityType id=$id',
        entityType: entityType,
        entityId: id,
        userId: userId,
      );
    });
    return id;
  }

  /// Delete an entity by id
  Future<int> delete(int id, {int? userId, String? action, String? detail}) async {
    await db.transaction((txn) async {
      final count = await txn.delete(tableName, where: 'id = ?', whereArgs: [id]);
      if (count == 0) throw StateError('$entityType not found');

      await auditService.logInTransaction(
        txn,
        action: action ?? 'delete_$entityType',
        detail: detail ?? 'Deleted $entityType id=$id',
        entityType: entityType,
        entityId: id,
        userId: userId,
      );
    });
    return id;
  }

  /// List all entities with optional where clause
  Future<List<T>> list({
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final maps = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return maps.map(fromMap).toList();
  }

  /// Count entities matching criteria
  Future<int> count({String? where, List<dynamic>? whereArgs}) async {
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableName${where != null ? ' WHERE $where' : ''}',
      whereArgs,
    );
    return (result.first['count'] as int);
  }

  /// Delete entities matching where clause
  Future<int> deleteWhere(String where, List<dynamic> whereArgs, {int? userId, String? action, String? detail}) async {
    await db.transaction((txn) async {
      final count = await txn.delete(tableName, where: where, whereArgs: whereArgs);
      if (count == 0) throw StateError('No $entityType found to delete');

      await auditService.logInTransaction(
        txn,
        action: action ?? 'delete_${entityType}_where',
        detail: detail ?? 'Deleted $entityType where $where',
        entityType: entityType,
        entityId: null,
        userId: userId,
      );
    });
    return 1;
  }

  /// Execute a transaction with audit logging
  Future<R> transaction<R>(
    Future<R> Function(Transaction txn) action, {
    int? userId,
    String? actionName,
    String? detail,
    int? entityId,
  }) async {
    return await db.transaction((txn) async {
      final result = await action(txn);
      await auditService.logInTransaction(
        txn,
        action: actionName ?? 'transaction',
        detail: detail ?? 'Executed transaction',
        entityType: entityType,
        entityId: entityId,
        userId: userId,
      );
      return result;
    });
  }

  /// Add created_at and updated_at timestamps to map
  Map<String, dynamic> _addTimestamps(
    Map<String, dynamic> map,
    int? createdAt,
    int? updatedAt,
  ) {
    final result = Map<String, dynamic>.from(map);
    if (createdAt != null && !result.containsKey('created_at')) {
      result['created_at'] = createdAt;
    }
    if (updatedAt != null) {
      result['updated_at'] = updatedAt;
    }
    return result;
  }
}

/// Mixin for entities that have id, createdAt, updatedAt
mixin TimestampedEntity {
  int? id;
  int? createdAt;
  int? updatedAt;

  Map<String, dynamic> baseToMap() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  void baseFromMap(Map<String, dynamic> map) {
    id = map['id'] as int?;
    createdAt = map['created_at'] as int?;
    updatedAt = map['updated_at'] as int?;
  }
}