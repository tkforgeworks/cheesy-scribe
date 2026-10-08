import 'package:cheesy_scribe/app/shell/scribe_drawer.dart';
import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/notes_repository.dart';
import 'package:cheesy_scribe/app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'support.dart';

Future<void> openDrawer(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Open menu'));
  await tester.pumpAndSettle();
}

Future<void> tapDrawerItem(WidgetTester tester, String label) async {
  await openDrawer(tester);
  await tester.tap(find.widgetWithText(DrawerPill, label));
  await tester.pumpAndSettle();
}

bool pillSelected(WidgetTester tester, String label) =>
    tester.widget<DrawerPill>(find.widgetWithText(DrawerPill, label)).selected;

void main() {
  testApp('boots on /notes with the search bar and FAB', (tester) async {
    await pumpApp(tester);
    expect(find.text('Search your tastings'), findsOneWidget);
    expect(find.byType(ForgeFab), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);
  });

  testApp('drawer shows header, account row and version footer', (
    tester,
  ) async {
    await pumpApp(tester);
    await openDrawer(tester);
    expect(find.byType(Drawer), findsOneWidget);
    expect(find.text('Cheesy Scribe'), findsOneWidget);
    expect(find.text('Your notebook'), findsOneWidget);
    expect(find.text('A TK FORGEWORKS PRODUCT · V0.1.0'), findsOneWidget);
    expect(pillSelected(tester, 'My tasting notes'), isTrue);
    expect(pillSelected(tester, 'Cheese library'), isFalse);
    // Local-first: no sign out.
    expect(find.text('Sign out'), findsNothing);
  });

  testApp('every drawer item reaches its screen', (tester) async {
    await pumpApp(tester);

    await tapDrawerItem(tester, 'Cheese library');
    expect(find.text('Search the library'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^\d+ STYLES$')), findsOneWidget);
    await openDrawer(tester);
    expect(pillSelected(tester, 'Cheese library'), isTrue);
    expect(pillSelected(tester, 'My tasting notes'), isFalse);
    await tester.tap(find.widgetWithText(DrawerPill, 'Stats & insights'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Stats & insights'), findsOneWidget);

    await tapDrawerItem(tester, 'Settings');
    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);

    await tapDrawerItem(tester, 'My tasting notes');
    expect(find.text('Search your tastings'), findsOneWidget);

    // Pushed routes cover the shell and close back to it.
    await tapDrawerItem(tester, 'New tasting note');
    expect(find.widgetWithText(AppBar, 'New tasting note'), findsOneWidget);
    expect(find.byTooltip('Open menu'), findsNothing);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Search your tastings'), findsOneWidget);

    // Account and About are shell destinations too (CHEESE-47): menu icon,
    // selected pill, no back arrow.
    await tapDrawerItem(tester, 'Account');
    expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
    await openDrawer(tester);
    expect(pillSelected(tester, 'Account'), isTrue);
    await tester.tap(find.widgetWithText(DrawerPill, 'About Cheesy Scribe'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'About Cheesy Scribe'), findsOneWidget);
    expect(find.text('VERSION 0.1.0'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
    await openDrawer(tester);
    expect(pillSelected(tester, 'About Cheesy Scribe'), isTrue);
    await tester.tap(find.widgetWithText(DrawerPill, 'My tasting notes'));
    await tester.pumpAndSettle();
    expect(find.text('Search your tastings'), findsOneWidget);
  });

  testApp('search-bar avatar goes to Account', (tester) async {
    await pumpApp(tester);
    await tester.tap(
      find.descendant(
        of: find.byType(SearchBar),
        matching: find.byType(WedgeGlyph),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
    expect(find.byTooltip('Open menu'), findsOneWidget);
  });

  group('system back (CHEESE-47)', () {
    // Counts SystemNavigator.pop calls, i.e. "leave the app".
    late int exits;
    void watchExits(WidgetTester tester) {
      exits = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'SystemNavigator.pop') exits++;
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
    }

    for (final (path, marker) in [
      ('/notes', 'Search your tastings'),
      ('/library', 'Search the library'),
      ('/stats', 'Stats & insights'),
      ('/settings', 'Settings'),
      ('/account', 'Account'),
      ('/about', 'About Cheesy Scribe'),
    ]) {
      testApp('on $path opens the drawer, then leaves the app', (tester) async {
        await pumpApp(tester, at: path);
        watchExits(tester);
        expect(find.byType(Drawer), findsNothing);

        await systemBack(tester);
        expect(find.byType(Drawer), findsOneWidget);
        expect(exits, 0);

        await systemBack(tester);
        expect(exits, 1);
        expect(find.textContaining(marker), findsWidgets);
      });
    }

    testApp('pops stacked screens before reaching the drawer', (tester) async {
      final db = openTestDatabase();
      await onDb(tester, () async {
        final repo = NotesRepository(db);
        await repo.save(
          TastingNote(
            id: '41',
            cheeseName: 'Brie',
            tastedAt: DateTime(2026, 7, 1),
            createdAt: DateTime.utc(2026, 7, 1),
          ),
        );
        await repo.save(
          TastingNote(
            id: '42',
            cheeseName: 'Comté',
            tastedAt: DateTime(2026, 8, 1),
            createdAt: DateTime.utc(2026, 8, 1),
          ),
        );
      });
      await pumpApp(tester, at: '/notes/42', db: db);
      watchExits(tester);
      expect(find.widgetWithText(AppBar, 'Tasting note'), findsOneWidget);

      await systemBack(tester);
      expect(find.text('Search your tastings'), findsOneWidget);
      expect(find.byType(Drawer), findsNothing);

      // A sheet over a destination closes first too.
      await tester.longPress(find.text('Brie'));
      await tester.pumpAndSettle();
      expect(find.text('Delete'), findsOneWidget);
      await systemBack(tester);
      expect(find.text('Delete'), findsNothing);
      expect(find.byType(Drawer), findsNothing);
      expect(exits, 0);
    });

    testApp('licenses pops back to About', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpApp(tester, at: '/about');
      watchExits(tester);
      await tester.tap(find.byKey(const Key('about-licenses')));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(AppBar, 'Open-source licenses'),
        findsOneWidget,
      );

      await systemBack(tester);
      expect(
        find.widgetWithText(AppBar, 'About Cheesy Scribe'),
        findsOneWidget,
      );
      expect(find.byType(Drawer), findsNothing);
      expect(exits, 0);
    });
  });

  testApp('menu icon opens the drawer on Stats and Settings', (tester) async {
    await pumpApp(tester, at: '/stats');
    await openDrawer(tester);
    expect(pillSelected(tester, 'Stats & insights'), isTrue);
    await tester.tap(find.widgetWithText(DrawerPill, 'Settings'));
    await tester.pumpAndSettle();
    await openDrawer(tester);
    expect(pillSelected(tester, 'Settings'), isTrue);
  });

  testApp('note detail links to edit; FAB opens the form', (tester) async {
    final db = openTestDatabase();
    await onDb(
      tester,
      () => NotesRepository(db).save(
        TastingNote(
          id: '42',
          cheeseName: 'Comté',
          tastedAt: DateTime(2026, 8, 1),
          createdAt: DateTime.utc(2026, 8, 1),
        ),
      ),
    );
    await pumpApp(tester, at: '/notes/42', db: db);
    expect(find.widgetWithText(AppBar, 'Tasting note'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Edit tasting note'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Search your tastings'), findsOneWidget);

    await tester.tap(find.byType(ForgeFab));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'New tasting note'), findsOneWidget);
  });

  testApp('style detail opens over the library', (tester) async {
    await pumpApp(tester, at: '/library/cheddar');
    expect(find.widgetWithText(AppBar, 'Cheese style'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Search the library'), findsOneWidget);
  });

  testApp('drawer shows the saved display name; theme follows settings', (
    tester,
  ) async {
    await pumpApp(
      tester,
      settings: const AppSettings(
        displayName: 'Tim',
        themeMode: ThemeMode.dark,
      ),
    );
    await openDrawer(tester);
    expect(find.text('Tim'), findsOneWidget);
    expect(find.text('Your notebook'), findsNothing);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  // CHEESE-43: plain `builder:` routes fall back to NoTransitionPage under
  // go_router 18, so pushed screens must animate (and keep predictive back)
  // through an explicit MaterialPage.
  testApp('pushed screens use the platform page transition', (tester) async {
    await pumpApp(tester);
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    for (final path in ['/licenses', '/notes/missing', '/library/fresh']) {
      router.push(path);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final route = ModalRoute.of(
        tester.element(find.byType(Scaffold, skipOffstage: false).last),
      )!;
      expect(route, isA<MaterialRouteTransitionMixin<void>>(), reason: path);
      expect(route.animation!.isAnimating, isTrue, reason: path);
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text('Search your tastings'), findsOneWidget, reason: path);
    }
  });
}
