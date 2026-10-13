import 'dart:convert';
import 'dart:io';

import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/features/stats/stats_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

TastingNote note(String id, {MilkType milk = MilkType.cow, int rating = 0}) =>
    TastingNote(
      id: id,
      cheeseName: id,
      tastedAt: DateTime(2026, 8, 1),
      createdAt: DateTime.utc(2026, 8, 1),
      milk: milk,
      rating: rating,
    );

void main() {
  testApp('no notes: zero tile, no average, charts need material', (
    tester,
  ) async {
    await pumpApp(tester, at: '/stats');
    expect(find.widgetWithText(AppBar, 'Stats & insights'), findsOneWidget);
    expect(find.widgetWithText(StatTile, '0'), findsOneWidget);
    expect(find.widgetWithText(StatTile, '—'), findsOneWidget);
    expect(find.text('CHEESES TASTED'), findsOneWidget);
    expect(find.text('AVERAGE RATING'), findsOneWidget);
    expect(find.text(StatsScreen.needMaterial), findsOneWidget);
    expect(find.byType(TopFlavorsCard), findsNothing);
    expect(find.byType(MilkBreakdownCard), findsNothing);
    // The menu icon still opens the drawer here.
    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    expect(find.byType(Drawer), findsOneWidget);
  });

  testApp(
    'two notes: real numbers, still no charts; a third unlocks them live',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final db = openTestDatabase();
      await onDb(tester, () async {
        await NotesRepository(db).save(note('a', rating: 4));
        await NotesRepository(db)
            .save(note('b', rating: 5, milk: MilkType.goat));
      });
      await pumpApp(tester, at: '/stats', db: db);
      expect(find.widgetWithText(StatTile, '2'), findsOneWidget);
      expect(find.widgetWithText(StatTile, '4.5'), findsOneWidget);
      expect(find.text(StatsScreen.needMaterial), findsOneWidget);

      await onDb(tester, () => NotesRepository(db).save(note('c', rating: 3)));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(StatTile, '3'), findsOneWidget);
      expect(find.widgetWithText(StatTile, '4.0'), findsOneWidget);
      expect(find.text(StatsScreen.needMaterial), findsNothing);
      expect(find.byType(TopFlavorsCard), findsOneWidget);
      expect(
        find.text('No flavor has scored a 3 yet. The wheel is waiting.'),
        findsOneWidget,
      );
      expect(find.byType(MilkBreakdownCard), findsOneWidget);
      expect(find.text('COW 67%'), findsOneWidget);
      expect(find.text('GOAT 33%'), findsOneWidget);
      expect(
        find.text("Verdict: you have a type, and it's cow."),
        findsOneWidget,
      );
    },
  );

  testApp('many notes: the mocked journal renders bars, legend and verdict', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final notes =
        (jsonDecode(
              File('test/fixtures/stats_128_notes.json').readAsStringSync(),
            ) as List<dynamic>)
            .map((e) => TastingNote.fromJson(e as Map<String, dynamic>))
            .toList();
    final db = openTestDatabase();
    await onDb(tester, () async {
      final repo = NotesRepository(db);
      for (final n in notes) {
        await repo.save(n);
      }
    });
    await pumpApp(tester, at: '/stats', db: db);
    expect(find.widgetWithText(StatTile, '128'), findsOneWidget);
    expect(find.widgetWithText(StatTile, '4.2'), findsOneWidget);
    expect(find.text('TOP FLAVORS'), findsOneWidget);
    for (final row in [
      'CARAMEL',
      'NUTTY',
      'EARTHY',
      'GRASSY',
      'SALTY',
      'SWEET',
    ]) {
      expect(find.text(row), findsOneWidget, reason: row);
    }
    expect(find.text('BUTTERY/CREAMY'), findsNothing); // seventh flavor is cut
    expect(find.text('32'), findsOneWidget);
    expect(find.text('MILK BREAKDOWN'), findsOneWidget);
    expect(find.text('COW 62%'), findsOneWidget);
    expect(find.text('GOAT 22%'), findsOneWidget);
    expect(find.text('SHEEP 11%'), findsOneWidget);
    expect(find.text('BUFFALO 5%'), findsOneWidget);
    expect(
      find.text("Verdict: you have a type, and it's cow."),
      findsOneWidget,
    );
  });
}
