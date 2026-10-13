import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/shell/shell_providers.dart';

/// `/licenses` (CHEESE-41): forge_ui's licences summary with this app's
/// licence, source link and asset line. Flutter's generated list stays one
/// tap away ("View all notices") because the engine and packages compiled
/// into the APK require their notices to ship with it.
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
    return ForgeLicensesScreen(
      appName: 'Cheesy Scribe',
      licenseName: 'Apache License 2.0',
      version: version,
      intro: intro,
      sourceLabel: 'github.com/tkforgeworks/cheesy-scribe',
      onOpenSource: () =>
          launchUrl(sourceUri, mode: LaunchMode.externalApplication),
      footnote: assetsLine,
    );
  }
}
