import 'package:flutter/material.dart';

import '../theme/scribe_theme.dart';

/// Forge-gradient circle with the white cheese-wedge glyph. 64 px on Login,
/// 24 px in the drawer header, 56 px (on `primaryContainer`, not gradient)
/// in the empty state — for that, use [WedgeGlyph] directly.
class ForgeLogoBadge extends StatelessWidget {
  const ForgeLogoBadge({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: ScribeTokens.forgeGradient,
      ),
      child: Center(
        child: WedgeGlyph(size: size * 0.5, color: Colors.white),
      ),
    );
  }
}

/// The cheese-wedge glyph from the mockups: a wedge outline with three holes,
/// drawn in the Heroicons manner (stroke only, round caps). Geometry is the
/// mockup's 24×24 SVG path, scaled.
class WedgeGlyph extends StatelessWidget {
  const WedgeGlyph({
    super.key,
    this.size = 24,
    this.color,
    this.strokeWidth = 1.8,
  });

  final double size;
  final Color? color;

  /// Stroke width at 24 px; scales with [size].
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _WedgePainter(
        color: color ?? context.colors.onSurface,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _WedgePainter extends CustomPainter {
  const _WedgePainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // M2.8 16.8 v-4.6 L21.2 6 v10.8 H2.8 z
    final wedge = Path()
      ..moveTo(2.8 * k, 16.8 * k)
      ..lineTo(2.8 * k, 12.2 * k)
      ..lineTo(21.2 * k, 6 * k)
      ..lineTo(21.2 * k, 16.8 * k)
      ..close();
    canvas.drawPath(wedge, paint);
    canvas.drawCircle(Offset(8 * k, 13.6 * k), 1.2 * k, paint);
    canvas.drawCircle(Offset(13.5 * k, 12 * k), 1.0 * k, paint);
    canvas.drawCircle(Offset(17.6 * k, 13.8 * k), 0.9 * k, paint);
  }

  @override
  bool shouldRepaint(_WedgePainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
