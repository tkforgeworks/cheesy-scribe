import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/features/feedback/feedback_client.dart';
import 'package:cheesy_scribe/features/feedback/feedback_fab.dart';
import 'package:cheesy_scribe/features/feedback/feedback_screen.dart';
import 'package:cheesy_scribe/features/notes/widgets/note_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';

import '../../support.dart';

TastingNote note(String id, String name, int day) => TastingNote(
  id: id,
  cheeseName: name,
  tastedAt: DateTime(2026, 8, day),
  createdAt: DateTime(2026, 8, day).toUtc(),
);

final fab = find.byKey(FeedbackFab.buttonKey);

/// The opacity of the [AnimatedOpacity] that [of] sits in.
double opacityAround(WidgetTester tester, Finder of) => tester
    .widget<AnimatedOpacity>(
      find.ancestor(of: of, matching: find.byType(AnimatedOpacity)).first,
    )
    .opacity;

void main() {
  testApp('shows on every browse-only screen', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = openTestDatabase();
    await onDb(tester, () => NotesRepository(db).save(note('n1', 'Comté', 3)));

    for (final at in [
      '/notes',
      '/notes/n1',
      '/notes/gone',
      '/library',
      '/library/blue',
      '/stats',
      '/settings',
      '/about',
      '/glossary',
      '/glossary/rind',
    ]) {
      await pumpApp(tester, at: at, db: db);
      expect(fab, findsOneWidget, reason: at);
    }
  });

  testApp('stays off screens with text entry', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = openTestDatabase();
    for (final at in ['/notes/new', '/account']) {
      await pumpApp(tester, at: at, db: db);
      expect(fab, findsNothing, reason: at);
    }
  });

  testApp('opens the form with its screen, and not again on the form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, at: '/stats');

    expect(find.byTooltip(FeedbackFab.tooltip), findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Send feedback'), findsOneWidget);
    expect(fab, findsNothing);
    final router = GoRouter.of(tester.element(find.byType(FeedbackScreen)));
    expect(
      router.state.uri.toString(),
      FeedbackScreen.location(FeedbackSource.stats),
    );
  });

  testApp('rides with the new-note button on Home, hiding on scroll', (
    tester,
  ) async {
    final db = openTestDatabase();
    await onDb(tester, () async {
      for (var i = 1; i <= 20; i++) {
        await NotesRepository(db).save(note('n$i', 'Cheese $i', i));
      }
    });
    await pumpApp(tester, db: db);

    final newNote = find.byType(ForgeFab);
    expect(fab, findsOneWidget);
    expect(newNote, findsOneWidget);
    // One animated pair around both buttons.
    Widget pairAround(Finder of) => tester.widget(
      find.ancestor(of: of, matching: find.byType(AnimatedOpacity)),
    );
    expect(pairAround(newNote), same(pairAround(fab)));
    expect(opacityAround(tester, fab), 1);

    // Home shows the buttons again whenever a scroll comes to rest, so
    // hold the finger down to see them hide (CHEESE-24's `_onScroll`).
    final finger = await tester.startGesture(
      tester.getCenter(find.byType(NoteRow).first),
    );
    for (var i = 0; i < 6; i++) {
      await finger.moveBy(const Offset(0, -50));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(opacityAround(tester, fab), 0);
    expect(opacityAround(tester, newNote), 0);

    for (var i = 0; i < 3; i++) {
      await finger.moveBy(const Offset(0, 50));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(opacityAround(tester, fab), 1);
    expect(opacityAround(tester, newNote), 1);
    await finger.up();
    await tester.pumpAndSettle();
  });
}
