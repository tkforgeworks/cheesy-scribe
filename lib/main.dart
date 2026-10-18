import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_core/forge_core.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';

import 'app/router.dart';
import 'app/theme/scribe_theme.dart';
import 'data/forge_providers.dart';
import 'data/providers.dart';

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
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider).asData?.value;
    return MaterialApp.router(
      title: 'Cheesy Scribe',
      theme: ScribeTheme.light(),
      darkTheme: ScribeTheme.dark(),
      themeMode: settings?.themeMode ?? ThemeMode.system,
      routerConfig: _router,
    );
  }
}
