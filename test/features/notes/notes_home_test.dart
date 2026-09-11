import 'package:cheesy_scribe/app/widgets/widgets.dart';
import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/features/notes/widgets/featured_note_card.dart';
import 'package:cheesy_scribe/features/notes/widgets/note_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

TastingNote note(
  String id,
  String name, {
  required DateTime day,
  int rating = 0,
  String? styleId,
  String? creamery,
  String? verdict,
  Map<FlavorNote, int> flavors = const {},
}) => TastingNote(
  id: id,
  cheeseName: name,
  tastedAt: day,
  createdAt: day.toUtc(),
  rating: rating,
  cheeseStyleId: styleId,
  creamery: creamery,
  verdict: verdict,
  flavors: flavors,
);

final seed = [
  note(
    'rogue',
    'Rogue River Blue',
    day: DateTime(2026, 8, 12),
    rating: 5,
    styleId: 'blue',
    creamery: 'Rogue Creamery',
    verdict: 'Tastes like winning an argument.',
    flavors: const {FlavorNote.caramel: 5, FlavorNote.earthy: 4},
  ),
  note(
    'comte',
    'Comté 24 mo',
    day: DateTime(2026, 8, 3),
    rating: 4,
    styleId: 'alpine',
    creamery: 'Marcel Petite',
  ),
  note(
    'fog',
    'Humboldt Fog',
    day: DateTime(2026, 7, 27),
    rating: 4,
    styleId: 'bloomy-rind',
  ),
  note(
    'epoisses',
    'Époisses',
    day: DateTime(2026, 7, 19),
    rating: 3,
    styleId: 'washed-rind',
  ),
  note(
    'mystery',
    'Mystery wedge',
    day: DateTime(2026, 7, 1),
    styleId: 'alpine',
  ),
];

void main() {
  testApp('empty state with an inline button', (tester) async {
    await pumpApp(tester);
    expect(find.text('No tastings yet'), findsOneWidget);
    expect(
      find.text("The cheese isn't going to review itself."),
      findsOneWidget,
    );
    expect(find.text('0 NOTES'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'New tasting notes'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'New tasting note'), findsOneWidget);
  });

  testApp('populated: featured newest, rows for the rest, taps open detail', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = openTestDatabase();
    await onDb(tester, () async {
      for (final n in seed) {
        await NotesRepository(db).save(n);
      }
    });
    await pumpApp(tester, db: db);

    expect(find.text('5 NOTES'), findsOneWidget);
    final featured = find.byType(FeaturedNoteCard);
    expect(featured, findsOneWidget);
    expect(
      find.descendant(of: featured, matching: find.text('Rogue River Blue')),
      findsOneWidget,
    );
    expect(find.text('LATEST TASTING · AUG 12'), findsOneWidget);
    expect(find.text('“Tastes like winning an argument.”'), findsOneWidget);
    expect(find.text('5.0'), findsOneWidget);
    expect(find.widgetWithText(TagCapsule, 'CARAMEL'), findsOneWidget);
    // Rows exclude the featured note and show the initials avatar.
    expect(find.byType(NoteRow), findsNWidgets(4));
    expect(find.widgetWithText(NoteRow, 'Rogue River Blue'), findsNothing);
    expect(find.text('CO'), findsOneWidget);
    expect(find.text('Marcel Petite — Aug 3'), findsOneWidget);
    // Unrated row shows no stars.
    final mystery = find.widgetWithText(NoteRow, 'Mystery wedge');
    expect(
      find.descendant(of: mystery, matching: find.byType(StarRating)),
      findsNothing,
    );

    await tester.tap(find.widgetWithText(NoteRow, 'Comté 24 mo'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Tasting note'), findsOneWidget);
    expect(find.text('Comté 24 mo'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tester.tap(featured);
    await tester.pumpAndSettle();
    expect(find.text('TASTED AUG 12, 2026'), findsOneWidget);
  });

  testApp('chips filter by rating and top styles; All resets', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = openTestDatabase();
    await onDb(tester, () async {
      for (final n in seed) {
        await NotesRepository(db).save(n);
      }
    });
    await pumpApp(tester, db: db);

    // Alpine has two notes, so it leads the style chips.
    expect(find.widgetWithText(FilterChip, 'Alpine'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilterChip, ' and up'));
    await tester.pumpAndSettle();
    expect(find.byType(FeaturedNoteCard), findsNothing);
    expect(find.text('3 NOTES'), findsOneWidget);
    expect(find.byType(NoteRow), findsNWidgets(3));
    expect(find.widgetWithText(NoteRow, 'Époisses'), findsNothing);

    await tester.tap(find.widgetWithText(FilterChip, 'Alpine'));
    await tester.pumpAndSettle();
    expect(find.text('1 NOTE'), findsOneWidget);
    expect(find.widgetWithText(NoteRow, 'Comté 24 mo'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'All'));
    await tester.pumpAndSettle();
    expect(find.text('5 NOTES'), findsOneWidget);
    expect(find.byType(FeaturedNoteCard), findsOneWidget);
  });

  testApp('long-press offers Edit / Delete; delete confirms and removes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = openTestDatabase();
    await onDb(tester, () async {
      for (final n in seed) {
        await NotesRepository(db).save(n);
      }
    });
    await pumpApp(tester, db: db);

    await tester.longPress(find.widgetWithText(NoteRow, 'Humboldt Fog'));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this note?'), findsOneWidget);
    await tester.tap(find.text('Keep it'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(NoteRow, 'Humboldt Fog'), findsOneWidget);

    await tester.longPress(find.widgetWithText(NoteRow, 'Humboldt Fog'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(NoteRow, 'Humboldt Fog'), findsNothing);
    expect(find.text('4 NOTES'), findsOneWidget);

    await tester.longPress(find.widgetWithText(NoteRow, 'Comté 24 mo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Edit tasting note'), findsOneWidget);
  });

  testApp('a single note is featured with a quiet line, not an empty state', (
    tester,
  ) async {
    final db = openTestDatabase();
    await onDb(tester, () => NotesRepository(db).save(seed.first));
    await pumpApp(tester, db: db);
    expect(find.byType(FeaturedNoteCard), findsOneWidget);
    expect(find.byType(NoteRow), findsNothing);
    expect(find.text('Nothing matches'), findsNothing);
    expect(
      find.text('One tasting so far. The journal has room.'),
      findsOneWidget,
    );
  });

  test('NoteRow.initials', () {
    expect(NoteRow.initials('Comté 24 mo'), 'CO');
    expect(NoteRow.initials('Époisses'), 'ÉP');
    expect(NoteRow.initials('X'), 'X');
    expect(NoteRow.initials('24'), '24');
  });
}
