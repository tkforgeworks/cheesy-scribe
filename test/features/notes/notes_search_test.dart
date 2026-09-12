import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/data/repositories/recent_searches_repository.dart';
import 'package:cheesy_scribe/features/notes/notes_search.dart';
import 'package:cheesy_scribe/features/notes/widgets/note_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

TastingNote note(
  String id,
  String name,
  DateTime day, {
  String? creamery,
  String? origin,
  String notes = '',
  String? verdict,
  Map<FlavorNote, int> flavors = const {},
}) => TastingNote(
  id: id,
  cheeseName: name,
  tastedAt: day,
  createdAt: day.toUtc(),
  creamery: creamery,
  origin: origin,
  notes: notes,
  verdict: verdict,
  flavors: flavors,
);

final seed = [
  note(
    'rogue',
    'Rogue River Blue',
    DateTime(2026, 8, 12),
    creamery: 'Rogue Creamery',
    origin: 'Oregon',
    verdict: 'Tastes like winning an argument.',
    flavors: const {FlavorNote.caramel: 5, FlavorNote.grassy: 1},
  ),
  note(
    'comte',
    'Comté 24 mo',
    DateTime(2026, 8, 3),
    creamery: 'Marcel Petite',
    origin: 'Jura, France',
    notes: 'Brothy and long.',
  ),
  note(
    'epoisses',
    'Époisses',
    DateTime(2026, 7, 19),
    creamery: 'Berthaut',
    origin: 'Burgundy',
  ),
];

Future<void> openSearch(WidgetTester tester) async {
  await tester.tap(find.text('Search your tastings').first);
  await tester.pumpAndSettle();
}

/// Rows inside the search view only.
Finder resultRows() => find.descendant(
  of: find.byKey(NotesSearchAnchor.resultsKey),
  matching: find.byType(NoteRow),
);

Finder resultRow(String name) => find.descendant(
  of: find.byKey(NotesSearchAnchor.resultsKey),
  matching: find.widgetWithText(NoteRow, name),
);

Future<void> type(WidgetTester tester, String q) async {
  await tester.enterText(find.byType(TextField).last, q);
  await tester.pumpAndSettle();
}

void main() {
  testApp('matches by every field and folds diacritics', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = openTestDatabase();
    await onDb(tester, () async {
      for (final n in seed) {
        await NotesRepository(db).save(n);
      }
    });
    await pumpApp(tester, db: db);
    await openSearch(tester);
    expect(
      find.text('Search by name, creamery, origin, notes or flavor.'),
      findsOneWidget,
    );

    Future<void> expectOnly(String q, String name) async {
      await type(tester, q);
      expect(resultRows(), findsOneWidget, reason: q);
      expect(resultRow(name), findsOneWidget, reason: q);
      expect(find.text('1 RESULT'), findsOneWidget, reason: q);
    }

    await expectOnly('rogue river', 'Rogue River Blue'); // name
    await expectOnly('petite', 'Comté 24 mo'); // creamery
    await expectOnly('burgundy', 'Époisses'); // origin
    await expectOnly('brothy', 'Comté 24 mo'); // notes
    await expectOnly('argument', 'Rogue River Blue'); // verdict
    await expectOnly('caramel', 'Rogue River Blue'); // flavor ≥ 3
    await expectOnly('epoisses', 'Époisses'); // diacritics
    await type(tester, 'grassy'); // scored 1: not a searchable flavor
    expect(find.text('0 RESULTS'), findsOneWidget);
    await type(tester, 'r');
    expect(find.text('3 RESULTS'), findsOneWidget);
  });

  testApp(
    'no results offers Clear search; result tap opens detail and is remembered',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = openTestDatabase();
      await onDb(tester, () async {
        for (final n in seed) {
          await NotesRepository(db).save(n);
        }
      });
      await pumpApp(tester, db: db);
      await openSearch(tester);

      await type(tester, 'zzz');
      expect(find.text('0 RESULTS'), findsOneWidget);
      expect(
        find.text('Nothing matches — either a typo or a cheese frontier.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Clear search'));
      await tester.pumpAndSettle();
      expect(
        find.text('Search by name, creamery, origin, notes or flavor.'),
        findsOneWidget,
      );

      await type(tester, 'petite');
      await tester.tap(resultRow('Comté 24 mo'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Tasting note'), findsOneWidget);
      expect(find.text('Comté 24 mo'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Your tastings'), findsOneWidget);
      expect(
        await onDb(tester, () => RecentSearchesRepository(db).watch().first),
        ['petite'],
      );
    },
  );

  testApp(
    'recent searches: newest first, tap re-runs, remove, submit records',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = openTestDatabase();
      await onDb(tester, () async {
        for (final n in seed) {
          await NotesRepository(db).save(n);
        }
        final r = RecentSearchesRepository(db);
        await r.add('older');
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await r.add('petite');
      });
      await pumpApp(tester, db: db);
      await openSearch(tester);

      expect(find.text('RECENT SEARCHES'), findsOneWidget);
      final terms = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .map((t) => (t.title! as Text).data)
          .toList();
      expect(terms, ['petite', 'older']);

      await tester.tap(find.byTooltip('Remove').last);
      await tester.pumpAndSettle();
      expect(find.text('older'), findsNothing);

      await tester.tap(find.text('petite'));
      await tester.pumpAndSettle();
      expect(resultRow('Comté 24 mo'), findsOneWidget);

      await tester.tap(find.byTooltip('Clear'));
      await tester.pumpAndSettle();
      expect(find.text('RECENT SEARCHES'), findsOneWidget);

      await type(tester, 'burgundy');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(
        await onDb(tester, () => RecentSearchesRepository(db).watch().first),
        ['burgundy', 'petite'],
      );

      await tester.tap(find.byTooltip('Close search'));
      await tester.pumpAndSettle();
      expect(find.text('Your tastings'), findsOneWidget);
    },
  );
}
