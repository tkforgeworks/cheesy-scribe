import 'dart:convert';
import 'dart:io';

import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/library_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

const assetPath = 'assets/data/cheese_styles.json';
const schemaPath =
    'docs/design_handoff_cheesy_scribe/schema/cheese-style.schema.json';

/// Examples from the hi-fi mockups; the six mocked styles keep them.
const mockedExamples = {
  'alpine': 'Comté, Gruyère, Appenzeller',
  'blue': 'Stilton, Roquefort, Rogue River',
  'bloomy-rind': 'Brie, Camembert, Humboldt Fog',
  'washed-rind': 'Époisses, Taleggio, Limburger',
  'fresh': 'Chèvre, Burrata, Ricotta',
  'hard-aged': 'Parmigiano, Manchego, Gouda',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final raw = jsonDecode(File(assetPath).readAsStringSync()) as List<dynamic>;

  test('every entry validates against the schema, ids unique slugs', () {
    final schema = JsonSchema.create(
      jsonDecode(File(schemaPath).readAsStringSync()),
      schemaVersion: SchemaVersion.draft2020_12,
    );
    final ids = <String>{};
    for (final entry in raw) {
      final result = schema.validate(entry);
      expect(result.errors, isEmpty, reason: '$entry\n${result.errors}');
      final id = (entry as Map<String, dynamic>)['id'] as String;
      expect(ids.add(id), isTrue, reason: 'duplicate id $id');
      expect(entry['description'], isNotEmpty);
      expect(
        (entry['examples'] as String).split(',').length,
        inInclusiveRange(1, 3),
      );
    }
    expect(raw.length, inInclusiveRange(25, 35));
  });

  test('the six mocked styles keep the mocked examples', () {
    final byId = {
      for (final e in raw.cast<Map<String, dynamic>>()) e['id']: e['examples'],
    };
    mockedExamples.forEach((id, examples) {
      expect(byId[id], examples, reason: id);
    });
  });

  test('repository loads from the asset bundle, caches, finds by id', () async {
    final repo = LibraryRepository();
    final styles = await repo.load();
    expect(styles.length, raw.length);
    expect(identical(await repo.load(), styles), isTrue);
    expect(styles.first.id, raw.first['id']);
    final alpine = await repo.byId('alpine');
    expect(alpine?.name, 'Alpine');
    expect(alpine?.typicalMilk, [MilkType.cow]);
    expect(alpine?.typicalTexture, TextureLevel.firm);
    expect(await repo.byId('nope'), isNull);
  });

  test('search matches name and examples, folding diacritics', () async {
    final styles = await LibraryRepository().load();
    List<String> ids(String q) =>
        LibraryRepository.search(styles, q).map((s) => s.id).toList();
    expect(ids('gruy'), ['alpine']);
    expect(ids('epoisses'), ['washed-rind']);
    expect(ids('BLUE'), containsAll(['blue', 'soft-blue']));
    expect(ids('rind washed'), ['washed-rind']);
    expect(ids(''), hasLength(styles.length));
    expect(ids('zzz'), isEmpty);
  });
}
