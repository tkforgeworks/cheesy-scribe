import 'package:flutter/material.dart';

import '../theme/scribe_theme.dart';

/// Journal field label: JetBrains Mono 10/500, uppercase, tracking 1.4,
/// tertiary colour (DESIGN_SPEC §3). Uppercases its content itself.
class MonoLabel extends StatelessWidget {
  const MonoLabel(
    this.text, {
    super.key,
    this.color,
    this.size,
    this.emphasis = false,
    this.textAlign,
  });

  final String text;
  final Color? color;
  final double? size;

  /// Emphasis = `onPrimaryContainer` colour (the "12 TASTED" treatment).
  final bool emphasis;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final base = context.text.labelSmall!;
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: base.copyWith(
        color: color ?? (emphasis ? context.colors.onPrimaryContainer : null),
        fontSize: size,
        fontWeight: emphasis ? FontWeight.w600 : null,
      ),
    );
  }
}
