import 'package:cheesy_scribe/features/about/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

void main() {
  testApp('renders the about page and opens the licenses', (tester) async {
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
    expect(find.text('tkforgeworks.com'), findsOneWidget);
    expect(find.text(AboutScreen.privacyLine), findsOneWidget);

    await tester.tap(find.byKey(const Key('about-licenses')));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Your tastings'), findsOneWidget);
  });
}
