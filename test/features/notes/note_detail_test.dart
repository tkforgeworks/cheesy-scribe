import 'package:cheesy_scribe/app/widgets/widgets.dart';
import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/features/notes/widgets/flavor_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

final fullNote = TastingNote(
  id: 'full',
  cheeseName: 'Rogue River Blue',
  tastedAt: DateTime(2026, 8, 12),
  createdAt: DateTime.utc(2026, 8, 12, 19),
  creamery: 'Rogue Creamery',
  origin: 'Central Point, Oregon',
  rind: RindType.leafWrapped,
  price: 28,
  milk: MilkType.cow,
  isRaw: true,
  rating: 5,
  texture: TextureLevel.semiSoft,
  notes: 'Autumn-only release, wrapped in pear-brandy-soaked grape leaves.',
  verdict: 'Tastes like winning an argument.',
  flavors: const {FlavorNote.caramel: 5, FlavorNote.moldyBlue: 4},
  cheeseStyleId: 'blue',
);

final minimalNote = TastingNote(
  id: 'min',
  cheeseName: 'Mystery wedge',
  tastedAt: DateTime(2026, 9, 1),
  createdAt: DateTime.utc(2026, 9, 1),
);

void main() {
  testApp('renders a full note', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = openTestDatabase();
    await onDb(tester, () => NotesRepository(db).save(fullNote));
    await pumpApp(tester, at: '/notes/full', db: db);

    expect(find.text('TASTED AUG 12, 2026 · \$28/LB'), findsOneWidget);
    expect(find.text('Rogue River Blue'), findsOneWidget);
    expect(
      find.text('Rogue Creamery · Central Point, Oregon — leaf-wrapped rind'),
      findsOneWidget,
    );
    expect(find.text('Tastes like winning an argument.'), findsOneWidget);
    expect(find.text('5.0'), findsOneWidget);
    for (final capsule in ['COW', 'RAW', '\$28/LB', 'BLUE']) {
      expect(find.widgetWithText(TagCapsule, capsule), findsOneWidget);
    }
    // Texture appears as a capsule and as the meter's active label.
    expect(find.text('SEMI-SOFT'), findsNWidgets(2));
    expect(find.text('NOTES'), findsOneWidget);
    expect(find.textContaining('Autumn-only release'), findsOneWidget);
    expect(find.byType(FlavorWheel), findsOneWidget);
    expect(find.text('TEXTURE'), findsOneWidget);
    expect(find.byType(Slider), findsNothing);

    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Edit tasting note'), findsOneWidget);
  });

  testApp('a minimal note hides what it does not have', (tester) async {
    final db = openTestDatabase();
    await onDb(tester, () => NotesRepository(db).save(minimalNote));
    await pumpApp(tester, at: '/notes/min', db: db);

    expect(find.text('TASTED SEP 1, 2026'), findsOneWidget);
    expect(find.text('Mystery wedge'), findsOneWidget);
    expect(find.byType(StarRating), findsNothing);
    expect(find.widgetWithText(TagCapsule, 'COW'), findsOneWidget);
    expect(find.widgetWithText(TagCapsule, 'SEMI-SOFT'), findsOneWidget);
    expect(find.text('NOTES'), findsNothing);
    expect(find.byType(FlavorWheel), findsNothing);
    expect(find.text('TEXTURE'), findsOneWidget);
  });

  testApp('edits stream in; deleting elsewhere pops the route', (tester) async {
    final db = openTestDatabase();
    final repo = NotesRepository(db);
    await onDb(tester, () => repo.save(minimalNote));
    await pumpApp(tester, at: '/notes/min', db: db);
    expect(find.text('Mystery wedge'), findsOneWidget);

    await onDb(
      tester,
      () => repo.save(minimalNote.copyWith(cheeseName: 'Named')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Named'), findsOneWidget);

    await onDb(tester, () => repo.delete('min'));
    await tester.pumpAndSettle();
    expect(find.text('Search your tastings'), findsOneWidget);
  });

  testApp('an unknown id shows the gone state without an edit action', (
    tester,
  ) async {
    await pumpApp(tester, at: '/notes/nope');
    expect(find.text('This note is gone'), findsOneWidget);
    expect(find.byTooltip('Edit'), findsNothing);
  });
}
