import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/data/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

void main() {
  testApp('defaults, edit on Done, propagates to the drawer and persists', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await pumpApp(tester);
    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    expect(find.text('Your notebook'), findsOneWidget);
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    final year = DateTime.now().year;
    expect(find.text('MEMBER SINCE $year · 0 NOTES'), findsOneWidget);
    expect(find.text('DISPLAY NAME'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Tim');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Tim'), findsWidgets); // header + field
    expect(find.text('T'), findsOneWidget); // avatar initial

    // Drawer reflects it immediately.
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    expect(find.text('Tim'), findsOneWidget);
    expect(find.text('Your notebook'), findsNothing);

    // Persisted, and member-since was stamped on first visit.
    final saved = await onDb(tester, () => SettingsRepository(db).load());
    expect(saved.displayName, 'Tim');
    expect(saved.memberSince?.year, year);
    await pumpApp(tester, at: '/account', db: db);
    expect(find.widgetWithText(TextField, 'Tim'), findsOneWidget);
  });

  testApp('member since follows the earliest note; blur saves; blank clears', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = openTestDatabase();
    await onDb(tester, () async {
      await SettingsRepository(db).save(const AppSettings(displayName: 'Tim'));
      final repo = NotesRepository(db);
      await repo.save(
        TastingNote(
          id: 'a',
          cheeseName: 'A',
          tastedAt: DateTime(2024, 3, 3),
          createdAt: DateTime.utc(2024, 3, 3),
        ),
      );
      await repo.save(
        TastingNote(
          id: 'b',
          cheeseName: 'B',
          tastedAt: DateTime(2026, 8, 1),
          createdAt: DateTime.utc(2026, 8, 1),
        ),
      );
    });
    await pumpApp(tester, at: '/account', db: db);
    expect(find.text('MEMBER SINCE 2024 · 2 NOTES'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '   ');
    // Blur by focusing nothing: tap outside the field.
    await tester.tap(find.text('Account'));
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final saved = await onDb(tester, () => SettingsRepository(db).load());
    expect(saved.displayName, isNull);
    expect(find.text('You'), findsOneWidget);
  });
}
