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
  test('the test build has no defines; the redirect is the app scheme', () {
    expect(scribeSupabaseConfig.isConfigured, isFalse);
    expect(scribeSupabaseConfig.hasGoogle, isFalse);
    expect(
      scribeSupabaseConfig.authRedirectUrl,
      'com.tkforgeworks.cheesy_scribe://auth-callback',
    );
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
