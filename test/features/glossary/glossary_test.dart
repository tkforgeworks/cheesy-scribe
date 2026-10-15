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

Finder get glossaryBar => find.widgetWithText(AppBar, 'Tasting terms');

/// The definition text inside [term]'s entry.
Finder definitionOf(Object term, String definition) => find.descendant(
  of: find.byKey(GlossaryScreen.termKey(term)),
  matching: find.text(definition),
);

void main() {
  testApp('every flavor, texture, rind and milk term has its definition', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 12000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, at: '/glossary');

    for (final s in GlossarySection.values) {
      expect(find.text(s.title), findsOneWidget);
      expect(find.text(s.intro), findsOneWidget);
    }
    for (final f in FlavorNote.values) {
      expect(definitionOf(f, f.definition), findsOneWidget, reason: f.name);
    }
    for (final t in TextureLevel.values) {
      expect(definitionOf(t, t.definition), findsOneWidget, reason: t.name);
    }
    for (final r in RindType.values) {
      expect(definitionOf(r, r.definition), findsOneWidget, reason: r.name);
    }
    expect(definitionOf('raw', rawDefinition), findsOneWidget);
    expect(definitionOf('grassfed', grassfedDefinition), findsOneWidget);
    // Stored as `lemon`, shown as CITRUS (CHEESE-45).
    expect(
      find.descendant(
        of: find.byKey(GlossaryScreen.termKey(FlavorNote.lemon)),
        matching: find.text('CITRUS'),
      ),
      findsOneWidget,
    );
  });

  testApp('the drawer opens the glossary and back returns to the notes', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(DrawerPill, 'Tasting terms'));
    await tester.pumpAndSettle();
    expect(glossaryBar, findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await systemBack(tester);
    expect(glossaryBar, findsNothing);
    expect(find.text('Search your tastings'), findsOneWidget);
  });

  testApp('a section link opens the glossary scrolled to that section', (
    tester,
  ) async {
    phoneScreen(tester);
    await pumpApp(tester, at: '/glossary?section=rind');

    final rind = tester.getRect(
      find.byKey(GlossaryScreen.sectionKey(GlossarySection.rind)),
    );
    final bar = tester.getRect(glossaryBar);
    expect(rind.top, closeTo(bar.bottom, 1));
    expect(
      find.byKey(GlossaryScreen.termKey(FlavorNote.salty)).hitTestable(),
      findsNothing,
    );
  });

  testApp('each form section opens its own part of the glossary', (
    tester,
  ) async {
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
      expect(glossaryBar, findsOneWidget, reason: s.name);
      // The section's title, since the flavor section outgrows the screen.
      expect(
        find
            .descendant(
              of: find.byKey(GlossaryScreen.sectionKey(s)),
              matching: find.text(s.title),
            )
            .hitTestable(),
        findsOneWidget,
        reason: s.name,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(glossaryBar, findsNothing);
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
    expect(glossaryBar, findsOneWidget);

    // The Android back button pops the glossary, not the form, and asks
    // nothing on the way.
    await systemBack(tester);
    expect(glossaryBar, findsNothing);
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
  testApp('the last entry rests above the system navigation bar', (
    tester,
  ) async {
    const navBar = 48.0;
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(bottom: navBar);
    tester.view.viewPadding = const FakeViewPadding(bottom: navBar);
    addTearDown(tester.view.reset);
    await pumpApp(tester, at: '/glossary');

    final list = tester.state<ScrollableState>(find.byType(Scrollable).first);
    list.position.jumpTo(list.position.maxScrollExtent);
    await tester.pumpAndSettle();
    final last = tester.getRect(find.byKey(GlossaryScreen.termKey('grassfed')));
    expect(last.bottom, lessThanOrEqualTo(915 - navBar));
  });
}
