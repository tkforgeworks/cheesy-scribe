import 'package:cheesy_scribe/features/account/account_screen.dart';
import 'package:cheesy_scribe/features/account/add_password_screen.dart';
import 'package:cheesy_scribe/features/account/auth_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_core/testing.dart';
import 'package:forge_ui/forge_ui.dart';

import '../../support.dart';

const emailOnly = ForgeSession(
  userId: 'tim',
  email: 'tim@example.com',
  emailConfirmed: true,
  identities: [
    ForgeIdentity(
      id: 'tim@example.com',
      identityId: 'link-email',
      provider: ForgeIdentityProvider.email,
      email: 'tim@example.com',
    ),
  ],
);

const googleOnly = ForgeSession(
  userId: 'tim',
  email: 'tim@example.com',
  emailConfirmed: true,
  identities: [
    ForgeIdentity(
      id: '1234',
      identityId: 'link-google',
      provider: ForgeIdentityProvider.google,
      email: 'tim@example.com',
    ),
  ],
);

/// The signed-in Account page's management rows (CHEESE-64).
void main() {
  Future<(FakeForgeAuth, FakeForgeAccounts)> boot(
    WidgetTester tester,
    ForgeSession session, {
    String? username,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final auth = FakeForgeAuth(
      initial: ForgeAuthState(event: ForgeAuthEvent.initial, session: session),
    );
    addTearDown(auth.dispose);
    final accounts = FakeForgeAccounts(auth, username: username);
    await pumpApp(tester, at: '/account', auth: auth, accounts: accounts);
    return (auth, accounts);
  }

  testApp('the username comes from the account and saves on Done', (
    tester,
  ) async {
    final (_, accounts) = await boot(tester, emailOnly, username: 'Curdy');
    expect(find.widgetWithText(TextField, 'Curdy'), findsOneWidget);
    expect(find.textContaining("your account's username"), findsOneWidget);
    await tester.enterText(
      find.byKey(ForgeAccountSettings.usernameFieldKey),
      'Big Cheese',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(accounts.usernameWrites, ['Big Cheese']);
    expect(find.text(AccountScreen.usernameSavedMessage), findsOneWidget);
    // The display name is untouched: it is this phone's.
    expect(find.widgetWithText(TextField, 'You'), findsNothing);
  });

  testApp('a refused username shows plain copy', (tester) async {
    final (_, accounts) = await boot(tester, emailOnly);
    accounts.nextError = ForgeDataError.invalid;
    await tester.enterText(
      find.byKey(ForgeAccountSettings.usernameFieldKey),
      'x' * 50,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text(dataErrorCopy(ForgeDataError.invalid)), findsOneWidget);
  });

  testApp('Link Google adds the method; a taken account is explained', (
    tester,
  ) async {
    final (auth, _) = await boot(tester, emailOnly);
    expect(find.byKey(ForgeAccountSettings.linkGoogleKey), findsOneWidget);
    expect(find.byKey(ForgeAccountSettings.setPasswordKey), findsNothing);
    auth.linkGoogleResult = const ForgeAuthFailure(
      ForgeAuthError.identityAlreadyLinked,
      'identity_already_exists',
    );
    await tester.ensureVisible(find.byKey(ForgeAccountSettings.linkGoogleKey));
    await tester.tap(find.byKey(ForgeAccountSettings.linkGoogleKey));
    await tester.pumpAndSettle();
    expect(
      find.text(authErrorCopy(ForgeAuthError.identityAlreadyLinked)),
      findsOneWidget,
    );
    auth.linkGoogleResult = null;
    await tester.tap(find.byKey(ForgeAccountSettings.linkGoogleKey));
    await tester.pumpAndSettle();
    expect(auth.linkGoogleCalls, 2);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('CONNECTED'), findsNWidgets(2));
    expect(find.byKey(ForgeAccountSettings.linkGoogleKey), findsNothing);
  });

  testApp('Set a password opens the form and saves through setPassword', (
    tester,
  ) async {
    final (auth, _) = await boot(tester, googleOnly);
    expect(find.byKey(ForgeAccountSettings.linkGoogleKey), findsNothing);
    await tester.ensureVisible(find.byKey(ForgeAccountSettings.setPasswordKey));
    await tester.tap(find.byKey(ForgeAccountSettings.setPasswordKey));
    await tester.pumpAndSettle();
    expect(find.text(AddPasswordScreen.heading), findsOneWidget);
    await tester.enterText(
      find.byKey(ForgeSetPasswordScreen.passwordFieldKey),
      'longenough1',
    );
    await tester.enterText(
      find.byKey(ForgeSetPasswordScreen.confirmFieldKey),
      'longenough1',
    );
    await tester.tap(find.byKey(ForgeSetPasswordScreen.submitKey));
    await tester.pumpAndSettle();
    expect(auth.passwordUpdates, ['longenough1']);
    expect(find.text(AddPasswordScreen.savedMessage), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Account'), findsOneWidget);
    // Leaving it without saving signs nobody out (unlike the reset flow).
    await tester.tap(find.byKey(ForgeAccountSettings.setPasswordKey));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(auth.signOutCalls, isEmpty);
  });
}
