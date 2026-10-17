import 'package:cheesy_scribe/app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forge_ui/forge_ui.dart';
import 'package:heroicons/heroicons.dart';

import '../support.dart';

void main() {
  group('StarRating', () {
    testWidgets('tapping star N sets N; tapping the current score clears', (
      tester,
    ) async {
      final changes = <int>[];
      await tester.pumpWidget(
        wrap(StarRating(value: 2, size: 30, onChanged: changes.add)),
      );
      await tester.tap(find.byType(HeroIcon).at(3));
      await tester.tap(find.byType(HeroIcon).at(1));
      expect(changes, [4, 0]);
    });

    testWidgets('display mode shows the score and hides it when unrated', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const StarRating(value: 4, showScore: true)),
      );
      expect(find.text('4.0'), findsOneWidget);
      await tester.pumpWidget(
        wrap(const StarRating(value: 0, showScore: true)),
      );
      expect(find.text('—'), findsOneWidget);
    });
  });

  testWidgets('JournalField shows label, hint and an uppercase error line', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const JournalField(
          label: 'Cheese name',
          hint: 'Start with what the label says',
          errorText: 'A cheese needs a name.',
        ),
      ),
    );
    expect(find.text('CHEESE NAME'), findsOneWidget);
    expect(find.text('Start with what the label says'), findsOneWidget);
    expect(find.text('A CHEESE NEEDS A NAME.'), findsOneWidget);
  });

  // The shared atoms are tested in forge_ui; this checks they take the
  // app's palette in both themes.
  testWidgets('ForgeFab and ForgeLogoBadge render in both themes', (
    tester,
  ) async {
    for (final dark in [false, true]) {
      await tester.pumpWidget(
        wrap(
          Column(
            children: [
              const ForgeLogoBadge(),
              ForgeFab(label: 'New tasting notes', onPressed: () {}),
              const ForgeSkeletonList(),
            ],
          ),
          dark: dark,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('New tasting notes'), findsOneWidget);
      expect(find.byType(ForgeSkeletonRow), findsNWidgets(3));
    }
  });
}
