import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/scribe_theme.dart';
import '../../../data/models/models.dart';

/// Layout maths for the wheel, shared by the painter, hit-testing and the
/// tests. Mirrors the spec sheet's SVG (viewBox 392×336, R 92, centre at
/// (196, 166)) scaled to [width].
class FlavorWheelGeometry {
  FlavorWheelGeometry(this.width)
    : height = width * 336 / 392,
      radius = width * 92 / 392,
      center = Offset(width / 2, width * 166 / 392),
      scale = width / 392;

  final double width;
  final double height;
  final double radius;
  final Offset center;

  /// Multiplier from spec-sheet units to pixels.
  final double scale;

  static const spokes = 16;
  static const rings = 5;

  /// Angle of [spoke]: 12 o'clock is spoke 0, then clockwise.
  static double angleOf(int spoke) =>
      -math.pi / 2 + spoke * 2 * math.pi / spokes;

  /// Position of [spoke] at [ring] (0 = centre, 5 = rim; fractional ok).
  Offset pointFor(int spoke, double ring) {
    final a = angleOf(spoke);
    final r = radius * ring / rings;
    return center + Offset(math.cos(a) * r, math.sin(a) * r);
  }

  /// Nearest (spoke, ring) to [p], or null when the tap is outside the
  /// wheel's tappable area. Ring 0 is the centre.
  (FlavorNote, int)? hitTest(Offset p) {
    final d = p - center;
    final dist = d.distance;
    if (dist > radius * 1.3) return null;
    var angle = math.atan2(d.dy, d.dx) + math.pi / 2;
    final full = 2 * math.pi;
    angle = ((angle % full) + full) % full;
    final spoke = (angle / (full / spokes)).round() % spokes;
    final ring = (dist / (radius / rings)).round().clamp(0, rings);
    return (FlavorNote.values[spoke], ring);
  }
}

/// The 16-spoke, 5-ring flavor wheel (DESIGN_SPEC §5, spec sheet 04). Tap a
/// spoke at a ring to score it; tap its current ring to clear. Read-only
/// when [onChanged] is null (note detail). The polygon animates 250 ms.
class FlavorWheel extends StatefulWidget {
  const FlavorWheel({super.key, required this.values, this.onChanged});

  /// Scores 1–5 per spoke; a missing spoke is 0.
  final Map<FlavorNote, int> values;

  /// Receives the full updated map; null makes the wheel read-only.
  final ValueChanged<Map<FlavorNote, int>>? onChanged;

  bool get readOnly => onChanged == null;

  @override
  State<FlavorWheel> createState() => _FlavorWheelState();
}

class _FlavorWheelState extends State<FlavorWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    value: 1,
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  late List<double> _from = _toList(widget.values);
  late List<double> _to = _from;

  static List<double> _toList(Map<FlavorNote, int> values) => [
    for (final f in FlavorNote.values) (values[f] ?? 0).toDouble(),
  ];

  List<double> get _current => [
    for (var i = 0; i < FlavorWheelGeometry.spokes; i++)
      _from[i] + (_to[i] - _from[i]) * _curve.value,
  ];

  @override
  void didUpdateWidget(FlavorWheel old) {
    super.didUpdateWidget(old);
    final next = _toList(widget.values);
    if (next.toString() != _to.toString()) {
      _from = _current;
      _to = next;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _tap(Offset local, FlavorWheelGeometry g) {
    final hit = g.hitTest(local);
    if (hit == null) return;
    final (flavor, ring) = hit;
    final current = widget.values[flavor] ?? 0;
    final next = Map<FlavorNote, int>.from(widget.values);
    if (ring == 0 || ring == current) {
      next.remove(flavor);
    } else {
      next[flavor] = ring;
    }
    widget.onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final labelStyle = ScribeTheme.mono(
      size: 8,
      weight: FontWeight.w500,
      letterSpacing: 0.3,
      color: c.onSecondaryContainer,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : 300.0;
        final g = FlavorWheelGeometry(width);
        return Semantics(
          label: 'Flavor wheel',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: widget.readOnly ? null : (d) => _tap(d.localPosition, g),
            child: AnimatedBuilder(
              animation: _curve,
              builder: (context, _) => CustomPaint(
                size: Size(g.width, g.height),
                painter: _WheelPainter(
                  geometry: g,
                  values: _current,
                  grid: context.scribe.wheelGrid,
                  accent: c.primary,
                  labelStyle: labelStyle,
                  textDirection: Directionality.of(context),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({
    required this.geometry,
    required this.values,
    required this.grid,
    required this.accent,
    required this.labelStyle,
    required this.textDirection,
  });

  final FlavorWheelGeometry geometry;
  final List<double> values;
  final Color grid;
  final Color accent;
  final TextStyle labelStyle;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final g = geometry;
    const n = FlavorWheelGeometry.spokes;
    final gridPaint = Paint()
      ..color = grid
      ..style = PaintingStyle.stroke;

    // Rings (outer one heavier) and spokes.
    for (var ring = 1; ring <= FlavorWheelGeometry.rings; ring++) {
      gridPaint.strokeWidth = ring == FlavorWheelGeometry.rings ? 1.2 : 0.6;
      canvas.drawPath(_polygon(List.filled(n, ring.toDouble())), gridPaint);
    }
    gridPaint.strokeWidth = 0.6;
    for (var i = 0; i < n; i++) {
      canvas.drawLine(g.center, g.pointFor(i, 5), gridPaint);
    }

    // Value polygon + dots, only once something is scored.
    if (values.any((v) => v > 0)) {
      final shape = _polygon(values);
      canvas.drawPath(shape, Paint()..color = accent.withValues(alpha: 0.18));
      canvas.drawPath(
        shape,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeJoin = StrokeJoin.round,
      );
      final dot = Paint()..color = accent;
      for (var i = 0; i < n; i++) {
        if (values[i] > 0) {
          canvas.drawCircle(g.pointFor(i, values[i]), 2.6, dot);
        }
      }
    }

    // Labels just outside the rim, anchored by which side they sit on.
    for (var i = 0; i < n; i++) {
      final p =
          g.center +
          Offset.fromDirection(
            FlavorWheelGeometry.angleOf(i),
            g.radius + 12 * g.scale,
          );
      final cos = math.cos(FlavorWheelGeometry.angleOf(i));
      final align = cos > 0.25
          ? TextAlign.left
          : cos < -0.25
          ? TextAlign.right
          : TextAlign.center;
      final lines = FlavorNote.values[i].label.split('/');
      var y = p.dy - 4.5;
      for (final line in lines) {
        final tp = TextPainter(
          text: TextSpan(text: line, style: labelStyle),
          textDirection: textDirection,
        )..layout();
        final x = switch (align) {
          TextAlign.left => p.dx,
          TextAlign.right => p.dx - tp.width,
          _ => p.dx - tp.width / 2,
        };
        tp.paint(canvas, Offset(x, y));
        y += 9;
      }
    }
  }

  Path _polygon(List<double> rings) {
    final path = Path();
    for (var i = 0; i < rings.length; i++) {
      final p = geometry.pointFor(i, rings[i]);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.values.toString() != values.toString() ||
      old.grid != grid ||
      old.accent != accent ||
      old.geometry.width != geometry.width ||
      old.labelStyle != labelStyle;
}
