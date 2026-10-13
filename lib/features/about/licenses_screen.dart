import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/shell/shell_providers.dart';
import '../../app/theme/scribe_theme.dart';
import '../../app/widgets/widgets.dart';
import '../settings/settings_screen.dart';

/// `/licenses` (CHEESE-41): a short summary of what the app is licensed
/// under and what it is built with, in place of dropping people straight
/// into Flutter's generated list. That list stays one tap away ("View all
/// notices") because the engine and packages compiled into the APK require
/// their notices to ship with it.
class LicensesScreen extends ConsumerWidget {
  const LicensesScreen({super.key});

  static const intro =
      'Cheesy Scribe is open source, and it is built on other people\'s '
      'open-source work. Here is the short version; every notice is one tap '
      'further down.';

  static const assetsLine =
      'The wedge, the app icon and the TK ForgeWorks mark are all rights '
      'reserved.';

  static final sourceUri = Uri.https(
    'github.com',
    '/tkforgeworks/cheesy-scribe',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).asData?.value;
    final c = context.colors;
    final x = context.scribe;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: HeroIcon(
            HeroIcons.arrowLeft,
            size: 24,
            color: c.onSurfaceVariant,
          ),
        ),
        title: const Text('Open-source licenses'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          32,
        ).withNavBarInset(context),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 22),
            child: Text(intro, style: context.text.bodyLarge),
          ),
          SettingsGroup(
            label: 'This app',
            children: [
              const ListTile(
                title: Text('Cheesy Scribe'),
                subtitle: Text('Apache License 2.0'),
              ),
              ListTile(
                key: const Key('licenses-source'),
                title: const Text('Source code'),
                subtitle: const Text('github.com/tkforgeworks/cheesy-scribe'),
                trailing: HeroIcon(
                  HeroIcons.arrowTopRightOnSquare,
                  size: 18,
                  color: x.textTertiary,
                ),
                onTap: () =>
                    launchUrl(sourceUri, mode: LaunchMode.externalApplication),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const SettingsGroup(
            label: 'Built with',
            children: [
              ListTile(
                title: Text('Flutter and Dart packages'),
                subtitle: Text('BSD, MIT, Apache 2.0 and similar licences'),
              ),
              ListTile(
                title: Text('Fonts'),
                subtitle: Text(
                  'Poppins, Source Serif 4 and JetBrains Mono: '
                  'SIL Open Font License 1.1',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SettingsGroup(
            label: 'Full text',
            children: [
              ListTile(
                key: const Key('licenses-all'),
                title: const Text('View all notices'),
                subtitle: const Text('Every licence that ships with the app'),
                trailing: HeroIcon(
                  HeroIcons.chevronRight,
                  size: 18,
                  color: x.textTertiary,
                ),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Cheesy Scribe',
                  applicationVersion: version,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            assetsLine,
            textAlign: TextAlign.center,
            style: ScribeTheme.serif(
              size: 13.5,
              italic: true,
              color: x.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// The bundled fonts' OFL texts (`assets/fonts/licenses/`), which Flutter's
/// generated notices do not include because the fonts are app assets, not
/// packages. Adds them to [LicenseRegistry] once; the texts load lazily
/// when the notices page asks for them.
void registerBundledFontLicenses() {
  if (_fontLicensesRegistered) return;
  _fontLicensesRegistered = true;
  LicenseRegistry.addLicense(() async* {
    for (final (family, file) in bundledFontLicenses) {
      final text = await rootBundle.loadString('assets/fonts/licenses/$file');
      yield LicenseEntryWithLineBreaks([family], text);
    }
  });
}

var _fontLicensesRegistered = false;

/// Font family → licence file under `assets/fonts/licenses/`.
@visibleForTesting
const bundledFontLicenses = [
  ('Poppins', 'Poppins-OFL.txt'),
  ('Source Serif 4', 'SourceSerif4-OFL.md'),
  ('JetBrains Mono', 'JetBrainsMono-OFL.txt'),
];
