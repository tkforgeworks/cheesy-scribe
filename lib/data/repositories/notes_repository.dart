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

/// A local note's sync bookkeeping, as [NotesRepository.syncStamps] reports
/// it.
@immutable
class SyncStamp {
  const SyncStamp({required this.updatedAt, required this.dirty});
  final DateTime updatedAt;
  final bool dirty;
}

/// CRUD, paged listing, search and per-style counts over the `notes` table,
/// plus the sync bookkeeping the engine needs (CHEESE-58). Streams re-emit
/// whenever the table changes (drift stream queries).
///
/// Every read and write is scoped to one [owner] (CHEESE-62): the
/// signed-in account's id, or null for the notes made while signed out.
/// `notesRepositoryProvider` rebuilds the repository when the session
/// changes, so the whole app re-reads under the new scope. The few calls
/// that cross scopes (the unowned count, attaching, removing an account's
/// notes) say so in their names.
class NotesRepository {
  NotesRepository(this._db, {Uuid? uuid, DateTime Function()? now, this.owner})
    : _uuid = uuid ?? const Uuid(),
      _now = now ?? DateTime.now;

  final AppDatabase _db;
  final Uuid _uuid;
  final DateTime Function() _now;

  /// Whose notes this repository sees: an account id, or null for unowned.
  final String? owner;

  $NotesTable get _t => _db.notes;

  Expression<bool> _scope($NotesTable n) =>
      owner == null ? n.ownerUserId.isNull() : n.ownerUserId.equals(owner!);

  /// Fresh id for a note about to be saved.
  String newId() => _uuid.v4();

  /// Insert or replace a local edit: stamps [TastingNote.updatedAt] with
  /// the current time, files the row under [owner] and marks it dirty for
  /// sync. Returns the note as stored.
  Future<TastingNote> save(TastingNote note) async {
    final stamped = note.copyWith(updatedAt: _now().toUtc());
    await _db
        .into(_t)
        .insertOnConflictUpdate(
          noteToCompanion(stamped)
              .copyWith(dirty: const Value(true), ownerUserId: Value(owner)),
        );
    return stamped;
  }

  /// Deletes one of [owner]'s notes locally. An owned note leaves a
  /// tombstone so sync can delete it from the account (see [tombstones]);
  /// an unowned one has nothing on the server to delete.
  Future<void> delete(String id) => _db.transaction(() async {
    if (owner != null) {
      await _db
          .into(_db.noteTombstones)
          .insertOnConflictUpdate(
            NoteTombstonesCompanion(
              id: Value(id),
              deletedAt: Value(_now().toUtc().toIso8601String()),
              ownerUserId: Value(owner),
            ),
          );
    }
    await (_db.delete(_t)..where((n) => n.id.equals(id) & _scope(n))).go();
  });

  // --- Ownership (CHEESE-62) --------------------------------------------

