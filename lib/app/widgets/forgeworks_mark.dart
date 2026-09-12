import 'package:flutter/material.dart';

/// The TK ForgeWorks hammer-and-anvil mark (`assets/brand/tkforgeworks-mark.svg`,
/// from the parent design system). It identifies the maker, so it appears
/// exactly once in this app: on About, next to "A TK ForgeWorks product"
/// (DESIGN_SPEC §10).
///
/// Pass [color] to paint both shapes in a single tint, which is what Cheesy
/// Scribe does (its palette has no purple, DESIGN_SPEC §1 rule 2). Without a
/// colour the mark wears its brand gradients: purple anvil, forge hammer.
class ForgeWorksMark extends StatelessWidget {
  const ForgeWorksMark({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  /// Anvil outline, normalised to the SVG's square viewBox (0–1 on both axes).
  static const anvil = <Offset>[
    Offset(0.8031, 0.9215),
    Offset(0.5640, 0.8725),
    Offset(0.2506, 0.9213),
    Offset(0.2506, 0.8804),
    Offset(0.4168, 0.7606),
    Offset(0.3820, 0.6867),
    Offset(0.2586, 0.6256),
    Offset(0.0385, 0.5624),
    Offset(0.0385, 0.5127),
    Offset(0.2564, 0.5127),
    Offset(0.2564, 0.5077),
    Offset(0.9633, 0.5077),
    Offset(0.8419, 0.6170),
    Offset(0.7001, 0.7108),
    Offset(0.6572, 0.7602),
    Offset(0.7670, 0.8299),
    Offset(0.8031, 0.8771),
    Offset(0.8031, 0.9215),
  ];

  /// Hammer outline, same normalisation as [anvil].
  static const hammer = <Offset>[
    Offset(0.1434, 0.4180),
    Offset(0.0938, 0.3952),
    Offset(0.0903, 0.3871),
    Offset(0.1067, 0.3131),
    Offset(0.0938, 0.2770),
    Offset(0.1024, 0.2270),
    Offset(0.1028, 0.2262),
    Offset(0.1370, 0.1728),
    Offset(0.1750, 0.1167),
    Offset(0.1983, 0.0793),
    Offset(0.2449, 0.0822),
    Offset(0.2693, 0.0983),
    Offset(0.2989, 0.1283),
    Offset(0.3116, 0.2274),
    Offset(0.3712, 0.2541),
    Offset(0.4720, 0.2903),
    Offset(0.6157, 0.3182),
    Offset(0.7472, 0.3530),
    Offset(0.8629, 0.3793),
    Offset(0.9427, 0.3995),
    Offset(0.9552, 0.4209),
    Offset(0.9401, 0.4812),
    Offset(0.9197, 0.4990),
    Offset(0.8830, 0.4984),
    Offset(0.8009, 0.4754),
    Offset(0.6404, 0.4289),
    Offset(0.4892, 0.3881),
    Offset(0.3628, 0.3566),
    Offset(0.3032, 0.3546),
    Offset(0.2790, 0.3488),
    Offset(0.2686, 0.3432),
    Offset(0.2478, 0.3759),
    Offset(0.2385, 0.4268),
    Offset(0.2240, 0.4360),
    Offset(0.1435, 0.4180),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MarkPainter(color: color),
    );
  }
}

class _MarkPainter extends CustomPainter {
  const _MarkPainter({required this.color});

  final Color? color;

  // Brand gradients from the SVG: anvil top-to-bottom purple, hammer along
  // the handle in the forge colours.
  static const _anvilGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF9632F3), Color(0xFF8532D6), Color(0xFF601BBC)],
    stops: [0.0, 0.52, 1.0],
  );
  static const _hammerGradient = LinearGradient(
    begin: Alignment(-0.7, -0.8),
    end: Alignment(0.95, 0.5),
    colors: [Color(0xFFFBDF19), Color(0xFFF68F25), Color(0xFFEE3423)],
    stops: [0.0, 0.52, 1.0],
  );

  @override
  void paint(Canvas canvas, Size size) {
    _fill(canvas, size, ForgeWorksMark.anvil, _anvilGradient);
    _fill(canvas, size, ForgeWorksMark.hammer, _hammerGradient);
  }

  void _fill(Canvas canvas, Size size, List<Offset> points, Gradient brand) {
    final path = Path()
      ..addPolygon([
        for (final p in points) Offset(p.dx * size.width, p.dy * size.height),
      ], true);
    final paint = Paint()..isAntiAlias = true;
    if (color != null) {
      paint.color = color!;
    } else {
      paint.shader = brand.createShader(path.getBounds());
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.color != color;
}
