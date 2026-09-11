import 'package:cheesy_scribe/app/widgets/widgets.dart';
import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

/// The text field inside the journal field labelled [label].
Finder field(String label) => find.descendant(
  of: find.ancestor(
    of: find.text(label.toUpperCase()),
    matching: find.byType(JournalField),
  ),
  matching: find.byType(TextField),
);

bool saveEnabled(WidgetTester tester) =>
    tester
        .widget<TextButton>(find.widgetWithText(TextButton, 'Save'))
        .onPressed !=
    null;

/// A tall surface so the whole form is laid out without scrolling.
void tallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 3600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

final fullNote = TastingNote(
  id: 'full',
  cheeseName: 'Époisses',
  tastedAt: DateTime(2026, 8, 12),
  createdAt: DateTime.utc(2026, 8, 12, 19, 30),
  creamery: 'Berthaut',
  origin: 'Burgundy',
  rind: RindType.washed,
  price: 28,
  priceUnit: PriceUnit.eurPerKg,
  milk: MilkType.cow,
  isRaw: true,
  rating: 4,
  texture: TextureLevel.runny,
  notes: 'Loud.',
  verdict: 'A dare.',
  flavors: const {FlavorNote.stinky: 5},
  cheeseStyleId: 'washed-rind',
);

void main() {
  testApp('save enables with a name; saving opens the new note', (
    tester,
  ) async {
    tallScreen(tester);
    final db = await pumpApp(tester, at: '/notes/new');
    expect(find.widgetWithText(AppBar, 'New tasting note'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);

    await tester.enterText(field('Cheese name'), 'Comté');
    await tester.pump();
    expect(saveEnabled(tester), isTrue);

    await tester.enterText(field('Creamery'), 'Marcel Petite');
    await tester.enterText(field('Price'), '24.5');
    await tester.tap(find.widgetWithText(FilterChip, 'Sheep'));
    await tester.tap(find.widgetWithText(FilterChip, 'Raw'));
    await tester.pump();

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Tasting note'), findsOneWidget);

    final notes = await onDb(
      tester,
      () => NotesRepository(db).watchAll().first,
    );
    expect(notes, hasLength(1));
    final n = notes.single;
    expect(n.cheeseName, 'Comté');
    expect(n.creamery, 'Marcel Petite');
    expect(n.price, 24.5);
    expect(n.priceUnit, PriceUnit.usdPerLb);
    expect(n.milk, MilkType.sheep);
    expect(n.isRaw, isTrue);
    expect(n.tastedAt, TastingNote.dateOnly(DateTime.now()));

    // Back from detail lands on the list, not the form.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Search your tastings'), findsOneWidget);
  });

  testApp('validation: a cheese needs a name; price cannot be negative', (
    tester,
  ) async {
    tallScreen(tester);
    await pumpApp(tester, at: '/notes/new');
    await tester.tap(find.widgetWithText(FilledButton, 'Save to journal'));
    await tester.pump();
    expect(find.text('A CHEESE NEEDS A NAME.'), findsOneWidget);

    await tester.enterText(field('Cheese name'), 'Brie');
    await tester.pump();
    expect(find.text('A CHEESE NEEDS A NAME.'), findsNothing);

    await tester.enterText(field('Price'), '-3');
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pump();
    expect(find.text("PRICE CAN'T BE NEGATIVE."), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'New tasting note'), findsOneWidget);
  });

  testApp('close asks before discarding edits, not before an untouched form', (
    tester,
  ) async {
    tallScreen(tester);
    await pumpApp(tester, at: '/notes/new');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Search your tastings'), findsOneWidget);

    await tester.tap(find.byType(ForgeFab));
    await tester.pumpAndSettle();
    await tester.enterText(field('Cheese name'), 'Stilton');
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Discard this note?'), findsOneWidget);
    expect(find.text('The cheese deserved better.'), findsOneWidget);

    await tester.tap(find.text('Keep writing'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'New tasting note'), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Search your tastings'), findsOneWidget);
  });

  testApp('edit prefills every field and saves in place', (tester) async {
    tallScreen(tester);
    final db = openTestDatabase();
    await onDb(tester, () => NotesRepository(db).save(fullNote));
    await pumpApp(tester, at: '/notes/full/edit', db: db);
    expect(find.widgetWithText(AppBar, 'Edit tasting note'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Époisses'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Berthaut'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Aug 12, 2026'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Washed'), findsOneWidget);
    expect(find.widgetWithText(TextField, '28'), findsOneWidget);
    expect(find.text('€/KG'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Washed rind'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'A dare.'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Loud.'), findsOneWidget);
    expect(find.text('4.0'), findsOneWidget);
    expect(
      tester
          .widget<FilterChip>(find.widgetWithText(FilterChip, 'Raw'))
          .selected,
      isTrue,
    );
    expect(saveEnabled(tester), isTrue);

    // Untouched edit form closes without a prompt.
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Tasting note'), findsOneWidget);

    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(field('Cheese name'), 'Époisses de Bourgogne');
    await tester.tap(find.byTooltip('Clear').first); // clears the rind
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Tasting note'), findsOneWidget);

    final saved = (await onDb(
      tester,
      () => NotesRepository(db).getNote('full'),
    ))!;
    expect(saved.cheeseName, 'Époisses de Bourgogne');
    expect(saved.rind, isNull);
    expect(saved.createdAt, fullNote.createdAt);
    expect(saved.rating, 4);
    expect(saved.flavors, {FlavorNote.stinky: 5});
    expect(saved.cheeseStyleId, 'washed-rind');
    expect(
      await onDb(
        tester,
        () => NotesRepository(db).watchCount(const NotesQuery()).first,
      ),
      1,
    );
  });

  testApp('pickers: milk Other reveals a field; style and rind sheets', (
    tester,
  ) async {
    tallScreen(tester);
    await pumpApp(tester, at: '/notes/new');
    expect(find.text('WHICH MILK?'), findsNothing);
    await tester.tap(find.widgetWithText(FilterChip, 'Other').first);
    await tester.pump();
    expect(find.text('WHICH MILK?'), findsOneWidget);

    await tester.tap(field('Style'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(SearchBar).last, 'alp');
    await tester.pumpAndSettle();
    expect(find.text('Alpine'), findsOneWidget);
    expect(find.text('Blue'), findsNothing);
    await tester.tap(find.text('Alpine'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Alpine'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear'));
    await tester.pump();
    expect(find.widgetWithText(TextField, 'Alpine'), findsNothing);

    await tester.tap(field('Rind'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other').last);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Other'), findsOneWidget);
    expect(find.text('RIND (OTHER)'), findsOneWidget);
  });
}
