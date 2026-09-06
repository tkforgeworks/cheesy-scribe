import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/theme/scribe_theme.dart';
import 'app/widgets/widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Phone-portrait UI only (CHEESE-1 §3 C); the manifest also pins it.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ScribeApp());
}

/// Root widget. Routing and the drawer shell arrive with CHEESE-19; until then
/// the home is a placeholder that proves the theme and fonts render.
class ScribeApp extends StatelessWidget {
  const ScribeApp({super.key, this.themeMode = ThemeMode.system});

  /// Settings > Appearance > Theme will drive this (CHEESE-31).
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cheesy Scribe',
      theme: ScribeTheme.light(),
      darkTheme: ScribeTheme.dark(),
      themeMode: themeMode,
      home: const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ForgeLogoBadge(size: 64),
            const SizedBox(height: 16),
            Text(
              'Cheesy Scribe',
              style: ScribeTheme.ui(
                size: 30,
                weight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Tasting notes for cheese you'll pretend to remember.",
              textAlign: TextAlign.center,
              style: ScribeTheme.serif(
                size: 13.5,
                italic: true,
                color: context.scribe.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
