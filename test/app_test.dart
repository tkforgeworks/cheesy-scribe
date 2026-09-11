import 'package:cheesy_scribe/app/shell/scribe_drawer.dart';
import 'package:cheesy_scribe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> pumpApp(WidgetTester tester, {String at = '/notes'}) async {
  await tester.pumpWidget(ProviderScope(child: ScribeApp(initialLocation: at)));
  await tester.pumpAndSettle();
}

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
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Cheesy Scribe',
      packageName: 'com.tkforgeworks.cheesy_scribe',
      version: '0.1.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  testWidgets('boots on /notes with the search bar and FAB', (tester) async {
    await pumpApp(tester);
    expect(find.text('Search your tastings'), findsOneWidget);
    expect(find.text('New tasting notes'), findsOneWidget);
    expect(find.byType(Drawer), findsNothing);
  });

  testWidgets('drawer shows header, account row and version footer', (
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

  testWidgets('every drawer item reaches its screen', (tester) async {
    await pumpApp(tester);

    await tapDrawerItem(tester, 'Cheese library');
    expect(find.text('Search the library'), findsOneWidget);
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

    await tapDrawerItem(tester, 'Account');
    expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    await tapDrawerItem(tester, 'About Cheesy Scribe');
    expect(find.widgetWithText(AppBar, 'About Cheesy Scribe'), findsOneWidget);
    expect(find.text('VERSION 0.1.0'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Search your tastings'), findsOneWidget);
  });

  testWidgets('menu icon opens the drawer on Stats and Settings', (
    tester,
  ) async {
    await pumpApp(tester, at: '/stats');
    await openDrawer(tester);
    expect(pillSelected(tester, 'Stats & insights'), isTrue);
    await tester.tap(find.widgetWithText(DrawerPill, 'Settings'));
    await tester.pumpAndSettle();
    await openDrawer(tester);
    expect(pillSelected(tester, 'Settings'), isTrue);
  });

  testWidgets('note detail links to edit; FAB opens the form', (tester) async {
    await pumpApp(tester, at: '/notes/42');
    expect(find.widgetWithText(AppBar, 'Tasting note'), findsOneWidget);
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Edit tasting note'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Search your tastings'), findsOneWidget);

    await tester.tap(find.text('New tasting notes'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'New tasting note'), findsOneWidget);
  });

  testWidgets('style detail opens over the library', (tester) async {
    await pumpApp(tester, at: '/library/cheddar');
    expect(find.widgetWithText(AppBar, 'Cheese style'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Search the library'), findsOneWidget);
  });
}
