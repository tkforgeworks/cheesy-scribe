import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/shell/scribe_shell.dart';
import '../../app/shell/shell_providers.dart';
import '../../app/widgets/widgets.dart';
import '../../data/forge_providers.dart';

/// `/about` (DESIGN_SPEC §6 About, CHEESE-33): forge_ui's shared about
/// screen with this app's badge, blurb, links and privacy line. The
/// TK ForgeWorks mark is tinted, since this app has no purple.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static const blurb =
      "I keep your cheese notes so you don't have to pretend to remember "
      'them. Name, maker, where it came from, what it did on the tongue and '
      'how many stars you would defend in an argument: written down once, '
      'kept on this phone, ready when the next wedge turns up. Sign in if '
      'you want a backup for the next phone; skip it and nothing changes. '
      'No opinions about your palate either way. Those are yours.';

  static const privacyLine =
      'Your notes stay on this device unless you sign in to back them up.';
  static final siteUri = Uri.https('tkforgeworks.com');

  /// The website's deletion form (TKFW-83), for someone who cannot sign in
  /// any more; a signed-in user is sent to Account instead (CHEESE-65).
  static final deleteAccountUri = Uri.https(
    'tkforgeworks.com',
    '/privacy/cheesy-scribe/delete-account/',
  );

  /// Same URL as the Play Console privacy policy field (CHEESE-35). The page
  /// lives in the TKForgeWorks_website repo, `content/privacy/`.
  static final privacyUri = Uri.https(
    'tkforgeworks.com',
    '/privacy/cheesy-scribe/',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).asData?.value;
    final backup = ref.watch(backupAvailableProvider);
    final signedIn = ref.watch(sessionProvider) != null;
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
      // Play wants a way to delete the account from where the user already
      // is: Account when signed in, the website form otherwise. Hidden in a
      // build with no backend, where no account can exist.
      onOpenDeleteAccount: !backup
          ? null
          : signedIn
          ? () => context.go('/account')
          : () => launchUrl(
              deleteAccountUri,
              mode: LaunchMode.externalApplication,
            ),
      footnote: privacyLine,
      tintMark: true,
    );
  }
}
