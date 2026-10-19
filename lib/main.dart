import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';

import 'app/router.dart';
import 'app/session_guard.dart';
import 'app/theme/scribe_theme.dart';
import 'data/forge_providers.dart';
import 'data/providers.dart';
import 'data/sync/sync_providers.dart';
import 'features/account/auth_copy.dart';
import 'features/account/check_email_screen.dart';
import 'features/account/set_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Phone-portrait UI only (CHEESE-1 §3 C); the manifest also pins it.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  registerForgeFontLicenses();
  // The backend, when this build has one (CHEESE-59). Initialising opens no
  // connection: the first request happens when the user signs in (or at
  // start-up to refresh a session they created earlier).
  final core = scribeSupabaseConfig.isConfigured
      ? await ForgeCore.initialize(scribeSupabaseConfig)
      : null;
  runApp(
    ProviderScope(
      overrides: [forgeCoreProvider.overrideWithValue(core)],
      child: const ScribeApp(),
    ),
  );
}

/// Root widget: themes + router. Needs a [ProviderScope] above it; the
/// theme mode follows `AppSettings.themeMode` (Settings > Appearance,
/// CHEESE-31).
class ScribeApp extends ConsumerStatefulWidget {
  const ScribeApp({super.key, this.initialLocation = '/notes'});

  /// Where the router starts; tests use it to open deep routes directly.
  final String initialLocation;

  @override
  ConsumerState<ScribeApp> createState() => _ScribeAppState();
}

class _ScribeAppState extends ConsumerState<ScribeApp> {
  late final GoRouter _router = createScribeRouter(
    initialLocation: widget.initialLocation,
    onMailLink: (link) => _pendingLink = link,
  );

  /// The mail link that just opened the app, until the auth state it
  /// produces arrives (CHEESE-68): what [_onAuthState] greets.
  ForgeMailLink? _pendingLink;
  final _messenger = GlobalKey<ScaffoldMessengerState>();
  late final _guard = SessionGuard(ref, _messenger);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  /// Mail links (CHEESE-61/68): forge_core verifies the token the link
  /// carries and the result arrives here. A reset link gives
  /// `passwordRecovery`: show the set-password screen, in place of the
  /// check-email screen when that is what is showing. A confirmation link
  /// gives `signedIn`. Either way the user would otherwise just find
  /// themselves in the app, so the link that [_router] saw arrive is
  /// greeted with a line at the bottom; a link that could not be verified
  /// (expired, already used) gets the error copy in the same place.
  void _onAuthState(
    AsyncValue<ForgeAuthState>? _,
    AsyncValue<ForgeAuthState> next,
  ) {
    final state = next.asData?.value;
    if (state == null) return;
    final link = _pendingLink;
    if (state.isMailLinkFailed) {
      _pendingLink = null;
      _notify(authErrorCopy(state.error ?? ForgeAuthError.linkExpired));
      return;
    }
    if (state.isPasswordRecovery) {
      _pendingLink = null;
      if (link?.isPasswordReset == true) _notify(resetLinkVerifiedMessage);
      final here = _router.state.uri.path;
      if (here == SetPasswordScreen.path) return;
      if (here == CheckEmailScreen.path) {
        _router.pushReplacement(SetPasswordScreen.path);
      } else {
        _router.push(SetPasswordScreen.path);
      }
      return;
    }
    if (state.event == ForgeAuthEvent.signedIn) {
      _pendingLink = null;
      if (link != null && !link.isPasswordReset) _notify(emailConfirmedMessage);
    }
  }

  void _notify(String message) {
    _messenger.currentState
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, _onAuthState);
    // Keeps the sync engine alive for the app's lifetime while signed in
    // (CHEESE-62); null when signed out or without a backend.
    ref.watch(syncCoordinatorProvider);
    _guard.watch();
    final settings = ref.watch(appSettingsProvider).asData?.value;
    return MaterialApp.router(
      scaffoldMessengerKey: _messenger,
      title: 'Cheesy Scribe',
      theme: ScribeTheme.light(),
      darkTheme: ScribeTheme.dark(),
      themeMode: settings?.themeMode ?? ThemeMode.system,
      routerConfig: _router,
    );
  }
}
