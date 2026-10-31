import 'dart:io';

import 'package:cheesy_scribe/data/db/app_database.dart';
import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/data/repositories/sync_meta_repository.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The DDL the released v0.1.0 (schema 1) and v0.2.0 (schema 2) builds
/// wrote; v2 changed no table. Frozen here on purpose: a migration test has
/// to start from what shipped, not from what `createAll` would make today.
const _releasedDdl = [
  'CREATE TABLE "notes" ("id" TEXT NOT NULL, "cheese_name" TEXT NOT NULL, '
      '"tasted_at" TEXT NOT NULL, "created_at" TEXT NOT NULL, '
      '"creamery" TEXT NULL, "origin" TEXT NULL, "rind" TEXT NULL, '
      '"rind_other" TEXT NULL, "price" REAL NULL, "price_unit" TEXT NOT NULL, '
      '"milk" TEXT NOT NULL, "milk_other" TEXT NULL, '
      '"is_grassfed" INTEGER NOT NULL DEFAULT 0 CHECK ("is_grassfed" IN (0, 1)), '
      '"is_raw" INTEGER NOT NULL DEFAULT 0 CHECK ("is_raw" IN (0, 1)), '
      '"attribute_other" TEXT NULL, "rating" INTEGER NOT NULL DEFAULT 0, '
      '"texture" TEXT NOT NULL, "notes" TEXT NOT NULL DEFAULT \'\', '
      '"verdict" TEXT NULL, "fl_salty" INTEGER NOT NULL DEFAULT 0, '
      '"fl_sweet" INTEGER NOT NULL DEFAULT 0, '
      '"fl_sharp_tangy" INTEGER NOT NULL DEFAULT 0, '
      '"fl_lemon" INTEGER NOT NULL DEFAULT 0, '
      '"fl_grassy" INTEGER NOT NULL DEFAULT 0, '
      '"fl_herbal" INTEGER NOT NULL DEFAULT 0, '
      '"fl_caramel" INTEGER NOT NULL DEFAULT 0, '
      '"fl_nutty" INTEGER NOT NULL DEFAULT 0, '
      '"fl_earthy" INTEGER NOT NULL DEFAULT 0, '
      '"fl_moldy_blue" INTEGER NOT NULL DEFAULT 0, '
      '"fl_stinky" INTEGER NOT NULL DEFAULT 0, '
      '"fl_robust" INTEGER NOT NULL DEFAULT 0, '
      '"fl_buttery_creamy" INTEGER NOT NULL DEFAULT 0, '
      '"fl_milky_lactic" INTEGER NOT NULL DEFAULT 0, '
      '"fl_crumbly" INTEGER NOT NULL DEFAULT 0, '
      '"fl_crystalline" INTEGER NOT NULL DEFAULT 0, '
      '"cheese_style_id" TEXT NULL, "photo_url" TEXT NULL, '
      '"search_text" TEXT NOT NULL, PRIMARY KEY ("id"))',
  'CREATE TABLE "recent_searches" ("term" TEXT NOT NULL, '
      '"searched_at" TEXT NOT NULL, PRIMARY KEY ("term"))',
  'CREATE TABLE "settings" ("key" TEXT NOT NULL, "value" TEXT NOT NULL, '
      'PRIMARY KEY ("key"))',
  'CREATE INDEX notes_by_date ON notes (tasted_at, created_at)',
  'CREATE INDEX notes_by_style ON notes (cheese_style_id)',
];

/// Opens [file] as a database at a released schema version, created from
/// [_releasedDdl] rather than from today's table classes.
class _ReleasedDatabase extends GeneratedDatabase {
  _ReleasedDatabase(File file, this.schemaVersion)
    : super(NativeDatabase(file));

  @override
  final int schemaVersion;

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      for (final sql in _releasedDdl) {
        await customStatement(sql);
      }
    },
  );

  /// A note as an old build wrote it, with the haystack of its day.
  Future<void> insertNote({
    required String id,
    required String name,
    required String createdAt,
    required String searchText,
    int lemon = 0,
  }) => customInsert(
    'INSERT INTO notes (id, cheese_name, tasted_at, created_at, price_unit, '
    'milk, texture, fl_lemon, search_text) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
    variables: [
      Variable(id),
      Variable(name),
      Variable('2026-07-27'),
      Variable(createdAt),
      Variable('usdPerLb'),
      Variable('cow'),
      Variable('semiSoft'),
      Variable(lemon),
      Variable(searchText),
    ],
  );
}

/// Today's database held at schema v4: opening it over a released file
/// runs the real v3 and v4 steps and stops, which is exactly the state of a
/// phone that upgraded to 0.3.0.
class _V4Database extends AppDatabase {
  _V4Database(super.executor);

