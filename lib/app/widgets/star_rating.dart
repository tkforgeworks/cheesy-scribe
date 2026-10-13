import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../theme/scribe_theme.dart';

/// Five-star rating. Display at 12–22 px, input at 30 px (spec sheet 03).
/// Whole stars 0–5; 0 means unrated (score hidden, shown as "—").
/// Tap star N to set N; tap the current score again to clear to 0.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.size = 12,
    this.showScore = false,
    this.gap = 2,
  }) : assert(value >= 0 && value <= 5);

  final int value;
  final ValueChanged<int>? onChanged;
  final double size;
  final bool showScore;
  final double gap;

  bool get _interactive => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final x = context.scribe;
    // Input stars need a 44 px tap target (DESIGN_SPEC §3 minimum).
    final pad = _interactive
        ? ((44 - size) / 2).clamp(0, 8).toDouble()
        : gap / 2;
    final stars = List<Widget>.generate(5, (i) {
      final n = i + 1;
      final glyph = HeroIcon(
        HeroIcons.star,
        style: HeroIconStyle.solid,
        size: size,
        color: n <= value ? x.starActive : x.starInactive,
      );
      if (!_interactive) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: glyph,
        );
      }
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged!(n == value ? 0 : n),
        child: Padding(padding: EdgeInsets.all(pad), child: glyph),
      );
    });

    final scoreSize = (size * 0.45).clamp(9.5, 13.0);
    return Semantics(
      label: 'Rating',
      value: value == 0 ? 'unrated' : '$value of 5',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...stars,
          if (showScore) ...[
            SizedBox(width: _interactive ? 4 : 6),
            Text(
              value == 0 ? '—' : value.toDouble().toStringAsFixed(1),
              style: context.text.labelMedium!.copyWith(
                fontSize: scoreSize,
                color: value == 0 ? x.textGhost : x.textTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
