import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/shell/shell_providers.dart';
import '../../app/theme/scribe_theme.dart';
import '../../app/widgets/widgets.dart';

/// `/about` (DESIGN_SPEC §6 About, CHEESE-33): badge, name, version, one
/// paragraph in the TKFW voice, the maker line, links and the privacy
/// line. The hammer/anvil mark arrives with the brand assets (CHEESE-18).
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static const blurb =
      "I keep your cheese notes so you don't have to pretend to remember "
      'them. Name, maker, where it came from, what it did on the tongue and '
      'how many stars you would defend in an argument: written down once, '
      'kept on this phone, ready when the next wedge turns up. No account, '
      'no cloud, and no opinions about your palate. Those are yours.';

  static const privacyLine = 'Your notes stay on this device.';
  static final siteUri = Uri.https('tkforgeworks.com');

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
        title: const Text('About Cheesy Scribe'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
        children: [
          const Center(child: ForgeLogoBadge(size: 64)),
          const SizedBox(height: 16),
          Text(
            'Cheesy Scribe',
            textAlign: TextAlign.center,
            style: ScribeTheme.ui(
              size: 30,
              weight: FontWeight.w700,
              color: c.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          MonoLabel(
            version == null ? 'Version —' : 'Version $version',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          Text(blurb, style: context.text.bodyLarge),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // The TKFW hammer/anvil mark goes here (CHEESE-18).
              const WedgeGlyph(size: 16),
              const SizedBox(width: 8),
              MonoLabel(
                'A TK ForgeWorks product',
                size: 9.5,
                color: x.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  key: const Key('about-site'),
                  title: const Text('tkforgeworks.com'),
                  trailing: HeroIcon(
                    HeroIcons.arrowTopRightOnSquare,
                    size: 18,
                    color: x.textTertiary,
                  ),
                  onTap: () =>
                      launchUrl(siteUri, mode: LaunchMode.externalApplication),
                ),
                Divider(height: 1, color: x.rowDivider),
                ListTile(
                  key: const Key('about-licenses'),
                  title: const Text('Open-source licenses'),
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
          ),
          const SizedBox(height: 22),
          Text(
            privacyLine,
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
