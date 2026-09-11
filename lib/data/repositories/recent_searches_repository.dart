import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// The search view's "recent searches" list, most recent first, capped.
class RecentSearchesRepository {
  RecentSearchesRepository(this._db, {this.cap = 10});

  final AppDatabase _db;
  final int cap;

  $RecentSearchesTable get _t => _db.recentSearches;

  Stream<List<String>> watch() =>
      (_db.select(_t)..orderBy([(r) => OrderingTerm.desc(r.searchedAt)]))
          .watch()
          .map((rows) => rows.map((r) => r.term).toList());

  /// Records [term] (trimmed; blanks ignored), bumping it to the top and
  /// dropping the oldest beyond [cap].
  Future<void> add(String term) async {
    final t = term.trim();
    if (t.isEmpty) return;
    await _db.transaction(() async {
      await _db
          .into(_t)
          .insertOnConflictUpdate(
            RecentSearchesCompanion.insert(
              term: t,
              searchedAt: DateTime.now().toUtc().toIso8601String(),
            ),
          );
      final rows = await (_db.select(
        _t,
      )..orderBy([(r) => OrderingTerm.desc(r.searchedAt)])).get();
      for (final stale in rows.skip(cap)) {
        await (_db.delete(_t)..where((r) => r.term.equals(stale.term))).go();
      }
    });
  }

  Future<void> remove(String term) =>
      (_db.delete(_t)..where((r) => r.term.equals(term))).go();

  Future<void> clear() => _db.delete(_t).go();
}
