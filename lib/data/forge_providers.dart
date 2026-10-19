import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_core/forge_core.dart';

/// Where confirmation and password-reset mails send the user back to
/// (CHEESE-68): an HTTPS Android App Link on tkforgeworks.com. The website
/// vouches for this app's signing certificates in
/// `/.well-known/assetlinks.json`, so Android hands the link straight to the
/// app with nothing left behind in the mail client, and anyone without the
/// app sees a page that explains and links to the store. App code rather
/// than configuration: the manifest's `autoVerify` intent filter and the
/// Supabase project's redirect allow list both name it, and the trailing
/// slash matters to the allow list (GoTrue matches it as sent).
const scribeAuthRedirectUrl =
    'https://tkforgeworks.com/apps/cheesy-scribe/auth/';

/// The custom scheme the mails redirected to from rc.2 to rc.8 (CHEESE-61):
/// the application id *without its underscore*, since a URL scheme may only
/// contain letters, digits, `+`, `-` and `.`, and GoTrue silently falls back
/// to the Site URL for a redirect it cannot parse. Still opens the app one
/// more RC so a mail sent before the switch keeps working; the manifest
/// filter and this constant go together.
const legacyAuthCallbackUrl = 'com.tkforgeworks.cheesyscribe://auth-callback';

/// Whether [uri] is a mail link opening the app: the App Link (host and
/// path prefix, so GoTrue's `?code=` or `#error=` may follow) or the legacy
/// scheme. The router sends both to Account; supabase_flutter reads the
/// code from the same link on its own.
bool isAuthCallback(Uri uri) {
  final current = Uri.parse(scribeAuthRedirectUrl);
  // go_router drops the trailing slash from a location, so the path is
  // matched as the manifest's pathPrefix: with or without it.
  final prefix = current.path.endsWith('/')
      ? current.path.substring(0, current.path.length - 1)
      : current.path;
  if (uri.scheme == current.scheme &&
      uri.host == current.host &&
      (uri.path == prefix || uri.path.startsWith('$prefix/'))) {
    return true;
  }
  final legacy = Uri.parse(legacyAuthCallbackUrl);
  return uri.scheme == legacy.scheme && uri.host == legacy.host;
}

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

/// Convenience: the current session, or null when signed out. While the
/// stream is still loading it answers from `ForgeAuth.current`, which is
/// synchronous, so a signed-in app never flashes the signed-out notebook
/// at start.
final sessionProvider = Provider<ForgeSession?>((ref) {
  final state = ref.watch(authStateProvider);
  if (state case AsyncData(:final value)) return value.session;
  return ref.watch(forgeAuthProvider)?.current.session;
});

/// Whose notes the notebook shows (CHEESE-62): the signed-in account's id,
/// or null for the notes made while signed out.
final currentOwnerProvider = Provider<String?>(
  (ref) => ref.watch(sessionProvider)?.userId,
);

/// The signed-in user's `accounts` row (username, created date), live
/// across sign-ins; null when signed out or without a backend. A write
/// (`setUsername`) invalidates it so the row is re-read (CHEESE-64).
final accountProvider = StreamProvider<ForgeAccount?>((ref) {
  final accounts = ref.watch(forgeAccountsProvider);
  if (accounts == null) return Stream.value(null);
  return accounts.watchAccount().map(
    (result) => switch (result) {
      ForgeOk(:final value) => value,
      ForgeFailed() => null,
    },
  );
});
