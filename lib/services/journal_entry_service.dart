// lib/services/journal_entry_service.dart

import 'package:sqflite/sqflite.dart';
import '../models/finance_models.dart';
import 'base_repository.dart';
import 'audit_service.dart';
import '../constants/entity_types.dart';
import 'query_builder.dart';

class JournalEntryService extends BaseRepository<JournalEntry> {
  final Database db;
  final AuditService auditService;

  JournalEntryService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'journal_entries',
          entityType: EntityTypes.journalEntry,
          fromMap: (m) => JournalEntry.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(JournalEntry entity) => entity.toMap();

  @override
  int? getId(JournalEntry entity) => entity.id;

  @override
  JournalEntry setId(JournalEntry entity, int id) => entity..id = id;

  Future<JournalEntry?> getJournalEntry(int id) async => getById(id);

  Future<List<JournalEntry>> getJournalEntries({
    String? status,
    int? fromDate,
    int? toDate,
    int limit = 100,
    int offset = 0,
  }) async {
    final query = QueryBuilder.where();
    if (status != null) query.eq('status', status);
    if (fromDate != null) query.gte('entry_date', fromDate);
    if (toDate != null) query.lte('entry_date', toDate);
    query.orderBy('entry_date', descending: true);
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

  Future<int> createJournalEntry(JournalEntry entry, {int? userId}) async {
    return await create(entry,
        action: 'create_journal_entry',
        detail: 'Created journal entry ${entry.entryNumber}',
        userId: userId);
  }

  Future<int> updateJournalEntry(JournalEntry entry, {int? userId}) async {
    return await update(entry,
        action: 'update_journal_entry',
        detail: 'Updated journal entry ${entry.entryNumber}',
        userId: userId);
  }

  Future<int> postJournalEntry(int entryId, int postedBy, {int? userId}) async {
    return await transaction((txn) async {
      final count = await txn.update(tableName, {
        'status': 'POSTED',
        'posted_at': DateTime.now().millisecondsSinceEpoch,
        'posted_by': postedBy,
      }, where: 'id = ?', whereArgs: [entryId]);
      if (count == 0) throw StateError('Journal entry not found');
      await auditService.logInTransaction(
        txn,
        action: 'post_journal_entry',
        detail: 'Posted journal entry $entryId',
        entityType: EntityTypes.journalEntry,
        entityId: entryId,
        userId: userId ?? postedBy,
      );
      return entryId;
    });
  }
}

class JournalEntryLineService extends BaseRepository<JournalEntryLine> {
  final Database db;
  final AuditService auditService;

  JournalEntryLineService(this.db, {AuditService? auditService})
      : auditService = auditService ?? AuditService(db),
        super(
          db: db,
          tableName: 'journal_entry_lines',
          entityType: EntityTypes.journalEntryLine,
          fromMap: (m) => JournalEntryLine.fromMap(m),
          auditService: auditService,
        );

  @override
  Map<String, dynamic> toMap(JournalEntryLine entity) => entity.toMap();

  @override
  int? getId(JournalEntryLine entity) => entity.id;

  @override
  JournalEntryLine setId(JournalEntryLine entity, int id) => entity..id = id;

  Future<List<JournalEntryLine>> getJournalEntryLines(int entryId) async {
    final query = QueryBuilder.where().eq('entry_id', entryId);
    final queryMap = query.build();
    return list(
      where: queryMap['where'],
      whereArgs: queryMap['whereArgs'],
      orderBy: queryMap['orderBy'],
      limit: queryMap['limit'],
      offset: queryMap['offset'],
    );
  }

  Future<int> addJournalEntryLine(JournalEntryLine line, {int? userId}) async {
    return await create(line,
        action: 'add_journal_entry_line',
        detail: 'Added line to journal entry ${line.entryId}',
        userId: userId);
  }

  Future<void> addJournalEntryLines(int entryId, List<JournalEntryLine> lines, {int? userId}) async {
    await transaction((txn) async {
      for (final line in lines) {
        final map = line.toMap();
        map['entry_id'] = entryId;
        await txn.insert(tableName, map);
      }
      await auditService.logInTransaction(
        txn,
        action: 'add_journal_entry_lines',
        detail: 'Added ${lines.length} lines to journal entry $entryId',
        entityType: EntityTypes.journalEntryLine,
        entityId: entryId,
        userId: userId,
      );
    });
  }

  Future<int> updateJournalEntryLine(JournalEntryLine line, {int? userId}) async {
    return await update(line,
        action: 'update_journal_entry_line',
        detail: 'Updated journal entry line',
        userId: userId);
  }
}