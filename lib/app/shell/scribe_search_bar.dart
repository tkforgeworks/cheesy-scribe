import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/scribe_theme.dart';
import '../widgets/widgets.dart';
import 'scribe_shell.dart';
import 'shell_providers.dart';

/// The pinned search bar on Notes and Library (DESIGN_SPEC §5): h52, radius
/// 28, `surfaceContainer` fill, leading menu icon opens the shell drawer,
/// trailing 32 px avatar with the local display name's initial.
class ScribeSearchBar extends ConsumerWidget {
  const ScribeSearchBar({
    super.key,
    required this.hint,
    this.onTap,
    this.controller,
    this.onChanged,
  });

  final String hint;

  /// Tapping the bar itself (Home opens its full-screen search view).
  final VoidCallback? onTap;

  /// For inline filtering (Library): type straight into the bar.
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final name = ref.watch(displayNameProvider)?.trim();
    final initial = (name != null && name.isNotEmpty)
        ? name.characters.first.toUpperCase()
        : null;

    return SearchBar(
      hintText: hint,
      hintStyle: WidgetStatePropertyAll(
        ScribeTheme.ui(size: 14, color: context.scribe.textTertiary),
      ),
      onTap: onTap,
      controller: controller,
      onChanged: onChanged,
      leading: IconButton(
        tooltip: 'Open menu',
        onPressed: () => ScribeShell.openDrawer(context),
        icon: HeroIcon(HeroIcons.bars3, size: 24, color: c.onSurfaceVariant),
      ),
      trailing: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Material(
            color: c.primaryContainer,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => context.push('/account'),
              child: SizedBox(
                width: 32,
                height: 32,
                child: Center(
                  child: initial != null
                      ? Text(
                          initial,
                          style: ScribeTheme.ui(
                            size: 13,
                            weight: FontWeight.w600,
                            color: c.onPrimaryContainer,
                          ),
                        )
                      : WedgeGlyph(size: 18, color: c.onPrimaryContainer),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
