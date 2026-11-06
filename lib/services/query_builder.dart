// lib/services/query_builder.dart

/// Fluent query builder for SQLite WHERE clauses
class QueryBuilder {
  final List<String> _conditions = [];
  final List<dynamic> _args = [];
  String? _orderBy;
  int? _limit;
  int? _offset;

  QueryBuilder();

  /// Create a new query builder
  static QueryBuilder where() => QueryBuilder();

  /// Add equality condition: field = value
  QueryBuilder eq(String field, dynamic value) {
    _conditions.add('$field = ?');
    _args.add(value);
    return this;
  }

  /// Add inequality condition: field != value
  QueryBuilder ne(String field, dynamic value) {
    _conditions.add('$field != ?');
    _args.add(value);
    return this;
  }

  /// Add greater than condition: field > value
  QueryBuilder gt(String field, dynamic value) {
    _conditions.add('$field > ?');
    _args.add(value);
    return this;
  }

  /// Add greater than or equal condition: field >= value
  QueryBuilder gte(String field, dynamic value) {
    _conditions.add('$field >= ?');
    _args.add(value);
    return this;
  }

  /// Add less than condition: field < value
  QueryBuilder lt(String field, dynamic value) {
    _conditions.add('$field < ?');
    _args.add(value);
    return this;
  }

  /// Add less than or equal condition: field <= value
  QueryBuilder lte(String field, dynamic value) {
    _conditions.add('$field <= ?');
    _args.add(value);
    return this;
  }

  /// Add LIKE condition: field LIKE pattern
  QueryBuilder like(String field, String pattern) {
    _conditions.add('$field LIKE ?');
    _args.add(pattern);
    return this;
  }

  /// Add NOT LIKE condition
  QueryBuilder notLike(String field, String pattern) {
    _conditions.add('$field NOT LIKE ?');
    _args.add(pattern);
    return this;
  }

  /// Add IN condition: field IN (values)
  QueryBuilder inList(String field, List<dynamic> values) {
    if (values.isEmpty) {
      _conditions.add('1 = 0'); // Always false
      return this;
    }
    final placeholders = values.map((_) => '?').join(', ');
    _conditions.add('$field IN ($placeholders)');
    _args.addAll(values);
    return this;
  }

  /// Add NOT IN condition
  QueryBuilder notInList(String field, List<dynamic> values) {
    if (values.isEmpty) {
      return this; // No restriction
    }
    final placeholders = values.map((_) => '?').join(', ');
    _conditions.add('$field NOT IN ($placeholders)');
    _args.addAll(values);
    return this;
  }

  /// Add IS NULL condition
  QueryBuilder isNull(String field) {
    _conditions.add('$field IS NULL');
    return this;
  }

  /// Add IS NOT NULL condition
  QueryBuilder isNotNull(String field) {
    _conditions.add('$field IS NOT NULL');
    return this;
  }

  /// Add BETWEEN condition
  QueryBuilder between(String field, dynamic min, dynamic max) {
    _conditions.add('$field BETWEEN ? AND ?');
    _args.addAll([min, max]);
    return this;
  }

  /// Add raw condition
  QueryBuilder raw(String condition, [List<dynamic>? args]) {
    _conditions.add(condition);
    if (args != null) _args.addAll(args);
    return this;
  }

  /// Add AND conjunction
  QueryBuilder and() => this;

  /// Add OR conjunction - wraps previous condition
  QueryBuilder or(QueryBuilder other) {
    if (_conditions.isEmpty) {
      _conditions.addAll(other._conditions);
      _args.addAll(other._args);
    } else if (other._conditions.isNotEmpty) {
      final last = _conditions.removeLast();
      _conditions.add('($last OR ${other._conditions.join(' AND ')})');
      _args.addAll(other._args);
    }
    return this;
  }

  /// Add ORDER BY clause
  QueryBuilder orderBy(String field, {bool descending = false}) {
    _orderBy = '$field ${descending ? 'DESC' : 'ASC'}';
    return this;
  }

  /// Add LIMIT clause
  QueryBuilder limit(int limit) {
    _limit = limit;
    return this;
  }

  /// Add OFFSET clause
  QueryBuilder offset(int offset) {
    _offset = offset;
    return this;
  }

  /// Build the WHERE clause
  String? buildWhere() {
    return _conditions.isEmpty ? null : _conditions.join(' AND ');
  }

  /// Get the WHERE arguments
  List<dynamic> get whereArgs => _args;

  /// Get the ORDER BY clause
  String? get orderByClause => _orderBy;

  /// Get the LIMIT clause
  int? get limitValue => _limit;

  /// Get the OFFSET clause
  int? get offsetValue => _offset;

  /// Build a complete query map for sqflite
  Map<String, dynamic> build() {
    return {
      'where': buildWhere(),
      'whereArgs': whereArgs,
      'orderBy': orderByClause,
      'limit': limitValue,
      'offset': offsetValue,
    };
  }

  /// Reset the builder
  void clear() {
    _conditions.clear();
    _args.clear();
    _orderBy = null;
    _limit = null;
    _offset = null;
  }
}

/// Extension for building queries with nullable fields
extension QueryBuilderNullable on QueryBuilder {
  /// Add equality condition only if value is not null
  QueryBuilder eqIfNotNull(String field, dynamic value) {
    if (value != null) eq(field, value);
    return this;
  }

  /// Add LIKE condition only if pattern is not null/empty
  QueryBuilder likeIfNotEmpty(String field, String? pattern) {
    if (pattern != null && pattern.isNotEmpty) like(field, pattern);
    return this;
  }

  /// Add IN condition only if list is not empty
  QueryBuilder inListIfNotEmpty(String field, List<dynamic>? values) {
    if (values != null && values.isNotEmpty) inList(field, values);
    return this;
  }
}