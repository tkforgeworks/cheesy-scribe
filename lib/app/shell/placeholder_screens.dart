/// Placeholder bodies for every route until the feature tickets land.
/// Each names the ticket that replaces it; delete the class with the ticket.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/scribe_theme.dart';
import '../widgets/widgets.dart';
import '../../data/providers.dart';
import 'scribe_search_bar.dart';
import 'scribe_shell.dart';
import 'shell_providers.dart';

/// Centered "arrives with CHEESE-N" body shared by the placeholders.
class PlaceholderBody extends StatelessWidget {
  const PlaceholderBody({super.key, required this.title, required this.ticket});

  final String title;
  final String ticket;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: const WedgeGlyph(size: 28),
      title: title,
      aside: 'Arrives with $ticket. The shell got here first.',
    );
  }
}

/// App bar for the two top-level screens without a search bar.
AppBar _menuAppBar(BuildContext context, String title) => AppBar(
  leading: IconButton(
    tooltip: 'Open menu',
    onPressed: () => ScribeShell.openDrawer(context),
    icon: HeroIcon(
      HeroIcons.bars3,
      size: 24,
      color: context.colors.onSurfaceVariant,
    ),
  ),
  title: Text(title),
);

/// App bar for full-screen routes: back arrow (or close X for dialogs).
AppBar _backAppBar(
  BuildContext context,
  String title, {
  bool close = false,
  List<Widget>? actions,
}) => AppBar(
  leading: IconButton(
    tooltip: close ? 'Close' : 'Back',
    onPressed: () => context.pop(),
    icon: HeroIcon(
      close ? HeroIcons.xMark : HeroIcons.arrowLeft,
      size: 24,
      color: context.colors.onSurfaceVariant,
    ),
  ),
  title: Text(title),
  actions: actions,
);

// ---- Shell destinations ----

/// `/library` — CHEESE-29 replaces this with the style grid. Already
/// reads the bundled library for the "N STYLES" count.
class LibraryPlaceholderScreen extends ConsumerWidget {
  const LibraryPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cheeseStylesProvider).asData?.value.length;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ScribeSearchBar(hint: 'Search the library'),
            ),
            if (count != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: MonoLabel('$count styles', emphasis: true),
                ),
              ),
            const Expanded(
              child: PlaceholderBody(
                title: 'Cheese library',
                ticket: 'CHEESE-29',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `/stats` — CHEESE-30.
class StatsPlaceholderScreen extends StatelessWidget {
  const StatsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _menuAppBar(context, 'Stats & insights'),
      body: const PlaceholderBody(
        title: 'Stats & insights',
        ticket: 'CHEESE-30',
      ),
    );
  }
}

/// `/settings` — CHEESE-31.
class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _menuAppBar(context, 'Settings'),
      body: const PlaceholderBody(title: 'Settings', ticket: 'CHEESE-31'),
    );
  }
}

// ---- Full-screen routes (root navigator) ----

/// `/library/:styleId` — CHEESE-29.
class StyleDetailPlaceholderScreen extends StatelessWidget {
  const StyleDetailPlaceholderScreen({super.key, required this.styleId});

  final String styleId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _backAppBar(context, 'Cheese style'),
      body: const PlaceholderBody(title: 'Cheese style', ticket: 'CHEESE-29'),
    );
  }
}

/// `/account` — CHEESE-34 (local profile).
class AccountPlaceholderScreen extends StatelessWidget {
  const AccountPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _backAppBar(context, 'Account'),
      body: const PlaceholderBody(title: 'Account', ticket: 'CHEESE-34'),
    );
  }
}

/// `/about` — CHEESE-33. Already shows the badge, name and version.
class AboutPlaceholderScreen extends ConsumerWidget {
  const AboutPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionProvider).asData?.value;
    return Scaffold(
      appBar: _backAppBar(context, 'About Cheesy Scribe'),
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
            MonoLabel(version == null ? 'Version —' : 'Version $version'),
            const SizedBox(height: 18),
            Text(
              'The rest arrives with CHEESE-33.',
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