  /// How many notes were made while signed out, whatever this repository's
  /// scope: the Account page offers to attach them to the signed-in
  /// account, and they come back as the notebook on sign-out.
  Stream<int> watchUnownedCount() {
    final count = _t.id.count();
    final query = _db.selectOnly(_t)
      ..addColumns([count])
      ..where(_t.ownerUserId.isNull());
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// One-shot [watchUnownedCount] (app code must not take `.first` of a
  /// drift stream: under flutter_test's fake clock it leaves the database
  /// unable to close).
  Future<int> unownedCount() async {
    final count = _t.id.count();
    final row =
        await (_db.selectOnly(_t)
              ..addColumns([count])
              ..where(_t.ownerUserId.isNull()))
            .getSingle();
    return row.read(count) ?? 0;
  }

  /// Files every unowned note under [userId] and marks it dirty, so the
  /// next sync uploads it. Returns how many moved. Keeps each note's own
  /// [TastingNote.updatedAt]: attaching is not an edit.
  Future<int> attachUnownedTo(String userId) =>
      (_db.update(_t)..where((n) => n.ownerUserId.isNull())).write(
        NotesCompanion(ownerUserId: Value(userId), dirty: const Value(true)),
      );

  /// Forgets [userId]'s notes and tombstones on this phone (sign-out,
  /// account deletion): the account keeps its copy on the server and a
  /// later sign-in downloads it again. Unowned notes are untouched.
  Future<void> removeOwned(String userId) => _db.transaction(() async {
    await (_db.delete(_t)..where((n) => n.ownerUserId.equals(userId))).go();
    await (_db.delete(
      _db.noteTombstones,
    )..where((t) => t.ownerUserId.equals(userId))).go();
  });

  // --- Sync bookkeeping -----------------------------------------------

  /// Notes changed locally since they were last pushed, oldest change first.
  Stream<List<TastingNote>> watchDirty() =>
      _dirtyQuery().watch().map((rows) => rows.map(noteFromRow).toList());

  /// One-shot [watchDirty].
  Future<List<TastingNote>> dirtyNotes() async =>
      (await _dirtyQuery().get()).map(noteFromRow).toList();

  SimpleSelectStatement<$NotesTable, NoteRow> _dirtyQuery() => _db.select(_t)
    ..where((n) => n.dirty.equals(true) & _scope(n))
    ..orderBy([
      (n) => OrderingTerm.asc(n.updatedAt),
      (n) => OrderingTerm.asc(n.id),
    ]);

  /// The local stamp and dirty flag of each of [ids] that exists in this
  /// scope, for the sync's manifest diff.
  Future<Map<String, SyncStamp>> syncStamps(Iterable<String> ids) async {
    final rows =
        await (_db.selectOnly(_t)
              ..addColumns([_t.id, _t.updatedAt, _t.dirty])
              ..where(_t.id.isIn(ids) & _scope(_t)))
            .get();
    return {
      for (final r in rows)
        r.read(_t.id)!: SyncStamp(
          updatedAt: DateTime.parse(r.read(_t.updatedAt)!),
          dirty: r.read(_t.dirty)!,
        ),
    };
  }

  /// Clears the dirty flag on [pushed], but only where the row still carries
  /// the same [TastingNote.updatedAt]: an edit made while the push was in
  /// flight stays dirty for the next one.
  Future<void> markClean(Iterable<TastingNote> pushed) => _db.batch((b) {
    for (final n in pushed) {
      b.update(
        _t,
        const NotesCompanion(dirty: Value(false)),
        where: (t) =>
            t.id.equals(n.id) &
            t.updatedAt.equals(n.updatedAt.toUtc().toIso8601String()),
      );
    }
  });

  /// Writes notes received from the account as they are, keeping their own
  /// [TastingNote.updatedAt], filed under [owner] and clean. Never stamps.
  Future<void> applyRemote(Iterable<TastingNote> notes) => _db.batch((b) {
    b.insertAllOnConflictUpdate(_t, [
      for (final n in notes)
        noteToCompanion(n)
            .copyWith(dirty: const Value(false), ownerUserId: Value(owner)),
    ]);
  });

  /// Removes notes the account says were deleted, without tombstones.
  Future<void> applyRemoteDeletions(Iterable<String> ids) =>
      (_db.delete(_t)..where((n) => n.id.isIn(ids) & _scope(n))).go();

  /// Local deletions of [owner]'s notes not yet pushed, oldest first.
  Future<List<NoteTombstone>> tombstones() async {
    final rows =
        await (_db.select(_db.noteTombstones)
              ..where(
                (t) => owner == null
                    ? t.ownerUserId.isNull()
                    : t.ownerUserId.equals(owner!),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.deletedAt),
                (t) => OrderingTerm.asc(t.id),
              ]))
            .get();
    return [
      for (final r in rows)
        NoteTombstone(id: r.id, deletedAt: DateTime.parse(r.deletedAt)),
    ];
  }

  /// How many of [owner]'s deletions wait to be pushed (the coordinator's
  /// trigger for a sync after a delete).
  Stream<int> watchTombstoneCount() {
    final t = _db.noteTombstones;
    final count = t.id.count();
    final query = _db.selectOnly(t)
      ..addColumns([count])
      ..where(
        owner == null ? t.ownerUserId.isNull() : t.ownerUserId.equals(owner!),
      );
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Forgets tombstones once their deletion reached the account.
  Future<void> clearTombstones(Iterable<String> ids) =>
      (_db.delete(_db.noteTombstones)..where((t) => t.id.isIn(ids))).go();

  Future<TastingNote?> getNote(String id) async {
    final row = await (_db.select(
      _t,
    )..where((n) => n.id.equals(id) & _scope(n))).getSingleOrNull();
    return row == null ? null : noteFromRow(row);
  }

  /// Emits null once the note is deleted (the detail screen pops on it).
  Stream<TastingNote?> watchNote(String id) =>
      (_db.select(_t)..where((n) => n.id.equals(id) & _scope(n)))
          .watchSingleOrNull()
          .map((row) => row == null ? null : noteFromRow(row));

  /// One page, newest tasting first (ties by creation time).
  Stream<List<TastingNote>> watchPage(NotesQuery q) {
    final query = _db.select(_t)
      ..where((n) => _scope(n) & _where(n, q))
      ..orderBy(_newestFirst)
      ..limit(q.limit, offset: q.offset);
    return query.watch().map((rows) => rows.map(noteFromRow).toList());
  }

  /// Total matches for [q], ignoring its paging.
  Stream<int> watchCount(NotesQuery q) {
    final count = _t.id.count();
    final query = _db.selectOnly(_t)
      ..addColumns([count])
      ..where(_scope(_t) & _where(_t, q));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  /// Every note, newest first (stats).
  Stream<List<TastingNote>> watchAll() =>
      (_db.select(_t)
            ..where(_scope)
            ..orderBy(_newestFirst))
          .watch()
          .map((rows) => rows.map(noteFromRow).toList());

  /// The featured card's note.
  Stream<TastingNote?> watchNewest() =>
      (_db.select(_t)
            ..where(_scope)
            ..orderBy(_newestFirst)
            ..limit(1))
          .watchSingleOrNull()
          .map((row) => row == null ? null : noteFromRow(row));

  /// `cheeseStyleId` -> number of notes linked to it ("12 TASTED").
  Stream<Map<String, int>> watchStyleCounts() {
    final count = _t.id.count();
    final query = _db.selectOnly(_t)
      ..addColumns([_t.cheeseStyleId, count])
      ..where(_scope(_t) & _t.cheeseStyleId.isNotNull())
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
