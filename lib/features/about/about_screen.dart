import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/shell/scribe_shell.dart';
import '../../app/shell/shell_providers.dart';
import '../../app/widgets/widgets.dart';

/// `/about` (DESIGN_SPEC §6 About, CHEESE-33): forge_ui's shared about
/// screen with this app's badge, blurb, links and privacy line. The
/// TK ForgeWorks mark is tinted, since this app has no purple.
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

  /// Same URL as the Play Console privacy policy field (CHEESE-35). The page
  /// lives in the TKForgeWorks_website repo, `content/privacy/`.
  static final privacyUri = Uri.https(
    'tkforgeworks.com',
    '/privacy/cheesy-scribe/',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).asData?.value;
    return ForgeAboutScreen(
      appName: 'Cheesy Scribe',
      // A drawer destination, so the menu icon and not a back arrow.
      leading: IconButton(
        tooltip: 'Open menu',
        onPressed: () => ScribeShell.openDrawer(context),
        icon: HeroIcon(
          HeroIcons.bars3,
          size: 24,
          color: context.colors.onSurfaceVariant,
        ),
      ),
      badge: const ForgeLogoBadge(size: 64),
      version: version,
      blurb: blurb,
      onSendFeedback: () => context.push('/feedback'),
      onOpenWebsite: () =>
          launchUrl(siteUri, mode: LaunchMode.externalApplication),
      onOpenPrivacyPolicy: () =>
          launchUrl(privacyUri, mode: LaunchMode.externalApplication),
      onOpenLicenses: () => context.push('/licenses'),
      footnote: privacyLine,
      tintMark: true,
    );
  }
}
