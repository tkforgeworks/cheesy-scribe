import 'dart:convert';
import 'dart:io';

import 'package:cheesy_scribe/data/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

TastingNote note(
  String id, {
  MilkType milk = MilkType.cow,
  int rating = 0,
  Map<FlavorNote, int> flavors = const {},
}) => TastingNote(
  id: id,
  cheeseName: id,
  tastedAt: DateTime(2026, 8, 1),
  createdAt: DateTime.utc(2026, 8, 1),
  milk: milk,
  rating: rating,
  flavors: flavors,
);

/// The mocked 128-note journal: 4.2 average, 62/22/11/5 milk split.
List<TastingNote> loadFixture() =>
    (jsonDecode(File('test/fixtures/stats_128_notes.json').readAsStringSync())
            as List<dynamic>)
        .map((e) => TastingNote.fromJson(e as Map<String, dynamic>))
        .toList();

void main() {
  test('empty journal', () {
    final s = TastingStats.fromNotes(const []);
    expect(s, TastingStats.empty);
    expect(s.hasEnoughForCharts, isFalse);
    expect(s.dominantMilk, isNull);
    expect(s.verdictLine, 'Verdict: too early to call. Keep tasting.');
  });

  test('one or two notes: real numbers, no charts', () {
    final one = TastingStats.fromNotes([note('a', rating: 4)]);
    expect(one.totalNotes, 1);
    expect(one.averageRating, 4);
    expect(one.hasEnoughForCharts, isFalse);
    final two = TastingStats.fromNotes([
      note('a', rating: 4),
      note('b', rating: 5, milk: MilkType.goat),
    ]);
    expect(two.totalNotes, 2);
    expect(two.averageRating, 4.5);
    expect(two.milkBreakdown[MilkType.cow], 0.5);
    expect(two.hasEnoughForCharts, isFalse);
    expect(two.verdictLine, contains('too early'));
  });

  test('three notes unlock the charts; rating 0 stays out of the average', () {
    final s = TastingStats.fromNotes([
      note('a', rating: 5),
      note('b', rating: 0),
      note('c', rating: 3, milk: MilkType.goat),
    ]);
    expect(s.hasEnoughForCharts, isTrue);
    expect(s.ratedNotes, 2);
    expect(s.averageRating, 4);
    expect(s.dominantMilk, MilkType.cow);
    expect(s.verdictLine, "Verdict: you have a type, and it's cow.");
  });

  test('all unrated: average 0, no rated notes', () {
    final s = TastingStats.fromNotes([note('a'), note('b'), note('c')]);
    expect(s.ratedNotes, 0);
    expect(s.averageRating, 0);
    expect(s.hasEnoughForCharts, isTrue);
  });

  test('a tie has no dominant milk and a neutral verdict', () {
    final s = TastingStats.fromNotes([
      note('a', milk: MilkType.cow),
      note('b', milk: MilkType.goat),
      note('c', milk: MilkType.cow),
      note('d', milk: MilkType.goat),
    ]);
    expect(s.dominantMilk, isNull);
    expect(s.verdictLine, 'Verdict: no favourite yet. Admirably open-minded.');
    expect(s.milkShares.map((e) => e.key), [MilkType.cow, MilkType.goat]);
  });

  test('"other" milk gets a kinder verdict', () {
    final s = TastingStats.fromNotes([
      note('a', milk: MilkType.other),
      note('b', milk: MilkType.other),
      note('c', milk: MilkType.cow),
    ]);
    expect(
      s.verdictLine,
      "Verdict: you have a type, and it's something unusual.",
    );
  });

  test('flavor counts need a score of 3 or more', () {
    final s = TastingStats.fromNotes([
      note('a', flavors: const {FlavorNote.caramel: 3, FlavorNote.lemon: 2}),
      note('b', flavors: const {FlavorNote.caramel: 5}),
      note('c', flavors: const {FlavorNote.nutty: 4, FlavorNote.lemon: 1}),
    ]);
    expect(s.flavorCounts, {FlavorNote.caramel: 2, FlavorNote.nutty: 1});
    expect(s.topFlavors.first.key, FlavorNote.caramel);
  });

  test('the mocked 128-note journal reproduces the design numbers', () {
    final notes = loadFixture();
    expect(notes, hasLength(128));
    final s = TastingStats.fromNotes(notes);
    expect(s.totalNotes, 128);
    expect(s.ratedNotes, 120);
    expect(s.averageRating, closeTo(4.2, 1e-9));
    String pct(MilkType m) => '${(s.milkBreakdown[m]! * 100).round()}%';
    expect(pct(MilkType.cow), '62%');
    expect(pct(MilkType.goat), '22%');
    expect(pct(MilkType.sheep), '11%');
    expect(pct(MilkType.buffalo), '5%');
    expect(s.dominantMilk, MilkType.cow);
    expect(s.verdictLine, "Verdict: you have a type, and it's cow.");
    final top = s.topFlavors
        .take(4)
        .map((e) => '${e.key.label} ${e.value}')
        .toList();
    expect(top, ['CARAMEL 32', 'NUTTY 28', 'EARTHY 21', 'GRASSY 14']);
    expect(s.flavorCounts.containsKey(FlavorNote.lemon), isFalse);
  });
}
