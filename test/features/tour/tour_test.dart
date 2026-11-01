import 'dart:io';

import 'package:cheesy_scribe/data/db/app_database.dart';
import 'package:cheesy_scribe/data/repositories/settings_repository.dart';
import 'package:cheesy_scribe/features/settings/settings_screen.dart';
import 'package:cheesy_scribe/features/tour/tour_highlights.dart';
import 'package:cheesy_scribe/features/tour/tour_screen.dart';
import 'package:cheesy_scribe/features/tour/tour_slides.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

/// The phone the tour's pictures were rendered for.
void phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

Future<int> storedTourVersion(WidgetTester tester, AppDatabase db) async =>
    (await onDb(tester, () => SettingsRepository(db).load())).tourVersion;

Finder get tour => find.byType(TourScreen);

Future<void> next(WidgetTester tester) async {
  await tester.tap(find.byKey(TourScreen.nextKey));
  await tester.pumpAndSettle();
}

void main() {
  testApp('first launch opens the tour over the journal', (tester) async {
    phone(tester);
    final db = await pumpApp(tester, tourSeen: false);
    expect(tour, findsOneWidget);
    expect(find.text(tourSlides.first.title), findsOneWidget);
    expect(find.text('1 · YOUR FIRST NOTE'), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(find.byKey(TourScreen.backKey)).onPressed,
      isNull,
    );
    expect(await storedTourVersion(tester, db), 0);

    await tester.tap(find.byKey(TourScreen.skipKey));
    await tester.pumpAndSettle();
    expect(tour, findsNothing);
    expect(find.text('Your tastings'), findsOneWidget);
    expect(await storedTourVersion(tester, db), TourScreen.version);
  });

  testApp('a phone that has seen this tour goes straight to the journal', (
    tester,
  ) async {
    phone(tester);
    await pumpApp(tester);
    expect(tour, findsNothing);
    expect(find.text('Your tastings'), findsOneWidget);
  });

  testApp('a launch that lands somewhere else leaves the tour for later', (
    tester,
  ) async {
    phone(tester);
    // A mail link lands on Account; any screen but the journal does.
    final db = await pumpApp(tester, at: '/settings', tourSeen: false);
    expect(tour, findsNothing);
    expect(await storedTourVersion(tester, db), 0);
  });

  testApp('Next walks every slide; the last one starts a note', (tester) async {
    phone(tester);
    final db = await pumpApp(tester, tourSeen: false);
    for (final (i, slide) in tourSlides.indexed) {
      expect(find.text(slide.title), findsOneWidget, reason: 'slide $i');
      expect(
        find.text(
          '${slide.chapter.index + 1} · ${slide.chapter.label}'.toUpperCase(),
        ),
        findsOneWidget,
      );
      if (i < tourSlides.length - 1) await next(tester);
    }
    expect(find.text('Done'), findsOneWidget);
    expect(find.text(TourScreen.writeLabel), findsOneWidget);
    // Back steps back from the end too.
    await tester.tap(find.byKey(TourScreen.backKey));
    await tester.pumpAndSettle();
    expect(find.text(tourSlides[tourSlides.length - 2].title), findsOneWidget);
    await next(tester);

    await tester.tap(find.text(TourScreen.writeLabel));
    await tester.pumpAndSettle();
    expect(tour, findsNothing);
    expect(find.widgetWithText(AppBar, 'New tasting note'), findsOneWidget);
    expect(await storedTourVersion(tester, db), TourScreen.version);
  });

  testApp('Done on the last slide closes the tour', (tester) async {
    phone(tester);
    final db = await pumpApp(tester, tourSeen: false);
    for (var i = 1; i < tourSlides.length; i++) {
      await next(tester);
    }
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(tour, findsNothing);
    expect(find.text('Your tastings'), findsOneWidget);
    expect(await storedTourVersion(tester, db), TourScreen.version);
  });

  testApp('swiping moves between slides', (tester) async {
    phone(tester);
    await pumpApp(tester, tourSeen: false);
    await tester.fling(
      find.byKey(TourScreen.pagesKey),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text(tourSlides[1].title), findsOneWidget);
  });

  testApp('system back goes back a slide, then closes the tour', (
    tester,
  ) async {
    phone(tester);
    final db = await pumpApp(tester, tourSeen: false);
    await next(tester);
    expect(find.text(tourSlides[1].title), findsOneWidget);

    await systemBack(tester);
    expect(tour, findsOneWidget);
    expect(find.text(tourSlides.first.title), findsOneWidget);
    expect(await storedTourVersion(tester, db), 0);

    await systemBack(tester);
    expect(tour, findsNothing);
    expect(find.text('Your tastings'), findsOneWidget);
    expect(await storedTourVersion(tester, db), TourScreen.version);
  });

  testApp('Settings replays the tour', (tester) async {
    phone(tester);
    await pumpApp(tester, at: '/settings');
    expect(tour, findsNothing);
    await tester.scrollUntilVisible(find.byKey(SettingsScreen.tourRowKey), 200);
    expect(find.text(SettingsScreen.tourTitle), findsOneWidget);
    await tester.tap(find.byKey(SettingsScreen.tourRowKey));
    await tester.pumpAndSettle();
    expect(tour, findsOneWidget);
    expect(find.text(tourSlides.first.title), findsOneWidget);

    await tester.tap(find.byKey(TourScreen.skipKey));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
  });

  group('pictures', () {
    final frames = {for (final s in tourSlides) ...s.frames};

    test('every slide has a light and a dark picture', () {
      for (final frame in frames) {
        for (final b in Brightness.values) {
          final path = TourScreen.asset(frame, b);
          expect(File(path).existsSync(), isTrue, reason: path);
        }
      }
    });

    test('every picture has highlights inside it, and no spares', () {
      expect(tourHighlights.keys.toSet(), frames);
      for (final MapEntry(key: frame, value: rects) in tourHighlights.entries) {
        expect(rects, isNotEmpty, reason: frame);
        for (final r in rects) {
          expect(r.left >= 0 && r.top >= 0, isTrue, reason: '$frame $r');
          expect(r.right <= 1 && r.bottom <= 1, isTrue, reason: '$frame $r');
          expect(r.width > 0 && r.height > 0, isTrue, reason: '$frame $r');
        }
      }
    });

    test('no picture is left over from an old slide', () {
      final files = Directory('assets/tour')
          .listSync()
          .map((f) => f.uri.pathSegments.last)
          .toSet();
      final wanted = {
        for (final f in frames)
          for (final b in Brightness.values) '${b.name}-$f.webp',
      };
      expect(files, wanted);
    });
  });
}
