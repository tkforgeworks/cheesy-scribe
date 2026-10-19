import 'package:cheesy_scribe/data/forge_providers.dart';
import 'package:cheesy_scribe/features/account/auth_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_core/testing.dart';

import '../../support.dart';

/// What the mail's button links to (CHEESE-68, forge-core FC-13): the App
/// Link as sent plus the verification token the template appends.
const link = '$scribeAuthRedirectUrl?token_hash=pkce_c69abc&type=signup';
const resetLink = '$scribeAuthRedirectUrl?token_hash=pkce_r0&type=recovery';

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

    await openLink(tester, resetLink);
    expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
    expect(find.textContaining('no routes'), findsNothing);

    // forge_core verifies the token and the stream reports recovery.
    auth.startPasswordRecovery(session);
    await tester.pumpAndSettle();
    expect(find.text('Choose a new password'), findsOneWidget);
    expect(find.text(resetLinkVerifiedMessage), findsOneWidget);
  });

  testApp('an expired link says so on Account and stays signed out', (
    tester,
  ) async {
    final auth = FakeForgeAuth();
    addTearDown(auth.dispose);
    await pumpApp(tester, at: link, auth: auth);
    expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
    // forge_core verified the token on its own and it was refused.
    auth.failMailLink();
    await tester.pumpAndSettle();
    expect(
      find.text(authErrorCopy(ForgeAuthError.linkExpired)),
      findsOneWidget,
    );
    expect(find.text('Signed in'), findsNothing);
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
    expect(find.text(emailConfirmedMessage), findsOneWidget);
  });

  testApp('a sign-in that no mail link produced is not greeted', (
    tester,
  ) async {
    final auth = FakeForgeAuth();
    addTearDown(auth.dispose);
    await pumpApp(tester, auth: auth);
    auth.signIn(session);
    await tester.pumpAndSettle();
    expect(find.text(emailConfirmedMessage), findsNothing);
    expect(find.text(resetLinkVerifiedMessage), findsNothing);
  });
}
