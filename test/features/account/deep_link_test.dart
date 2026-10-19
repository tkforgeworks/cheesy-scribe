import 'package:cheesy_scribe/data/forge_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_core/testing.dart';

import '../../support.dart';

/// What GoTrue redirects to after verifying a mail link (PKCE flow): the
/// App Link as sent plus the one-time code (CHEESE-68).
const link = '$scribeAuthRedirectUrl?code=c69abc';

/// The same for a mail sent before rc.9, which used the custom scheme.
const legacyLink = '$legacyAuthCallbackUrl/?code=c69abc';

const session = ForgeSession(userId: 'u1', email: 'tim@example.com');

void main() {
  // rc.2: the link opened the app, and go_router showed "Page not found:
  // no routes for location" because the whole URI arrived as a route.
  testApp('a mail link opening the app cold lands on Account', (tester) async {
    await pumpApp(tester, at: link);
    expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
    expect(find.textContaining('no routes'), findsNothing);
    expect(find.textContaining('not found'), findsNothing);
  });

  testApp('a mail link arriving while running goes to Account, then the '
      'recovery state opens set-password', (tester) async {
    final auth = FakeForgeAuth();
    addTearDown(auth.dispose);
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, auth: auth);
    expect(find.text('Your tastings'), findsOneWidget);

    await openLink(tester, link);
    expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
    expect(find.textContaining('no routes'), findsNothing);

    // supabase_flutter exchanges the code and the stream reports recovery.
    auth.startPasswordRecovery(session);
    await tester.pumpAndSettle();
    expect(find.text('Choose a new password'), findsOneWidget);
  });

  testApp('a mail sent before the App Link switch still opens Account', (
    tester,
  ) async {
    await pumpApp(tester, at: legacyLink);
    expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
    expect(find.textContaining('no routes'), findsNothing);
  });

  testApp('a confirmation link signs in and Account shows the account', (
    tester,
  ) async {
    final auth = FakeForgeAuth();
    addTearDown(auth.dispose);
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpApp(tester, at: link, auth: auth);
    auth.signIn(session);
    await tester.pumpAndSettle();
    expect(find.text('Signed in'), findsOneWidget);
    expect(find.text('tim@example.com'), findsOneWidget);
  });
}
