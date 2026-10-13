import 'package:flutter/material.dart';

import '../../../app/theme/scribe_theme.dart';
import '../../../app/widgets/widgets.dart';
import '../../../data/models/models.dart';

/// List entry mode for the flavor scores: 16 rows of a mono label and five
/// pips. Tap pip N to score N, tap the current score to clear (decision
/// B6: a 0–5 scale, so five pips). Same map as [FlavorWheel].
class FlavorList extends StatelessWidget {
  const FlavorList({super.key, required this.values, this.onChanged});

  final Map<FlavorNote, int> values;
  final ValueChanged<Map<FlavorNote, int>>? onChanged;

  static const pipCount = 5;

  /// Key of the [n]th pip (1-based) of [flavor]; used by tests.
  static Key pipKey(FlavorNote flavor, int n) =>
      ValueKey('pip-${flavor.name}-$n');

  void _set(FlavorNote flavor, int n) {
    final current = values[flavor] ?? 0;
    final next = Map<FlavorNote, int>.from(values);
    if (n == current) {
      next.remove(flavor);
    } else {
      next[flavor] = n;
    }
    onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final x = context.scribe;
    final c = context.colors;
    return Column(
      children: [
        for (final (i, flavor) in FlavorNote.values.indexed) ...[
          if (i > 0)
            CustomPaint(
              size: const Size(double.infinity, 1.5),
              painter: DottedUnderlinePainter(color: x.dottedLine),
            ),
          SizedBox(
            height: 34,
            child: Row(
              children: [
                Expanded(child: MonoLabel(flavor.label)),
                for (var n = 1; n <= pipCount; n++)
                  Semantics(
                    button: onChanged != null,
                    label: '${flavor.label} $n',
                    selected: (values[flavor] ?? 0) >= n,
                    child: InkWell(
                      key: pipKey(flavor, n),
                      onTap: onChanged == null ? null : () => _set(flavor, n),
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 26,
                        height: 34,
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (values[flavor] ?? 0) >= n
                                  ? c.primary
                                  : x.starInactive,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
