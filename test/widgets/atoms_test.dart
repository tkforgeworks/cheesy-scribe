import 'package:cheesy_scribe/app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('MonoLabel and capsules uppercase their content', (tester) async {
    await tester.pumpWidget(
      wrap(
        const Column(
          children: [
            MonoLabel('Cheese name'),
            TagCapsule('cow', tone: CapsuleTone.emphasis),
            StatusCapsule('connected', active: true),
          ],
        ),
      ),
    );
    expect(find.text('CHEESE NAME'), findsOneWidget);
    expect(find.text('COW'), findsOneWidget);
    expect(find.text('CONNECTED'), findsOneWidget);
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

  testWidgets('BoxedField accepts input', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      wrap(BoxedField(label: 'Email', controller: controller)),
    );
    await tester.enterText(find.byType(TextField), 'tyler@example.com');
    expect(controller.text, 'tyler@example.com');
    expect(find.text('EMAIL'), findsOneWidget);
  });

  testWidgets('ConfirmSheet resolves true on confirm and false on cancel', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => FilledButton(
            onPressed: () async {
              result = await showConfirmSheet(
                context,
                title: 'Discard this note?',
                aside: 'The cheese deserved better.',
                confirmLabel: 'Discard',
                cancelLabel: 'Keep writing',
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Discard this note?'), findsOneWidget);
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(result, isTrue);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep writing'));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('EmptyState renders title, aside and action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        EmptyState(
          icon: const WedgeGlyph(),
          title: 'No tastings yet',
          aside: "The cheese isn't going to review itself.",
          action: FilledButton(
            onPressed: () => tapped = true,
            child: const Text('New tasting notes'),
          ),
        ),
      ),
    );
    expect(find.text('No tastings yet'), findsOneWidget);
    await tester.tap(find.text('New tasting notes'));
    expect(tapped, isTrue);
  });

  testWidgets('ErrorCard shows message and calls retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      wrap(
        ErrorCard(
          message: "Couldn't reach the cellar.",
          onRetry: () => retried = true,
        ),
      ),
    );
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });

  testWidgets('ForgeFab and ForgeLogoBadge render in both themes', (
    tester,
  ) async {
    for (final dark in [false, true]) {
      await tester.pumpWidget(
        wrap(
          Column(
            children: [
              const ForgeLogoBadge(),
              ForgeFab(onPressed: () {}),
              const SkeletonList(),
            ],
          ),
          dark: dark,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('New tasting notes'), findsOneWidget);
      expect(find.byType(SkeletonRow), findsNWidgets(3));
    }
  });
}
