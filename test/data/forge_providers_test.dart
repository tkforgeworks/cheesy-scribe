import 'dart:io';

import 'package:cheesy_scribe/data/forge_providers.dart';
import 'package:cheesy_scribe/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_core/testing.dart';

import '../support.dart';

/// The app's container, with [authStateProvider] kept alive: a
/// `StreamProvider` nobody watches reads as loading, so the tests hold a
/// listener the way the Account screen does.
Future<ProviderContainer> containerOf(WidgetTester tester) async {
  final c = ProviderScope.containerOf(tester.element(find.byType(ScribeApp)));
  final sub = c.listen(authStateProvider, (_, _) {});
  addTearDown(sub.close);
  await tester.pump();
  return c;
}

void main() {
  test('the test build has no defines; the redirect is the App Link', () {
    expect(scribeSupabaseConfig.isConfigured, isFalse);
    expect(scribeSupabaseConfig.hasGoogle, isFalse);
    expect(
      scribeSupabaseConfig.authRedirectUrl,
      'https://tkforgeworks.com/apps/cheesy-scribe/auth/',
    );
  });

  test('the redirect is an HTTPS URL the manifest claims with autoVerify', () {
    // CHEESE-68: an Android App Link. GoTrue appends ?code=… to the URL as
    // sent, so the manifest claims the path as a prefix and the allow list
    // entry must carry the same trailing slash.
    final uri = Uri.parse(scribeAuthRedirectUrl);
    expect(uri.scheme, 'https');
    expect(uri.host, 'tkforgeworks.com');
    expect(uri.path, endsWith('/'));
    final prefix = uri.path.substring(0, uri.path.length - 1);
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(
      manifest,
      contains(
        'android:scheme="https" android:host="${uri.host}" '
        'android:pathPrefix="$prefix"',
      ),
    );
    final filter = manifest.indexOf('android:autoVerify="true"');
    expect(filter, greaterThan(-1));
    expect(manifest.indexOf('android:host="${uri.host}"'), greaterThan(filter));
    expect(manifest, isNot(contains('com.tkforgeworks.cheesyscribe')));
  });

  test('isAuthCallback recognises both links with whatever GoTrue appends', () {
    expect(
      isAuthCallback(Uri.parse('$scribeAuthRedirectUrl?code=abc')),
      isTrue,
    );
    expect(
      isAuthCallback(
        Uri.parse(
          '$scribeAuthRedirectUrl#error=access_denied&error_code=otp_expired',
        ),
      ),
      isTrue,
    );
    // go_router hands the location over without its trailing slash.
    expect(
      isAuthCallback(
        Uri.parse('https://tkforgeworks.com/apps/cheesy-scribe/auth?code=abc'),
      ),
      isTrue,
    );
    expect(
      isAuthCallback(
        Uri.parse('https://tkforgeworks.com/apps/cheesy-scribe/authx'),
      ),
      isFalse,
    );
    expect(
      isAuthCallback(
        Uri.parse('$scribeAuthRedirectUrl?token_hash=abc&type=signup'),
      ),
      isTrue,
    );
    // The rc.2–rc.8 custom scheme is no longer claimed.
    expect(
      isAuthCallback(
        Uri.parse('com.tkforgeworks.cheesyscribe://auth-callback/?code=abc'),
      ),
      isFalse,
    );
    expect(
      isAuthCallback(
        Uri.parse('https://tkforgeworks.com/privacy/cheesy-scribe/'),
      ),
      isFalse,
    );
    expect(
      isAuthCallback(
        Uri.parse('https://example.com/apps/cheesy-scribe/auth/?code=x'),
      ),
      isFalse,
    );
    expect(isAuthCallback(Uri.parse('/notes')), isFalse);
  });

  testApp('pumpApp injects a signed-out fake backend by default', (
    tester,
  ) async {
    await pumpApp(tester);
    final c = await containerOf(tester);
    expect(c.read(forgeCoreProvider), isNull);
    expect(c.read(forgeAuthProvider), isA<FakeForgeAuth>());
    expect(c.read(forgeAccountsProvider), isA<FakeForgeAccounts>());
    expect(c.read(backupAvailableProvider), isTrue);
    expect(c.read(authStateProvider).value?.isSignedIn, isFalse);
    expect(c.read(sessionProvider), isNull);
  });

  testApp('a seeded fake session is visible through the providers', (
    tester,
  ) async {
    final auth = FakeForgeAuth();
    addTearDown(auth.dispose);
    auth.signIn(FakeForgeAuth.fakeSession);
    await pumpApp(tester, auth: auth);
    final c = await containerOf(tester);
    expect(c.read(sessionProvider)?.email, 'fake@example.com');
    await auth.signOut();
    await tester.pumpAndSettle();
    expect(c.read(sessionProvider), isNull);
    expect(c.read(authStateProvider).value?.event, ForgeAuthEvent.signedOut);
  });

  testApp('backup: false models a build with no configuration', (tester) async {
    await pumpApp(tester, backup: false);
    final c = await containerOf(tester);
    expect(c.read(forgeAuthProvider), isNull);
    expect(c.read(forgeAccountsProvider), isNull);
    expect(c.read(backupAvailableProvider), isFalse);
    expect(c.read(authStateProvider).value, ForgeAuthState.signedOut);
  });
}
