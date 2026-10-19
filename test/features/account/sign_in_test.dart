import 'package:cheesy_scribe/features/account/account_screen.dart';
import 'package:cheesy_scribe/features/account/set_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_core/testing.dart';
import 'package:forge_ui/forge_ui.dart';

import '../../support.dart';

const emailSession = ForgeSession(
  userId: 'u-email',
  email: 'new@example.com',
  emailConfirmed: true,
  identities: [
    ForgeIdentity(
      id: 'new@example.com',
      identityId: 'link-email',
      provider: ForgeIdentityProvider.email,
      email: 'new@example.com',
    ),
  ],
);

void main() {
  Future<FakeForgeAuth> boot(
    WidgetTester tester, {
    String at = '/account',
    bool backup = true,
    FakeForgeAuth? auth,
  }) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final fake = auth ?? FakeForgeAuth();
    if (auth == null) addTearDown(fake.dispose);
    await pumpApp(tester, at: at, auth: fake, backup: backup);
    return fake;
  }

  Future<void> enterCredentials(
    WidgetTester tester,
    String email,
    String password,
  ) async {
    await tester.enterText(find.byKey(ForgeSignInPanel.emailFieldKey), email);
    await tester.enterText(
      find.byKey(ForgeSignInPanel.passwordFieldKey),
      password,
    );
    await tester.tap(find.byKey(ForgeSignInPanel.submitKey));
    await tester.pumpAndSettle();
  }

  testApp('a build with no backend says so and offers no sign-in', (
    tester,
  ) async {
    await boot(tester, backup: false);
    expect(find.text(AccountScreen.backupUnavailable), findsOneWidget);
    expect(find.byType(ForgeSignInPanel), findsNothing);
    expect(find.byType(ForgeAccountSettings), findsNothing);
    // The local profile is untouched.
    expect(find.text('DISPLAY NAME'), findsOneWidget);
  });

  testApp(
    'Google signs in, the account shows, and sign out brings the panel back',
    (tester) async {
      final auth = await boot(tester);
      expect(find.text(AccountScreen.signInHeading), findsOneWidget);
      expect(find.byType(ForgeSignInPanel), findsOneWidget);
      expect(find.text('DISPLAY NAME'), findsOneWidget);

      await tester.tap(find.byType(ForgeSignInButton));
      await tester.pumpAndSettle();
      expect(auth.googleSignIns, 1);
      expect(find.byType(ForgeSignInPanel), findsNothing);
      expect(find.text('fake@example.com'), findsWidgets); // account + method
      expect(find.text('Signed in'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('CONNECTED'), findsOneWidget);
      // CHEESE-64: username and, for a Google-only account, Set a
      // password; Delete account waits for CHEESE-65.
      expect(find.byKey(ForgeAccountSettings.usernameFieldKey), findsOneWidget);
      expect(find.byKey(ForgeAccountSettings.setPasswordKey), findsOneWidget);
      expect(find.byKey(ForgeAccountSettings.deleteKey), findsNothing);
      // The display name stays local and editable.
      expect(find.text('DISPLAY NAME'), findsOneWidget);

      await tester.tap(find.byKey(ForgeAccountSettings.signOutKey));
      await tester.pumpAndSettle();
      expect(find.text(AccountScreen.signOutAside), findsOneWidget);
      expect(find.byKey(ForgeSignOutSheet.eraseKey), findsNothing);
      await tester.tap(find.byKey(ForgeSignOutSheet.confirmKey));
      await tester.pumpAndSettle();
      expect(auth.signOutCalls, [false]);
      expect(find.byType(ForgeSignInPanel), findsOneWidget);
    },
  );

  testApp('a Google failure shows its copy; cancelling shows nothing', (
    tester,
  ) async {
    final auth = await boot(tester);
    auth.googleResult = const ForgeAuthFailure(
      ForgeAuthError.noGoogleAccount,
      'No credential available',
    );
    await tester.tap(find.byType(ForgeSignInButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('no Google account'), findsOneWidget);
    expect(find.byType(ForgeSignInPanel), findsOneWidget);

    auth.googleResult = const ForgeAuthCancelled();
    await tester.tap(find.byType(ForgeSignInButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('no Google account'), findsNothing);
    expect(find.byType(ForgeErrorCard), findsNothing);
    expect(auth.googleSignIns, 2);
  });

  testApp('creating an account waits on the mail; the link signs in', (
    tester,
  ) async {
    final auth = await boot(tester);
    await tester.tap(find.byKey(ForgeSignInPanel.switchModeKey));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsOneWidget);
    await enterCredentials(tester, 'new@example.com', 'hunter2222');
    expect(auth.signUps, [('new@example.com', 'hunter2222')]);
    expect(find.text('One more step'), findsOneWidget);
    expect(find.textContaining('new@example.com'), findsOneWidget);

    // Send again is on a cooldown first.
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(ForgeCheckEmailScreen.resendKey))
          .onPressed,
      isNull,
    );
    await tester.pump(const Duration(seconds: 31));
    await tester.tap(find.byKey(ForgeCheckEmailScreen.resendKey));
    await tester.pumpAndSettle();
    expect(auth.resends, ['new@example.com']);

    // The confirmation link, opened on this phone.
    auth.signIn(emailSession);
    await tester.pumpAndSettle();
    expect(find.text('One more step'), findsNothing);
    expect(find.text('Signed in'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('CONNECTED'), findsOneWidget);
  });

  testApp(
    'a wrong password shows copy; an unconfirmed account goes to check-email',
    (tester) async {
      final auth = await boot(tester);
      auth.signInResult = const ForgeAuthFailure(
        ForgeAuthError.invalidCredentials,
        'invalid',
      );
      await enterCredentials(tester, 'a@b.co', 'wrongpass');
      expect(auth.signIns, [('a@b.co', 'wrongpass')]);
      expect(find.textContaining('did not match'), findsOneWidget);

      auth.signInResult = const ForgeAuthFailure(
        ForgeAuthError.emailNotConfirmed,
        'email_not_confirmed',
      );
      await tester.tap(find.byKey(ForgeSignInPanel.submitKey));
      await tester.pumpAndSettle();
      expect(find.text('One more step'), findsOneWidget);
      expect(find.textContaining('a@b.co'), findsOneWidget);
      // Back to the form with a different address.
      await tester.tap(find.byKey(ForgeCheckEmailScreen.changeEmailKey));
      await tester.pumpAndSettle();
      expect(find.byType(ForgeSignInPanel), findsOneWidget);
      expect(find.textContaining('did not match'), findsNothing);
    },
  );

  testApp('forgot password sends a reset; the link swaps in set-password', (
    tester,
  ) async {
    final auth = await boot(tester);
    await tester.tap(find.byKey(ForgeSignInPanel.forgotKey));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(ForgeSignInPanel.emailFieldKey),
      'a@b.co',
    );
    await tester.tap(find.byKey(ForgeSignInPanel.submitKey));
    await tester.pumpAndSettle();
    expect(auth.resets, ['a@b.co']);
    expect(find.text('Check your inbox'), findsOneWidget);
    expect(find.textContaining('If there is an account for'), findsOneWidget);
    await tester.pump(const Duration(seconds: 31));
    await tester.tap(find.byKey(ForgeCheckEmailScreen.resendKey));
    await tester.pumpAndSettle();
    expect(auth.resets, ['a@b.co', 'a@b.co']);

    auth.startPasswordRecovery(emailSession);
    await tester.pumpAndSettle();
    expect(find.text('Check your inbox'), findsNothing);
    expect(find.text('Choose a new password'), findsOneWidget);
    await tester.enterText(
      find.byKey(ForgeSetPasswordScreen.passwordFieldKey),
      'newpassword1',
    );
    await tester.enterText(
      find.byKey(ForgeSetPasswordScreen.confirmFieldKey),
      'newpassword1',
    );
    await tester.tap(find.byKey(ForgeSetPasswordScreen.submitKey));
    await tester.pumpAndSettle();
    expect(auth.passwordUpdates, ['newpassword1']);
    expect(find.text(SetPasswordScreen.savedMessage), findsOneWidget);
    expect(find.text('Choose a new password'), findsNothing);
    expect(find.text('Signed in'), findsOneWidget);
    expect(auth.signOutCalls, isEmpty);
  });

  testApp(
    'a recovery link from anywhere opens set-password; a weak password keeps it open',
    (tester) async {
      final auth = await boot(tester, at: '/notes');
      auth.startPasswordRecovery(emailSession);
      await tester.pumpAndSettle();
      expect(find.text('Choose a new password'), findsOneWidget);
      // A second emission does not stack a second screen.
      auth.startPasswordRecovery(emailSession);
      await tester.pumpAndSettle();
      expect(find.text('Choose a new password'), findsOneWidget);

      auth.updatePasswordResult = const ForgeAuthFailure(
        ForgeAuthError.weakPassword,
        'Password is too weak (pwned)',
      );
      await tester.enterText(
        find.byKey(ForgeSetPasswordScreen.passwordFieldKey),
        'password',
      );
      await tester.enterText(
        find.byKey(ForgeSetPasswordScreen.confirmFieldKey),
        'password',
      );
      await tester.tap(find.byKey(ForgeSetPasswordScreen.submitKey));
      await tester.pumpAndSettle();
      expect(find.textContaining('too easy to guess'), findsOneWidget);
      expect(find.text('Choose a new password'), findsOneWidget);
      expect(find.text(SetPasswordScreen.blurb), findsOneWidget);
      // Backing out without a saved password ends the recovery session: the
      // link alone must not leave the user signed in (rc.3).
      expect(auth.current.isSignedIn, isTrue);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Your tastings'), findsOneWidget);
      expect(auth.signOutCalls, [false]);
      expect(auth.current.isSignedIn, isFalse);
      expect(find.text(SetPasswordScreen.leftMessage), findsOneWidget);
    },
  );

  testApp('system back on set-password signs the recovery session out too', (
    tester,
  ) async {
    final auth = await boot(tester);
    auth.startPasswordRecovery(emailSession);
    await tester.pumpAndSettle();
    expect(find.text('Choose a new password'), findsOneWidget);
    await systemBack(tester);
    expect(find.text('Choose a new password'), findsNothing);
    expect(auth.signOutCalls, [false]);
    expect(find.byType(ForgeSignInPanel), findsOneWidget);
  });
}
