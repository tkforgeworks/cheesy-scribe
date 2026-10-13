import 'package:flutter/material.dart';

import '../../../app/theme/scribe_theme.dart';
import '../../../app/widgets/widgets.dart';
import '../../../data/models/models.dart';

/// Six-stop texture meter (DESIGN_SPEC §5): 4 px track, 18 px thumb,
/// mono labels with the active one emphasised. Editable with [onChanged];
/// read-only (a painted track, no slider chrome) without it.
class TextureMeter extends StatelessWidget {
  const TextureMeter({super.key, required this.value, this.onChanged});

  final TextureLevel value;
  final ValueChanged<TextureLevel>? onChanged;

  @override
  Widget build(BuildContext context) {
    final steps = TextureLevel.values.length - 1;
    return Column(
      children: [
        if (onChanged != null)
          Slider(
            value: value.index.toDouble(),
            min: 0,
            max: steps.toDouble(),
            divisions: steps,
            label: value.label,
            onChanged: (v) => onChanged!(TextureLevel.values[v.round()]),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 12),
            child: _StaticTrack(fraction: value.index / steps),
          ),
        Row(
          children: [
            for (final t in TextureLevel.values)
              Expanded(
                child: MonoLabel(
                  t.label,
                  size: 8.5,
                  emphasis: t == value,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StaticTrack extends StatelessWidget {
  const _StaticTrack({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 18,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final x = constraints.maxWidth * fraction;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 7,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.surfaceContainer,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                width: x,
                top: 7,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: c.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                left: x - 9,
                top: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: c.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: c.surfaceContainerLowest,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
