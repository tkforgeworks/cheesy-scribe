import 'package:cheesy_scribe/app/shell/scribe_drawer.dart';
import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/features/glossary/glossary_button.dart';
import 'package:cheesy_scribe/features/glossary/glossary_screen.dart';
import 'package:cheesy_scribe/features/glossary/glossary_terms.dart';
import 'package:cheesy_scribe/features/notes/widgets/flavor_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';
import '../notes/note_form_test.dart' show field, tallScreen;

/// A phone-sized surface (the emulator's 1080×2400 @ 420 dpi).
void phoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

Finder get indexBar => find.widgetWithText(AppBar, 'Tasting terms');

Finder sectionBar(GlossarySection s) => find.widgetWithText(AppBar, s.title);

/// The definition text inside [term]'s entry.
Finder definitionOf(Object term, String definition) => find.descendant(
  of: find.byKey(GlossarySectionScreen.termKey(term)),
  matching: find.text(definition),
);

void main() {
  testApp('the index lists every section with its summary and term count', (
    tester,
  ) async {
    await pumpApp(tester, at: '/glossary');
    expect(find.text(glossaryIntro), findsOneWidget);
    for (final s in GlossarySection.values) {
      final row = find.byKey(GlossaryScreen.rowKey(s));
      for (final text in [
        s.title,
        s.summary,
        '${glossaryTerms(s).length} TERMS',
      ]) {
        expect(
          find.descendant(of: row, matching: find.text(text)),
          findsOneWidget,
          reason: '${s.name}: $text',
        );
      }
    }
  });

  testApp('every section page defines each of its terms', (tester) async {
    tester.view.physicalSize = const Size(800, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final s in GlossarySection.values) {
      await pumpApp(tester, at: '/glossary/${s.name}');
      expect(sectionBar(s), findsOneWidget);
      expect(find.text(s.intro), findsOneWidget);
      for (final t in glossaryTerms(s)) {
        expect(definitionOf(t.key, t.definition), findsOneWidget);
      }
    }
    // Stored as `lemon`, shown as CITRUS.
    await pumpApp(tester, at: '/glossary/flavor');
    expect(
      find.descendant(
        of: find.byKey(GlossarySectionScreen.termKey(FlavorNote.lemon)),
        matching: find.text('CITRUS'),
      ),
      findsOneWidget,
    );
  });

  testApp('drawer → index → section, and back the same way', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DrawerPill, 'Tasting terms'));
    await tester.pumpAndSettle();
    expect(indexBar, findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byKey(GlossaryScreen.rowKey(GlossarySection.rind)));
    await tester.pumpAndSettle();
    expect(sectionBar(GlossarySection.rind), findsOneWidget);
    expect(
      definitionOf(RindType.washed, RindType.washed.definition),
      findsOneWidget,
    );

    await systemBack(tester);
    expect(indexBar, findsOneWidget);
    await systemBack(tester);
    expect(indexBar, findsNothing);
    expect(find.text('Search your tastings'), findsOneWidget);
  });

  testApp('an unknown section says so', (tester) async {
    await pumpApp(tester, at: '/glossary/nope');
    expect(find.text('No such section'), findsOneWidget);
  });

  testApp('each form `?` opens its own section page, and back returns to '
      'the form', (tester) async {
    phoneScreen(tester);
    await pumpApp(tester, at: '/notes/new');

    // In form order, top to bottom, since scrollUntilVisible only goes down.
    for (final s in const [
      GlossarySection.rind,
      GlossarySection.milk,
      GlossarySection.texture,
      GlossarySection.flavor,
    ]) {
      final help = find.byTooltip(GlossaryButton.tooltipFor(s));
      await tester.scrollUntilVisible(
        help,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(help);
      await tester.pumpAndSettle();
      expect(sectionBar(s), findsOneWidget, reason: s.name);

      // Straight back to the form: the index is not underneath.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(indexBar, findsNothing, reason: s.name);
      expect(find.widgetWithText(AppBar, 'New tasting note'), findsOneWidget);
    }
  });

  testApp('the glossary opens from a part-filled form and back keeps the '
      'draft', (tester) async {
    tallScreen(tester);
    final db = await pumpApp(tester, at: '/notes/new');

    await tester.enterText(field('Cheese name'), 'Comté');
    await tester.enterText(field('Creamery'), 'Marcel Petite');
    await tester.tap(find.widgetWithText(FilterChip, 'Sheep'));
    await tester.tap(find.widgetWithText(FilterChip, 'Raw'));
    await tester.tap(find.text('List'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(FlavorList.pipKey(FlavorNote.nutty, 4)));
    await tester.pump();

    await tester.tap(
      find.byTooltip(GlossaryButton.tooltipFor(GlossarySection.texture)),
    );
    await tester.pumpAndSettle();
    expect(sectionBar(GlossarySection.texture), findsOneWidget);

    // The Android back button pops the glossary, not the form, and asks
    // nothing on the way.
    await systemBack(tester);
    expect(sectionBar(GlossarySection.texture), findsNothing);
    expect(find.text('Discard this note?'), findsNothing);
    expect(find.widgetWithText(AppBar, 'New tasting note'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Save'));
    await tester.pumpAndSettle();
    final note = (await onDb(
      tester,
      () => NotesRepository(db).watchAll().first,
    )).single;
    expect(note.cheeseName, 'Comté');
    expect(note.creamery, 'Marcel Petite');
    expect(note.milk, MilkType.sheep);
    expect(note.isRaw, isTrue);
    expect(note.flavors, {FlavorNote.nutty: 4});
  });

  // CHEESE-44: the list's explicit padding has to add the nav-bar inset.
  testApp('the longest section ends above the system navigation bar', (
    tester,
  ) async {
    const navBar = 48.0;
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: navBar);
    tester.view.viewPadding = const FakeViewPadding(bottom: navBar);
    addTearDown(tester.view.reset);
    await pumpApp(tester, at: '/glossary/flavor');

    final last = find.byKey(
      GlossarySectionScreen.termKey(FlavorNote.values.last),
    );
    await tester.scrollUntilVisible(
      last,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    final list = tester.state<ScrollableState>(find.byType(Scrollable).first);
    list.position.jumpTo(list.position.maxScrollExtent);
    await tester.pumpAndSettle();
    expect(tester.getRect(last).bottom, lessThanOrEqualTo(915 - navBar));
  });
}
