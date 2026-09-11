import 'package:cheesy_scribe/data/db/search_text.dart';
import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/data/repositories/recent_searches_repository.dart';
import 'package:cheesy_scribe/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';

import '../support.dart';

TastingNote note(
  String id,
  String name, {
  DateTime? tastedAt,
  DateTime? createdAt,
  String? creamery,
  String? origin,
  int rating = 0,
  String? styleId,
  String notes = '',
  Map<FlavorNote, int> flavors = const {},
}) => TastingNote(
  id: id,
  cheeseName: name,
  tastedAt: tastedAt ?? DateTime(2026, 8, 1),
  createdAt: createdAt ?? DateTime.utc(2026, 8, 1, 12),
  creamery: creamery,
  origin: origin,
  rating: rating,
  cheeseStyleId: styleId,
  notes: notes,
  flavors: flavors,
);

void main() {
  group('normalizeForSearch', () {
    test('folds case, diacritics and punctuation', () {
      expect(normalizeForSearch('Époisses'), 'epoisses');
      expect(normalizeForSearch('  Comté 24 mo.  '), 'comte 24 mo');
      expect(normalizeForSearch('SHARP/TANGY'), 'sharp tangy');
      expect(searchTokens('Sheep,  Spain'), ['sheep', 'spain']);
      expect(searchTokens('   '), isEmpty);
    });
  });

  group('NotesRepository', () {
    late NotesRepository repo;

    setUp(() => repo = NotesRepository(openTestDatabase()));

    test('save, get, update in place, delete', () async {
      final n = note('a', 'Comté', rating: 4);
      await repo.save(n);
      expect(await repo.getNote('a'), n);
      await repo.save(n.copyWith(rating: 5, verdict: 'Yes.'));
      expect((await repo.getNote('a'))!.rating, 5);
      expect(await repo.watchCount(const NotesQuery()).first, 1);
      await repo.delete('a');
      expect(await repo.getNote('a'), isNull);
      expect(repo.newId(), isNot(equals(repo.newId())));
    });

    test('round-trips every field through the row mapping', () async {
      final full = TastingNote(
        id: 'full',
        cheeseName: 'Époisses',
        tastedAt: DateTime(2026, 8, 12),
        createdAt: DateTime.utc(2026, 8, 12, 19, 30, 5),
        creamery: 'Berthaut',
        origin: 'Burgundy',
        rind: RindType.washed,
        rindOther: null,
        price: 28.5,
        priceUnit: PriceUnit.eurPerKg,
        milk: MilkType.goat,
        milkOther: 'Half goat',
        isGrassfed: true,
        isRaw: true,
        attributeOther: 'Cave-aged',
        rating: 3,
        texture: TextureLevel.runny,
        notes: 'Loud.',
        verdict: 'A dare.',
        flavors: const {FlavorNote.stinky: 5, FlavorNote.crystalline: 1},
        cheeseStyleId: 'washed-rind',
        photoUrl: 'https://example.com/e.jpg',
      );
      await repo.save(full);
      expect(await repo.getNote('full'), full);
    });

    test('pages newest first with createdAt as tiebreak', () async {
      await repo.save(note('old', 'Old', tastedAt: DateTime(2026, 7, 1)));
      await repo.save(
        note(
          'same-early',
          'Same day, saved first',
          tastedAt: DateTime(2026, 8, 1),
          createdAt: DateTime.utc(2026, 8, 1, 9),
        ),
      );
      await repo.save(
        note(
          'same-late',
          'Same day, saved later',
          tastedAt: DateTime(2026, 8, 1),
          createdAt: DateTime.utc(2026, 8, 1, 18),
        ),
      );
      await repo.save(note('new', 'New', tastedAt: DateTime(2026, 9, 1)));

      final ids = (await repo.watchPage(const NotesQuery()).first)
          .map((n) => n.id)
          .toList();
      expect(ids, ['new', 'same-late', 'same-early', 'old']);
      final page2 = await repo
          .watchPage(const NotesQuery(limit: 2, offset: 2))
          .first;
      expect(page2.map((n) => n.id), ['same-early', 'old']);
      expect((await repo.watchNewest().first)!.id, 'new');
      expect((await repo.watchAll().first).length, 4);
    });

    test('search is case- and diacritic-insensitive across fields', () async {
      await repo.save(note('e', 'Époisses', origin: 'Burgundy, France'));
      await repo.save(
        note(
          'c',
          'Comté',
          creamery: 'Marcel Petite',
          notes: 'Brothy and long.',
          flavors: const {FlavorNote.nutty: 4},
        ),
      );
      await repo.save(note('m', 'Manchego', origin: 'La Mancha, Spain'));

      Future<List<String>> find(String q) async =>
          (await repo.watchPage(NotesQuery(search: q)).first)
              .map((n) => n.id)
              .toList();

      expect(await find('epoisses'), ['e']);
      expect(await find('ÉPOISSES'), ['e']);
      expect(await find('france'), ['e']);
      expect(await find('petite'), ['c']);
      expect(await find('brothy'), ['c']);
      expect(await find('nutty'), ['c']);
      expect(await find('mancha spain'), ['m']);
      expect(await find('spain burgundy'), isEmpty);
      expect(await find(''), hasLength(3));
      expect(await repo.watchCount(const NotesQuery(search: 'spain')).first, 1);
    });

    test('filters by minimum rating and style', () async {
      // Tasted on successive days so "newest first" is 1, 2, 3, 4.
      final day = DateTime(2026, 8, 10);
      await repo.save(
        note('1', 'One', rating: 5, styleId: 'alpine', tastedAt: day),
      );
      await repo.save(
        note(
          '2',
          'Two',
          rating: 4,
          styleId: 'blue',
          tastedAt: day.subtract(const Duration(days: 1)),
        ),
      );
      await repo.save(
        note(
          '3',
          'Three',
          rating: 3,
          styleId: 'alpine',
          tastedAt: day.subtract(const Duration(days: 2)),
        ),
      );
      await repo.save(
        note('4', 'Four', tastedAt: day.subtract(const Duration(days: 3))),
      );

      Future<List<String>> ids(NotesQuery q) async =>
          (await repo.watchPage(q).first).map((n) => n.id).toList();

      expect(await ids(const NotesQuery(minRating: 4)), ['1', '2']);
      expect(await ids(const NotesQuery(styleId: 'alpine')), ['1', '3']);
      expect(await ids(const NotesQuery(minRating: 4, styleId: 'alpine')), [
        '1',
      ]);
      expect(await repo.watchStyleCounts().first, {'alpine': 2, 'blue': 1});
      expect(await repo.watchTopStyleIds().first, ['alpine', 'blue']);
      expect(await repo.watchTopStyleIds(limit: 1).first, ['alpine']);
    });

    test('watchNote emits updates and null on delete', () async {
      await repo.save(note('w', 'Watched'));
      final events = <String?>[];
      final sub = repo.watchNote('w').listen((n) => events.add(n?.cheeseName));
      await pumpEventQueue();
      await repo.save(note('w', 'Renamed'));
      await pumpEventQueue();
      await repo.delete('w');
      await pumpEventQueue();
      await sub.cancel();
      expect(events, ['Watched', 'Renamed', null]);
    });
  });

  group('SettingsRepository', () {
    test('defaults, save, update, clearing a key', () async {
      final repo = SettingsRepository(openTestDatabase());
      expect(await repo.load(), const AppSettings());
      await repo.save(
        const AppSettings(
          displayName: 'Tim',
          themeMode: ThemeMode.dark,
          units: PriceUnit.eurPerKg,
        ),
      );
      expect(
        await repo.watch().first,
        const AppSettings(
          displayName: 'Tim',
          themeMode: ThemeMode.dark,
          units: PriceUnit.eurPerKg,
        ),
      );
      await repo.update((s) => s.copyWith(displayName: null));
      final after = await repo.load();
      expect(after.displayName, isNull);
      expect(after.themeMode, ThemeMode.dark);
    });
  });

  group('RecentSearchesRepository', () {
    test('most recent first, dedupes, ignores blanks, caps at 10', () async {
      final repo = RecentSearchesRepository(openTestDatabase());
      await repo.add('  ');
      expect(await repo.watch().first, isEmpty);
      for (var i = 1; i <= 12; i++) {
        await repo.add('term $i');
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }
      var terms = await repo.watch().first;
      expect(terms.length, 10);
      expect(terms.first, 'term 12');
      expect(terms, isNot(contains('term 1')));
      await Future<void>.delayed(const Duration(milliseconds: 2));
      await repo.add('term 5');
      terms = await repo.watch().first;
      expect(terms.first, 'term 5');
      expect(terms.length, 10);
      await repo.remove('term 5');
      expect(await repo.watch().first, isNot(contains('term 5')));
      await repo.clear();
      expect(await repo.watch().first, isEmpty);
    });
  });
}
