import 'package:flutter/material.dart';

import '../theme/scribe_theme.dart';

/// Loading placeholder for a note row: 42 px circle + two text bars, colour
/// shimmering base → highlight over 1.2 s (DESIGN_SPEC §8). Colour-only
/// motion, per the TKFW rule.
class SkeletonRow extends StatefulWidget {
  const SkeletonRow({super.key});

  @override
  State<SkeletonRow> createState() => _SkeletonRowState();
}

class _SkeletonRowState extends State<SkeletonRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final x = context.scribe;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final color = Color.lerp(
          x.skeletonBase,
          x.skeletonHighlight,
          _controller.value,
        )!;
        Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
        );
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(160, 12),
                    const SizedBox(height: 8),
                    bar(110, 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The spec's loading state: three skeleton rows separated by dividers.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 3});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const Divider(),
          const SkeletonRow(),
        ],
      ],
    );
  }
}
