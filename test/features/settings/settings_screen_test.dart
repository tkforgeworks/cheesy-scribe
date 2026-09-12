import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/data/repositories/settings_repository.dart';
import 'package:cheesy_scribe/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

ThemeMode appThemeMode(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!;

void main() {
  testApp('theme and units persist and apply immediately', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = await pumpApp(tester, at: '/settings');
    expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
    for (final g in ['APPEARANCE', 'NOTIFICATIONS', 'DATA', 'ABOUT']) {
      expect(find.text(g), findsOneWidget, reason: g);
    }
    expect(appThemeMode(tester), ThemeMode.system);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(appThemeMode(tester), ThemeMode.dark);
    await tester.tap(find.text('€/kg'));
    await tester.pumpAndSettle();

    final saved = await onDb(tester, () => SettingsRepository(db).load());
    expect(saved.themeMode, ThemeMode.dark);
    expect(saved.units, PriceUnit.eurPerKg);

    // "Restart": a fresh app on the same database comes up dark, and the
    // form's price label follows the unit.
    await pumpApp(tester, at: '/notes/new', db: db);
    expect(appThemeMode(tester), ThemeMode.dark);
    expect(find.text('€/KG'), findsOneWidget);
  });

  testApp('deferred rows are disabled at 45 percent', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, at: '/settings');
    final reminder = tester.widget<ListTile>(
      find.byKey(const Key('reminder-row')),
    );
    expect(reminder.enabled, isFalse);
    expect(find.text('Coming soon. The cheese will wait.'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
    final export = tester.widget<ListTile>(find.byKey(const Key('export-row')));
    expect(export.enabled, isFalse);
    final opacities = tester
        .widgetList<Opacity>(
          find.ancestor(
            of: find.byKey(const Key('reminder-row')),
            matching: find.byType(Opacity),
          ),
        )
        .map((o) => o.opacity);
    expect(opacities, contains(SettingsScreen.disabledOpacity));
  });

  testApp('about group shows the version and opens licenses and About', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, at: '/settings');
    expect(find.text('0.1.0'), findsOneWidget);
    await tester.tap(find.text('Open-source licenses'));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('About Cheesy Scribe'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'About Cheesy Scribe'), findsOneWidget);
  });
}
