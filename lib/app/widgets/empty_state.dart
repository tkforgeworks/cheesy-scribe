import 'package:flutter/material.dart';

import '../theme/scribe_theme.dart';

/// Centred empty state: 56 px icon circle on `primaryContainer`, an 18/600
/// title, a serif-italic aside, and an optional action (DESIGN_SPEC §8).
/// Voice rule: one plain statement + one dry aside. Never "Oops!".
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.aside,
    this.action,
  });

  /// Rendered at ~28 px inside the circle; pass a `WedgeGlyph` or `HeroIcon`.
  final Widget icon;
  final String title;
  final String aside;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: c.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconTheme(
                  data: IconThemeData(color: c.onPrimaryContainer, size: 28),
                  child: icon,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: ScribeTheme.ui(
                size: 18,
                weight: FontWeight.w600,
                color: c.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              aside,
              textAlign: TextAlign.center,
              style: ScribeTheme.serif(
                size: 13.5,
                italic: true,
                color: context.scribe.textTertiary,
              ),
            ),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}
