import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';

import '../../app/shell/scribe_shell.dart';
import '../../app/theme/scribe_theme.dart';
import '../../app/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../data/providers.dart';

/// `/stats` (DESIGN_SPEC §6, CHEESE-30): two stat tiles, TOP FLAVORS bars
/// and the MILK BREAKDOWN stacked bar, all derived from the notes on the
/// device by [TastingStats.fromNotes]. Under three notes the charts give
/// way to a single italic line.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  static const needMaterial =
      'Come back after a few more cheeses — the charts need material.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(allNotesProvider);
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Open menu',
          onPressed: () => ScribeShell.openDrawer(context),
          icon: HeroIcon(HeroIcons.bars3, size: 24, color: c.onSurfaceVariant),
        ),
        title: const Text('Stats & insights'),
      ),
      body: switch (notes) {
        AsyncData(value: final list) => _StatsBody(
          stats: TastingStats.fromNotes(list),
        ),
        AsyncError() => const Padding(
          padding: EdgeInsets.all(16),
          child: ErrorCard(message: "Couldn't open the journal."),
        ),
        _ => const Padding(padding: EdgeInsets.all(16), child: SkeletonList()),
      },
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody({required this.stats});

  final TastingStats stats;

  @override
  Widget build(BuildContext context) {
    final x = context.scribe;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: StatTile(
                value: '${stats.totalNotes}',
                label: 'Cheeses tasted',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                value: stats.ratedNotes == 0
                    ? '—'
                    : stats.averageRating.toStringAsFixed(1),
                label: 'Average rating',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!stats.hasEnoughForCharts)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                StatsScreen.needMaterial,
                style: ScribeTheme.serif(
                  size: 13.5,
                  italic: true,
                  color: x.textTertiary,
                ),
              ),
            ),
          )
        else ...[
          TopFlavorsCard(stats: stats),
          const SizedBox(height: 12),
          MilkBreakdownCard(stats: stats),
        ],
      ],
    );
  }
}

/// Poppins 34/600 emphasis number over a mono label.
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: ScribeTheme.ui(
              size: 34,
              weight: FontWeight.w600,
              color: context.colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          MonoLabel(label, size: 9.5),
        ],
      ),
    ),
  );
}

/// Up to six bar rows: mono label (82 wide), 8 px track, mono count.
class TopFlavorsCard extends StatelessWidget {
  const TopFlavorsCard({super.key, required this.stats});

  final TastingStats stats;

  static const maxRows = 6;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.scribe;
    final rows = stats.topFlavors.take(maxRows).toList();
    final max = rows.isEmpty ? 1 : rows.first.value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MonoLabel('Top flavors'),
            const SizedBox(height: 12),
            if (rows.isEmpty)
              Text(
                'No flavor has scored a 3 yet. The wheel is waiting.',
                style: ScribeTheme.serif(
                  size: 13,
                  italic: true,
                  color: x.textTertiary,
                ),
              ),
            for (final (i, e) in rows.indexed) ...[
              if (i > 0) const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 82,
                    child: Text(
                      e.key.label,
                      style: ScribeTheme.mono(
                        size: 9.5,
                        weight: FontWeight.w500,
                        color: c.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 8,
                        color: c.surfaceContainer,
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: e.value / max,
                          child: Container(color: c.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 24,
                    child: Text(
                      '${e.value}',
                      textAlign: TextAlign.right,
                      style: ScribeTheme.mono(
                        size: 10,
                        weight: FontWeight.w500,
                        color: x.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 14 px stacked bar (radius 7), mono legend with swatches, verdict line.
class MilkBreakdownCard extends StatelessWidget {
  const MilkBreakdownCard({super.key, required this.stats});

  final TastingStats stats;

  /// Series colours, dominant first (spec sheet; dark equivalents ours).
  static const lightSeries = [
    Color(0xFFB3641B),
    Color(0xFFDFA04B),
    Color(0xFFF0CF95),
    Color(0xFFF2E8D5),
    Color(0xFFE6D9BF),
  ];
  static const darkSeries = [
    Color(0xFFF4B656),
    Color(0xFFC98F3F),
    Color(0xFF8A6A3A),
    Color(0xFF4A4237),
    Color(0xFF3B342B),
  ];

  static String percent(double fraction) => '${(fraction * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final x = context.scribe;
    final series = c.brightness == Brightness.dark ? darkSeries : lightSeries;
    final shares = stats.milkShares;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MonoLabel('Milk breakdown'),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SizedBox(
                height: 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, e) in shares.indexed)
                      Expanded(
                        flex: (e.value * 1000).round().clamp(1, 1000),
                        child: ColoredBox(color: series[i % series.length]),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                for (final (i, e) in shares.indexed)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: series[i % series.length],
                          shape: BoxShape.circle,
                          border: Border.all(color: x.dottedLine, width: 0.5),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${e.key.label.toUpperCase()} ${percent(e.value)}',
                        style: ScribeTheme.mono(
                          size: 9.5,
                          weight: FontWeight.w500,
                          color: c.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              stats.verdictLine,
              style: ScribeTheme.serif(
                size: 12.5,
                italic: true,
                color: x.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
