import 'dart:io';

import 'package:cheesy_scribe/data/db/app_database.dart';
import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The released v0.1.0 schema: same tables, version 1.
class _V1Database extends AppDatabase {
  _V1Database(super.executor);

  @override
  int get schemaVersion => 1;
}

void main() {
  test(
    'upgrading from v1 rebuilds the search text (LEMON is now CITRUS)',
    () async {
      final dir = await Directory.systemTemp.createTemp('cheesy-migration');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/cheesy_scribe.sqlite');

      final v1 = _V1Database(NativeDatabase(file));
      await NotesRepository(v1).save(
        TastingNote(
          id: 'fog',
          cheeseName: 'Humboldt Fog',
          tastedAt: DateTime(2026, 7, 27),
          createdAt: DateTime.utc(2026, 7, 27, 18),
          flavors: const {FlavorNote.lemon: 4},
        ),
      );
      // The haystack a v1 build wrote, with the old label.
      await v1.customStatement(
        "UPDATE notes SET search_text = 'humboldt fog lemon'",
      );
      await v1.close();

      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);
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
}
