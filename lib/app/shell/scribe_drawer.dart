import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/scribe_theme.dart';
import '../widgets/widgets.dart';
import 'shell_providers.dart';

/// Navigation drawer per DESIGN_SPEC §5/§7: 300 wide, right radius 16,
/// logo + wordmark header, divider-bounded account row, radius-28 pill
/// items, divider, spacer, pinned mono fine print with the app version.
///
/// Sign out is absent on purpose: v0.1.0 is local-first with no account
/// (CHEESE-11 brings it back with auth).
class ScribeDrawer extends ConsumerWidget {
  const ScribeDrawer({super.key, required this.selectedPath});

  /// Current location path; the pill whose route prefixes it is selected.
  final String selectedPath;

  static const _primary = [
    DrawerDestination(
      label: 'My tasting notes',
      icon: HeroIcons.documentText,
      path: '/notes',
    ),
    DrawerDestination(
      label: 'New tasting note',
      icon: HeroIcons.plus,
      path: '/notes/new',
      pushes: true,
    ),
    DrawerDestination(
      label: 'Cheese library',
      icon: HeroIcons.bookOpen,
      path: '/library',
    ),
    DrawerDestination(
      label: 'Stats & insights',
      icon: HeroIcons.chartBar,
      path: '/stats',
    ),
  ];

  static const _secondary = [
    DrawerDestination(
      label: 'Account',
      icon: HeroIcons.user,
      path: '/account',
      pushes: true,
    ),
    DrawerDestination(
      label: 'Settings',
      icon: HeroIcons.cog6Tooth,
      path: '/settings',
    ),
    DrawerDestination(
      label: 'About Cheesy Scribe',
      icon: HeroIcons.informationCircle,
      path: '/about',
      pushes: true,
    ),
  ];

  bool _isSelected(DrawerDestination d) =>
      !d.pushes &&
      (selectedPath == d.path || selectedPath.startsWith('${d.path}/'));

  void _open(BuildContext context, DrawerDestination d) {
    Scaffold.of(context).closeDrawer();
    if (d.pushes) {
      context.push(d.path);
    } else {
      context.go(d.path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = ref.watch(displayNameProvider);
    final version = ref.watch(appVersionProvider).asData?.value;
    final x = context.scribe;

    return Drawer(
      child: SafeArea(
        // Pinned footer on tall screens; scrolls as one piece on short ones.
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                      child: Row(
                        children: [
                          const ForgeLogoBadge(size: 34),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cheesy Scribe',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: ScribeTheme.ui(
                                size: 18,
                                weight: FontWeight.w700,
                                color: context.colors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _AccountRow(
                      displayName: displayName,
                      onTap: () => _open(context, _secondary.first),
                    ),
                    const SizedBox(height: 8),
                    for (final d in _primary)
                      DrawerPill(
                        destination: d,
                        selected: _isSelected(d),
                        onTap: () => _open(context, d),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                      child: Divider(height: 1, color: x.rowDivider),
                    ),
                    for (final d in _secondary)
                      DrawerPill(
                        destination: d,
                        selected: _isSelected(d),
                        onTap: () => _open(context, d),
                      ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                      child: Text(
                        version == null
                            ? 'A TK FORGEWORKS PRODUCT'
                            : 'A TK FORGEWORKS PRODUCT · V$version',
                        style: ScribeTheme.mono(
                          size: 8.5,
                          weight: FontWeight.w500,
                          letterSpacing: 1.2,
                          color: x.textGhost,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One drawer entry. [pushes] routes open over the shell (form, account,
/// about) and are never shown selected; the rest are shell destinations.
@immutable
class DrawerDestination {
  const DrawerDestination({
    required this.label,
    required this.icon,
    required this.path,
    this.pushes = false,
  });

  final String label;
  final HeroIcons icon;
  final String path;
  final bool pushes;
}

/// Radius-28 pill: `primaryContainer` fill + `onPrimaryContainer` text and
/// icon when selected; secondary text + tertiary icon otherwise.
class DrawerPill extends StatelessWidget {
  const DrawerPill({
    super.key,
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final DrawerDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = selected ? c.onPrimaryContainer : c.onSurfaceVariant;
    final iconColor = selected
        ? c.onPrimaryContainer
        : context.scribe.textTertiary;
    final radius = BorderRadius.circular(ScribeTokens.rSearch);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.ease,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? c.primaryContainer : Colors.transparent,
              borderRadius: radius,
            ),
            child: Row(
              children: [
                HeroIcon(destination.icon, size: 22, color: iconColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    destination.label,
                    style: ScribeTheme.ui(
                      size: 14,
                      weight: FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.displayName, required this.onTap});

  final String? displayName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.scribe;
    final name = displayName?.trim();
    final hasName = name != null && name.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: x.rowDivider),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: c.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: hasName
                      ? Text(
                          name.characters.first.toUpperCase(),
                          style: ScribeTheme.ui(
                            size: 15,
                            weight: FontWeight.w600,
                            color: c.onPrimaryContainer,
                          ),
                        )
                      : WedgeGlyph(size: 22, color: c.onPrimaryContainer),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasName ? name : 'Your notebook',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ScribeTheme.ui(
                        size: 14,
                        weight: FontWeight.w600,
                        color: c.onSurface,
                      ),
                    ),
                    Text(
                      hasName
                          ? 'Notes stay on this phone'
                          : 'Add a name under Account',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
