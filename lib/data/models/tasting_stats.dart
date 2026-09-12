import 'package:flutter/foundation.dart';

import 'enums.dart';
import 'tasting_note.dart';

/// Derived, never stored — computed from the notes list for Stats & insights.
/// Unrated notes (rating 0) count toward [totalNotes] but not the average
/// (B7). CHEESE-23 adds the fixture tests and the `< 3 notes` treatment.
@immutable
class TastingStats {
  const TastingStats({
    required this.totalNotes,
    required this.ratedNotes,
    required this.averageRating,
    required this.flavorCounts,
    required this.milkBreakdown,
  });

  static const empty = TastingStats(
    totalNotes: 0,
    ratedNotes: 0,
    averageRating: 0,
    flavorCounts: {},
    milkBreakdown: {},
  );

  final int totalNotes;

  /// Notes with a rating; the denominator of [averageRating].
  final int ratedNotes;

  /// Mean of rated notes, 0 when none are rated.
  final double averageRating;

  /// Flavor -> number of notes scoring it >= 3.
  final Map<FlavorNote, int> flavorCounts;

  /// Milk -> fraction of all notes (0..1).
  final Map<MilkType, double> milkBreakdown;

  factory TastingStats.fromNotes(Iterable<TastingNote> notes) {
    final list = notes.toList();
    if (list.isEmpty) return empty;
    final flavorCounts = <FlavorNote, int>{};
    final milkCounts = <MilkType, int>{};
    var ratingSum = 0;
    var rated = 0;
    for (final n in list) {
      if (n.isRated) {
        ratingSum += n.rating;
        rated++;
      }
      milkCounts[n.milk] = (milkCounts[n.milk] ?? 0) + 1;
      n.flavors.forEach((f, v) {
        if (v >= 3) flavorCounts[f] = (flavorCounts[f] ?? 0) + 1;
      });
    }
    return TastingStats(
      totalNotes: list.length,
      ratedNotes: rated,
      averageRating: rated == 0 ? 0 : ratingSum / rated,
      flavorCounts: Map.unmodifiable(flavorCounts),
      milkBreakdown: Map.unmodifiable(
        milkCounts.map((k, v) => MapEntry(k, v / list.length)),
      ),
    );
  }

  /// Flavors ordered by count, highest first (ties in wheel order).
  List<MapEntry<FlavorNote, int>> get topFlavors =>
      flavorCounts.entries.toList()..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.index.compareTo(b.key.index);
      });

  /// Charts need material: fewer than three notes shows tiles only
  /// (DESIGN_SPEC §8).
  bool get hasEnoughForCharts => totalNotes >= minNotesForCharts;

  static const minNotesForCharts = 3;

  /// Milks by share, largest first (ties in enum order).
  List<MapEntry<MilkType, double>> get milkShares =>
      milkBreakdown.entries.toList()..sort((a, b) {
        final byShare = b.value.compareTo(a.value);
        return byShare != 0 ? byShare : a.key.index.compareTo(b.key.index);
      });

  /// The milk with a strict majority of the vote, or null when tied or
  /// when there is nothing to judge yet.
  MilkType? get dominantMilk {
    if (!hasEnoughForCharts) {
      return null;
    }
    final shares = milkShares;
    if (shares.isEmpty) {
      return null;
    }
    if (shares.length > 1 && shares[1].value == shares[0].value) {
      return null;
    }
    return shares.first.key;
  }

  /// The italic line under the milk breakdown, TKFW voice.
  String get verdictLine {
    if (!hasEnoughForCharts) return 'Verdict: too early to call. Keep tasting.';
    final milk = dominantMilk;
    if (milk == null) {
      return 'Verdict: no favourite yet. Admirably open-minded.';
    }
    final name = switch (milk) {
      MilkType.other => 'something unusual',
      _ => milk.label.toLowerCase(),
    };
    return "Verdict: you have a type, and it's $name.";
  }
}
