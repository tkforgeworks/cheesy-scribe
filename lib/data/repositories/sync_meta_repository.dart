import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Key/value state for the sync engine (`sync_meta`, CHEESE-58): last sync
/// time, last error, and whatever else the engine needs to resume. Separate
/// from settings so a settings save never touches it.
class SyncMetaRepository {
  SyncMetaRepository(this._db);

  final AppDatabase _db;

  $SyncMetaTable get _t => _db.syncMeta;

  Future<String?> get(String key) async => (await (_db.select(
    _t,
  )..where((r) => r.key.equals(key))).getSingleOrNull())?.value;

  Stream<String?> watch(String key) => (_db.select(
    _t,
  )..where((r) => r.key.equals(key))).watchSingleOrNull().map((r) => r?.value);

  /// Sets [key]; a null [value] removes it.
  Future<void> set(String key, String? value) async {
    if (value == null) {
      await (_db.delete(_t)..where((r) => r.key.equals(key))).go();
    } else {
      await _db
          .into(_t)
          .insertOnConflictUpdate(
            SyncMetaCompanion(key: Value(key), value: Value(value)),
          );
    }
  }

  /// Forgets all sync state (sign-out, erase).
  Future<void> clear() => _db.delete(_t).go();
}
