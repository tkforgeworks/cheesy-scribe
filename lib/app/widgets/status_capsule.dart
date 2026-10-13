import 'package:flutter/material.dart';

import '../theme/scribe_theme.dart';

/// Pill-shaped status capsule (spec sheet 03): CONNECTED uses the success
/// pair, anything else the neutral fill with tertiary text.
class StatusCapsule extends StatelessWidget {
  const StatusCapsule(this.text, {super.key, this.active = false});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final x = context.scribe;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: active ? x.successBg : context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text.toUpperCase(),
        style: context.text.labelMedium!.copyWith(
          color: active ? x.successFg : x.textTertiary,
        ),
      ),
    );
  }
}
