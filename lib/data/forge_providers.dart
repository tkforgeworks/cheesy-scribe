import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_core/forge_core.dart';

/// Where confirmation and password-reset mails send the user back to. App
/// code rather than configuration: it is the application id as a custom
/// scheme, declared as an intent filter in the Android manifest and on the
/// Supabase project's redirect allow list.
const scribeAuthRedirectUrl = 'com.tkforgeworks.cheesy_scribe://auth-callback';

/// The Supabase project this build talks to, read from the three
/// `--dart-define`s (`FORGE_SUPABASE_URL`, `FORGE_SUPABASE_PUBLISHABLE_KEY`,
/// `FORGE_GOOGLE_WEB_CLIENT_ID`; see `config/dev.example.json`). A build
/// without them is still a valid build: `isConfigured` is false, nothing is
/// initialised and the account features say backup isn't available.
const scribeSupabaseConfig = ForgeSupabaseConfig.fromEnvironment(
  authRedirectUrl: scribeAuthRedirectUrl,
);

/// The initialised backend handle, or null in a build with no
/// configuration. `main()` overrides this with the result of
/// `ForgeCore.initialize`; tests leave it null and override
/// [forgeAuthProvider] / [forgeAccountsProvider] with fakes instead, so no
/// test ever touches the network.
final forgeCoreProvider = Provider<ForgeCore?>((ref) => null);

/// Session state and sign-in; null when backup isn't available.
final forgeAuthProvider = Provider<ForgeAuth?>(
  (ref) => ref.watch(forgeCoreProvider)?.auth,
);

/// The signed-in user's account row; null when backup isn't available.
final forgeAccountsProvider = Provider<ForgeAccounts?>(
  (ref) => ref.watch(forgeCoreProvider)?.accounts,
);

/// Whether this build can sign in at all (CHEESE-59). False in CI's
/// define-less builds and in `flutter run` without the dev define file.
final backupAvailableProvider = Provider<bool>(
  (ref) => ref.watch(forgeAuthProvider) != null,
);

/// The session as the app sees it, live. Signed out for good in a build
/// with no backend.
final authStateProvider = StreamProvider<ForgeAuthState>((ref) {
  final auth = ref.watch(forgeAuthProvider);
  return auth?.changes ?? Stream.value(ForgeAuthState.signedOut);
});

/// Convenience: the current session, or null while loading or signed out.
final sessionProvider = Provider<ForgeSession?>(
  (ref) => ref.watch(authStateProvider).asData?.value.session,
);
