import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart';
import '../db/search_text.dart';
import '../models/models.dart';

/// What the home list / search view asks for. Everything is ANDed.
@immutable
class NotesQuery {
  const NotesQuery({
    this.search = '',
    this.minRating = 0,
    this.styleId,
    this.limit = 20,
    this.offset = 0,
  });

  /// Free text; every word must appear in the note's search haystack.
  final String search;

  /// 0 = any; 4 = the "4★ and up" chip.
  final int minRating;
  final String? styleId;
  final int limit;
  final int offset;

  NotesQuery copyWith({
    String? search,
    int? minRating,
    Object? styleId = _unset,
    int? limit,
    int? offset,
  }) => NotesQuery(
    search: search ?? this.search,
    minRating: minRating ?? this.minRating,
    styleId: identical(styleId, _unset) ? this.styleId : styleId as String?,
    limit: limit ?? this.limit,
    offset: offset ?? this.offset,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotesQuery &&
          other.search == search &&
          other.minRating == minRating &&
          other.styleId == styleId &&
          other.limit == limit &&
          other.offset == offset;

  @override
  int get hashCode => Object.hash(search, minRating, styleId, limit, offset);
}

const _unset = Object();

/// CRUD, paged listing, search and per-style counts over the `notes` table.
/// Streams re-emit whenever the table changes (drift stream queries).
class NotesRepository {
  NotesRepository(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  $NotesTable get _t => _db.notes;

  /// Fresh id for a note about to be saved.
  String newId() => _uuid.v4();

  /// Insert or replace.
  Future<TastingNote> save(TastingNote note) async {
    await _db.into(_t).insertOnConflictUpdate(noteToCompanion(note));
    return note;
  }

  Future<void> delete(String id) =>
      (_db.delete(_t)..where((n) => n.id.equals(id))).go();

  Future<TastingNote?> getNote(String id) async {
    final row = await (_db.select(
      _t,
    )..where((n) => n.id.equals(id))).getSingleOrNull();
    return row == null ? null : noteFromRow(row);
  }

  /// Emits null once the note is deleted (the detail screen pops on it).
  Stream<TastingNote?> watchNote(String id) =>
      (_db.select(_t)..where((n) => n.id.equals(id))).watchSingleOrNull().map(
        (row) => row == null ? null : noteFromRow(row),
      );

  /// One page, newest tasting first (ties by creation time).
  Stream<List<TastingNote>> watchPage(NotesQuery q) {
    final query = _db.select(_t)
      ..where((n) => _where(n, q))
      ..orderBy(_newestFirst)
      ..limit(q.limit, offset: q.offset);
    return query.watch().map((rows) => rows.map(noteFromRow).toList());
  }

  /// Total matches for [q], ignoring its paging.
  Stream<int> watchCount(NotesQuery q) {
    final count = _t.id.count();
    final query = _db.selectOnly(_t)
      ..addColumns([count])
      ..where(_where(_t, q));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Every note, newest first (stats, CSV export).
  Stream<List<TastingNote>> watchAll() =>
      (_db.select(_t)..orderBy(_newestFirst)).watch().map(
        (rows) => rows.map(noteFromRow).toList(),
      );

  /// The featured card's note.
  Stream<TastingNote?> watchNewest() =>
      (_db.select(_t)
            ..orderBy(_newestFirst)
            ..limit(1))
          .watchSingleOrNull()
          .map((row) => row == null ? null : noteFromRow(row));

  /// `cheeseStyleId` -> number of notes linked to it ("12 TASTED").
  Stream<Map<String, int>> watchStyleCounts() {
    final count = _t.id.count();
    final query = _db.selectOnly(_t)
      ..addColumns([_t.cheeseStyleId, count])
      ..where(_t.cheeseStyleId.isNotNull())
      ..groupBy([_t.cheeseStyleId]);
    return query.watch().map(
      (rows) => {
        for (final r in rows) r.read(_t.cheeseStyleId)!: r.read(count) ?? 0,
      },
    );
  }

  /// Style ids by note count, highest first — the Home filter chips.
  Stream<List<String>> watchTopStyleIds({int limit = 4}) =>
      watchStyleCounts().map((counts) {
        final entries = counts.entries.toList()
          ..sort((a, b) {
            final byCount = b.value.compareTo(a.value);
            return byCount != 0 ? byCount : a.key.compareTo(b.key);
          });
        return entries.take(limit).map((e) => e.key).toList();
      });

  static final List<OrderingTerm Function($NotesTable)> _newestFirst = [
    (n) => OrderingTerm.desc(n.tastedAt),
    (n) => OrderingTerm.desc(n.createdAt),
  ];

  static Expression<bool> _where($NotesTable n, NotesQuery q) {
    Expression<bool> expr = const Constant(true);
    if (q.minRating > 0) {
      expr = expr & n.rating.isBiggerOrEqualValue(q.minRating);
    }
    if (q.styleId != null) {
      expr = expr & n.cheeseStyleId.equals(q.styleId!);
    }
    for (final token in searchTokens(q.search)) {
      // Tokens are normalised to [a-z0-9], so no LIKE escaping is needed.
      expr = expr & n.searchText.like('%$token%');
    }
    return expr;
  }
}
