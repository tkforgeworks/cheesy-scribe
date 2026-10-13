import '../db/app_database.dart';
import '../models/models.dart';

/// [AppSettings] persisted as key/value rows (keys = `toJson` keys).
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Stream<AppSettings> watch() =>
      _db.select(_db.settings).watch().map(_fromRows);

  Future<AppSettings> load() async =>
      _fromRows(await _db.select(_db.settings).get());

  /// Writes every key; keys absent from [settings] (a cleared display
  /// name) are removed so the defaults apply again.
  Future<void> save(AppSettings settings) => _db.transaction(() async {
    final json = settings.toJson();
    await _db.delete(_db.settings).go();
    for (final e in json.entries) {
      await _db
          .into(_db.settings)
          .insert(
            SettingsCompanion.insert(key: e.key, value: e.value as String),
          );
    }
  });

  Future<void> update(AppSettings Function(AppSettings) change) async =>
      save(change(await load()));

  static AppSettings _fromRows(List<SettingRow> rows) =>
      AppSettings.fromJson({for (final r in rows) r.key: r.value});
}
