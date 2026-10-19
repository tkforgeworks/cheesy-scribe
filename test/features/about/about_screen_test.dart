import 'package:cheesy_scribe/features/about/about_screen.dart';
import 'package:cheesy_scribe/features/about/licenses_screen.dart';
import 'package:flutter/material.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';

import '../../support.dart';

void main() {
  testApp('renders the about page and opens the licenses summary', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About Cheesy Scribe'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'About Cheesy Scribe'), findsOneWidget);
    expect(find.text('Cheesy Scribe'), findsOneWidget);
    expect(find.text('VERSION 0.1.0'), findsOneWidget);
    expect(find.text(AboutScreen.blurb), findsOneWidget);
    expect(find.text('A TK FORGEWORKS PRODUCT'), findsOneWidget);
    expect(find.byType(ForgeWorksMark), findsOneWidget);
    expect(find.text('Send feedback'), findsOneWidget);
    expect(find.text('tkforgeworks.com'), findsOneWidget);
    expect(find.text('Privacy policy'), findsOneWidget);
    expect(
      AboutScreen.privacyUri.toString(),
      'https://tkforgeworks.com/privacy/cheesy-scribe/',
    );
    expect(find.text(AboutScreen.privacyLine), findsOneWidget);

    await tester.tap(find.byKey(ForgeAboutScreen.licensesKey));
    await tester.pumpAndSettle();
    expect(find.byType(LicensesScreen), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'About Cheesy Scribe'), findsOneWidget);
    expect(find.byTooltip('Back'), findsNothing);
    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My tasting notes'));
    await tester.pumpAndSettle();
    expect(find.text('Your tastings'), findsOneWidget);
  });

  // CHEESE-65: Play wants deletion reachable from where the user is.
  testApp('Delete account on About goes to Account when signed in', (
    tester,
  ) async {
    final auth = FakeForgeAuth(
      initial: const ForgeAuthState(
        event: ForgeAuthEvent.initial,
        session: ForgeSession(userId: 'tim', email: 'tim@example.com'),
      ),
    );
    addTearDown(auth.dispose);
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, at: '/about', auth: auth);
    await tester.ensureVisible(find.byKey(ForgeAboutScreen.deleteAccountKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ForgeAboutScreen.deleteAccountKey));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
    expect(find.byKey(ForgeAccountSettings.deleteKey), findsOneWidget);
  });

  testApp('the row is present signed out and absent without a backend', (
    tester,
  ) async {
    await pumpApp(tester, at: '/about');
    expect(find.byKey(ForgeAboutScreen.deleteAccountKey), findsOneWidget);
    await pumpApp(tester, at: '/about', backup: false);
    expect(find.byKey(ForgeAboutScreen.deleteAccountKey), findsNothing);
  });
}
