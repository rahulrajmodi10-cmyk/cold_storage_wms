// lib/models/base_model.dart

/// Base mixin for all entity models providing common fields and serialization methods
mixin BaseModel {
  int? id;
  int? createdAt;
  int? updatedAt;

  /// Convert base fields to map for database operations
  Map<String, dynamic> baseToMap() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  /// Populate base fields from database map
  void baseFromMap(Map<String, dynamic> map) {
    id = map['id'] as int?;
    createdAt = map['created_at'] as int?;
    updatedAt = map['updated_at'] as int?;
  }

  /// Create a copy with updated timestamp
  T copyWithUpdatedAt<T extends BaseModel>(T entity, int updatedAt) {
    entity.updatedAt = updatedAt;
    return entity;
  }

  /// Create a copy with id and timestamps (after insert)
  T copyWithIdAndTimestamps<T extends BaseModel>(T entity, int id, int createdAt, int updatedAt) {
    entity.id = id;
    entity.createdAt = createdAt;
    entity.updatedAt = updatedAt;
    return entity;
  }
}

/// Extension for nullable datetime helpers
extension BaseModelDateTime on BaseModel {
  DateTime? get createdAtDateTime => createdAt != null ? DateTime.fromMillisecondsSinceEpoch(createdAt!) : null;
  DateTime? get updatedAtDateTime => updatedAt != null ? DateTime.fromMillisecondsSinceEpoch(updatedAt!) : null;

  String? get createdAtString => createdAtDateTime?.toIso8601String();
  String? get updatedAtString => updatedAtDateTime?.toIso8601String();
}