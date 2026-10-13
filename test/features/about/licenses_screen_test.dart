import 'package:cheesy_scribe/features/about/licenses_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

void main() {
  testApp('summarises the licences and opens the full notices', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, at: '/licenses');
    expect(find.widgetWithText(AppBar, 'Open-source licenses'), findsOneWidget);
    expect(find.text(LicensesScreen.intro), findsOneWidget);
    expect(find.text('Apache License 2.0'), findsOneWidget);
    expect(find.text('github.com/tkforgeworks/cheesy-scribe'), findsOneWidget);
    expect(
      LicensesScreen.sourceUri.toString(),
      'https://github.com/tkforgeworks/cheesy-scribe',
    );
    expect(find.textContaining('SIL Open Font License 1.1'), findsOneWidget);
    expect(find.text(LicensesScreen.assetsLine), findsOneWidget);

    await tester.tap(find.byKey(const Key('licenses-all')));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(LicensesScreen), findsOneWidget);
  });

  test('registers the bundled font licences once', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerBundledFontLicenses();
    registerBundledFontLicenses();
    final entries = await LicenseRegistry.licenses.toList();
    for (final (family, _) in bundledFontLicenses) {
      final matches = entries.where((e) => e.packages.contains(family));
      expect(matches, hasLength(1), reason: family);
      final text = matches.single.paragraphs.map((p) => p.text).join('\n');
      expect(text, contains('SIL Open Font License'), reason: family);
    }
  });
}
