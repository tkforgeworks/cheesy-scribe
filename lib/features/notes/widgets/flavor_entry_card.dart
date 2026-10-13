import 'package:flutter/material.dart';

import '../../../app/theme/scribe_theme.dart';
import '../../../app/widgets/widgets.dart';
import '../../../data/models/models.dart';
import 'flavor_list.dart';
import 'flavor_wheel.dart';

enum FlavorEntryMode { wheel, list }

/// The FLAVOR WHEEL card: mono title, Wheel/List toggle, helper line and
/// the chosen entry widget. Both modes edit the same map, so switching
/// keeps every score. With [onChanged] null it is the detail screen's
/// read-only wheel card (no toggle, no helper).
class FlavorEntryCard extends StatefulWidget {
  const FlavorEntryCard({
    super.key,
    required this.values,
    this.onChanged,
    this.initialMode = FlavorEntryMode.wheel,
  });

  final Map<FlavorNote, int> values;
  final ValueChanged<Map<FlavorNote, int>>? onChanged;
  final FlavorEntryMode initialMode;

  @override
  State<FlavorEntryCard> createState() => _FlavorEntryCardState();
}

class _FlavorEntryCardState extends State<FlavorEntryCard> {
  late FlavorEntryMode _mode = widget.initialMode;

  static const _helper = {
    FlavorEntryMode.wheel:
        'Tap a spoke to score 0–5 — or switch to List to enter them one by one',
    FlavorEntryMode.list: 'Tap the pips to score each note 0–5',
  };

  @override
  Widget build(BuildContext context) {
    final editable = widget.onChanged != null;
    final mode = editable ? _mode : FlavorEntryMode.wheel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: MonoLabel('Flavor wheel')),
                if (editable)
                  SegmentedButton<FlavorEntryMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: FlavorEntryMode.wheel,
                        label: Text('Wheel'),
                      ),
                      ButtonSegment(
                        value: FlavorEntryMode.list,
                        label: Text('List'),
                      ),
                    ],
                    selected: {mode},
                    onSelectionChanged: (s) => setState(() => _mode = s.first),
                  ),
              ],
            ),
            if (editable) ...[
              const SizedBox(height: 6),
              Text(_helper[mode]!, style: context.text.bodySmall),
            ],
            const SizedBox(height: 12),
            switch (mode) {
              FlavorEntryMode.wheel => FlavorWheel(
                values: widget.values,
                onChanged: widget.onChanged,
              ),
              FlavorEntryMode.list => FlavorList(
                values: widget.values,
                onChanged: widget.onChanged,
              ),
            },
          ],
        ),
      ),
    );
  }
}
