import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// The search view's "recent searches" list, most recent first, capped.
class RecentSearchesRepository {
  RecentSearchesRepository(this._db, {this.cap = 10, DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _db;
  final int cap;

  /// Injectable clock: the stamps drive the profile sync's "later side".
  final DateTime Function() _now;

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
              searchedAt: _now().toUtc().toIso8601String(),
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

  /// Every term with when it was searched, most recent first (the sync's
  /// profile payload and its "when did this change" stamp).
  Future<List<(String term, DateTime at)>> entries() async {
    final rows = await (_db.select(
      _t,
    )..orderBy([(r) => OrderingTerm.desc(r.searchedAt)])).get();
    return [for (final r in rows) (r.term, DateTime.parse(r.searchedAt))];
  }

  /// Replaces the list with [terms] (most recent first) as received from
  /// the account, stamped just before [at] in descending order so the
  /// order survives and the list does not look newer than the server's.
  Future<void> replaceAll(List<String> terms, {required DateTime at}) =>
      _db.transaction(() async {
        await _db.delete(_t).go();
        for (final (i, term) in terms.take(cap).indexed) {
          await _db
              .into(_t)
              .insertOnConflictUpdate(
                RecentSearchesCompanion.insert(
                  term: term,
                  searchedAt: at
                      .toUtc()
                      .subtract(Duration(seconds: i))
                      .toIso8601String(),
                ),
              );
        }
      });

  Future<void> remove(String term) =>
      (_db.delete(_t)..where((r) => r.term.equals(term))).go();

  Future<void> clear() => _db.delete(_t).go();
}
