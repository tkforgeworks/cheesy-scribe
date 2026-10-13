import 'package:cheesy_scribe/app/widgets/widgets.dart';
import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/features/library/library_screen.dart';
import 'package:cheesy_scribe/features/notes/widgets/note_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

TastingNote note(String id, String name, String styleId, DateTime day) =>
    TastingNote(
      id: id,
      cheeseName: name,
      tastedAt: day,
      createdAt: day.toUtc(),
      cheeseStyleId: styleId,
    );

Finder card(String name) => find.widgetWithText(StyleCard, name);

void tall(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testApp('grid shows every style with live counts and filters by the bar', (
    tester,
  ) async {
    tall(tester);
    final db = openTestDatabase();
    await onDb(tester, () async {
      await NotesRepository(db)
          .save(note('a', 'Comté', 'alpine', DateTime(2026, 8, 1)));
      await NotesRepository(db)
          .save(note('b', 'Gruyère', 'alpine', DateTime(2026, 8, 2)));
    });
    await pumpApp(tester, at: '/library', db: db);

    expect(find.text('Cheese library'), findsOneWidget);
    expect(find.text('27 STYLES'), findsOneWidget);
    expect(find.textContaining('what am I even eating'), findsOneWidget);
    expect(find.byType(StyleCard), findsNWidgets(27));
    expect(
      find.descendant(of: card('Alpine'), matching: find.text('2 TASTED')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card('Blue'), matching: find.text('0 TASTED')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: card('Alpine'),
        matching: find.text('Comté, Gruyère, Appenzeller'),
      ),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'gruy');
    await tester.pumpAndSettle();
    expect(find.byType(StyleCard), findsOneWidget);
    expect(card('Alpine'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text('No such style'), findsOneWidget);
    await tester.tap(find.text('Clear search'));
    await tester.pumpAndSettle();
    expect(find.byType(StyleCard), findsNWidgets(27));

    // Card → detail with the linked notes.
    await tester.tap(card('Alpine'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Cheese style'), findsOneWidget);
    expect(find.text('Alpine'), findsOneWidget);
    expect(find.text('2 TASTED'), findsOneWidget);
    expect(find.textContaining('Big cooked-curd wheels'), findsOneWidget);
    expect(find.text('TYPICAL PROFILE'), findsOneWidget);
    expect(find.widgetWithText(TagCapsule, 'COW'), findsOneWidget);
    expect(find.text('FIRM'), findsOneWidget);
    expect(find.byType(NoteRow), findsNWidgets(2));
    await tester.tap(find.widgetWithText(NoteRow, 'Comté'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Tasting note'), findsOneWidget);
  });

  testApp('untasted style offers a preselected new note; counts update live', (
    tester,
  ) async {
    tall(tester);
    final db = await pumpApp(tester, at: '/library/blue');
    expect(find.text('Blue'), findsOneWidget);
    expect(find.text("You haven't met this one yet."), findsOneWidget);
    expect(find.byType(NoteRow), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'New tasting note'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'New tasting note'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Blue'), findsOneWidget);
    // Preselection does not count as an edit.
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Discard this note?'), findsNothing);
    expect(find.widgetWithText(AppBar, 'Cheese style'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'New tasting note'));
    await tester.pumpAndSettle();
    // Scope to the journal field: the library's filter bar is a TextField too.
    final nameField = find.descendant(
      of: find.ancestor(
        of: find.text('CHEESE NAME'),
        matching: find.byType(JournalField),
      ),
      matching: find.byType(TextField),
    );
    await tester.enterText(nameField, 'Stilton');
    await tester.pump(); // let the Save button pick up the new text
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Tasting note'), findsOneWidget);
    expect(find.widgetWithText(TagCapsule, 'BLUE'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Cheese style'), findsOneWidget);
    expect(find.widgetWithText(NoteRow, 'Stilton'), findsOneWidget);
    expect(find.text('1 TASTED'), findsOneWidget);
    expect(find.text("You haven't met this one yet."), findsNothing);

    final saved = await onDb(
      tester,
      () => NotesRepository(db).watchAll().first,
    );
    expect(saved.single.cheeseStyleId, 'blue');
  });

  testApp('unknown style shows the off-the-menu state', (tester) async {
    await pumpApp(tester, at: '/library/nope');
    expect(find.text('This style is off the menu'), findsOneWidget);
  });
}