  @override
  int get schemaVersion => 4;
}

Future<List<String>> _columns(GeneratedDatabase db) async {
  final rows = await db.customSelect('PRAGMA table_info(notes)').get();
  return [for (final r in rows) r.data['name'] as String];
}

void main() {
  late File file;

  setUp(() async {
    final dir = await Directory.systemTemp.createTemp('cheesy-migration');
    addTearDown(() => dir.delete(recursive: true));
    file = File('${dir.path}/cheesy_scribe.sqlite');
  });

  Future<void> seedReleased(int version) async {
    final old = _ReleasedDatabase(file, version);
    await old.insertNote(
      id: 'fog',
      name: 'Humboldt Fog',
      createdAt: '2026-07-27T18:00:00.000Z',
      searchText: version < 2 ? 'humboldt fog lemon' : 'humboldt fog citrus',
      lemon: 4,
    );
    await old.close();
  }

  Future<AppDatabase> upgradedFrom(int version) async {
    await seedReleased(version);
    final db = AppDatabase(NativeDatabase(file));
    addTearDown(db.close);
    return db;
  }

  test(
    'upgrading from v1 rebuilds the search text (LEMON is now CITRUS)',
    () async {
      final db = await upgradedFrom(1);
      final repo = NotesRepository(db);
      Future<List<String>> ids(String search) async => [
        for (final n in await repo.watchPage(NotesQuery(search: search)).first)
          n.id,
      ];

      expect(await ids('citrus'), ['fog']);
      expect(await ids('lemon'), isEmpty);
      expect(await ids('humboldt'), ['fog']);
    },
  );

  test('upgrading from v2 adds the sync bookkeeping (CHEESE-58)', () async {
    final db = await upgradedFrom(2);
    final repo = NotesRepository(db);

    // Existing notes: last change = creation, and dirty for the first push.
    final fog = (await repo.getNote('fog'))!;
    expect(fog.updatedAt, DateTime.utc(2026, 7, 27, 18));
    expect((await repo.dirtyNotes()).map((n) => n.id), ['fog']);
    // The v2 haystack is untouched (searchTextVersion is still 2).
    expect(
      (await repo.watchPage(const NotesQuery(search: 'citrus')).first).length,
      1,
    );

    // The new tables work (deleting an owned note leaves a tombstone;
    // 'fog' is unowned after the upgrade, so attach it first).
    final tim = NotesRepository(db, owner: 'tim');
    await tim.attachUnownedTo('tim');
    await tim.delete('fog');
    expect((await tim.tombstones()).map((t) => t.id), ['fog']);
    final meta = SyncMetaRepository(db);
    await meta.set('last_sync_at', 'never');
    expect(await meta.get('last_sync_at'), 'never');

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 5);
  });

  test(
    'upgrading from v4 drops the never-used photo_url (CHEESE-82)',
    () async {
      // A phone that shipped 0.3.0: the released DDL upgraded through v3 and
      // v4 (the real steps, pinned to stop there), with a photo_url value
      // nothing in the app could have written, to prove the drop is clean.
      await seedReleased(2);
      final v4 = _V4Database(NativeDatabase(file));
      await v4.customStatement(
        "UPDATE notes SET photo_url = 'https://example.com/fog.jpg' "
        "WHERE id = 'fog'",
      );
      expect(await _columns(v4), contains('photo_url'));
      await v4.close();

      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);
      expect(await _columns(db), isNot(contains('photo_url')));
      expect(await _columns(db), containsAll(['owner_user_id', 'updated_at']));
      final fog = (await NotesRepository(db).getNote('fog'))!;
      expect(fog.cheeseName, 'Humboldt Fog');
      expect(fog.flavorScore(FlavorNote.lemon), 4);
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.data.values.single, 5);
    },
  );

  test('upgrading from v2 leaves existing notes unowned (CHEESE-62)', () async {
    final db = await upgradedFrom(2);
    // Signed out, the notebook still shows them; an account sees nothing
    // until the user attaches them.
    final anon = NotesRepository(db);
    final tim = NotesRepository(db, owner: 'tim');
    expect((await anon.watchAll().first).map((n) => n.id), ['fog']);
    expect(await tim.watchAll().first, isEmpty);
    expect(await tim.watchUnownedCount().first, 1);
    expect(await tim.attachUnownedTo('tim'), 1);
    expect((await tim.watchAll().first).map((n) => n.id), ['fog']);
    expect(await anon.watchAll().first, isEmpty);
    // Tombstones carry the owner too.
    await tim.delete('fog');
    expect((await tim.tombstones()).map((t) => t.id), ['fog']);
    expect(await anon.tombstones(), isEmpty);
  });
}
