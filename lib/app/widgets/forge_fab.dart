import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/scribe_theme.dart';

/// The one gradient button in the app: extended FAB wrapped in the forge
/// gradient, radius 16, shadow 0 6 18 rgba(238,52,35,.35) (spec sheet 03).
/// The FAB itself is transparent / elevation 0 (see the theme).
class ForgeFab extends StatelessWidget {
  const ForgeFab({
    super.key,
    required this.onPressed,
    this.label = 'New tasting notes',
    this.icon = HeroIcons.plus,
    this.heroTag,
  });

  final VoidCallback? onPressed;
  final String label;
  final HeroIcons icon;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: ScribeTokens.forgeGradient,
        borderRadius: BorderRadius.circular(ScribeTokens.rFab),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59EE3423),
            offset: Offset(0, 6),
            blurRadius: 18,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: heroTag,
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        icon: HeroIcon(icon, color: Colors.white, size: 20),
        label: Text(label),
      ),
    );
  }
}
