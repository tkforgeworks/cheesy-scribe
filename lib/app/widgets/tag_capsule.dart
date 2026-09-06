import 'package:flutter/material.dart';

import '../theme/scribe_theme.dart';

enum CapsuleTone { neutral, emphasis }

/// Mono tag capsule: radius 4, JetBrains Mono 9.5 uppercase, padding 4.5×8.5
/// (spec sheet 03). Neutral for info (texture, price); emphasis for milk /
/// RAW / GRASSFED.
class TagCapsule extends StatelessWidget {
  const TagCapsule(this.text, {super.key, this.tone = CapsuleTone.neutral});

  final String text;
  final CapsuleTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final emphasis = tone == CapsuleTone.emphasis;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.5, vertical: 4.5),
      decoration: BoxDecoration(
        color: emphasis ? c.primaryContainer : c.surfaceContainer,
        borderRadius: BorderRadius.circular(ScribeTokens.rChipTag),
      ),
      child: Text(
        text.toUpperCase(),
        style: context.text.labelMedium!.copyWith(
          color: emphasis ? c.onPrimaryContainer : c.onSecondaryContainer,
        ),
      ),
    );
  }
}
