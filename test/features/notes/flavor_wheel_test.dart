import 'dart:math' as math;

import 'package:cheesy_scribe/data/models/models.dart';
import 'package:cheesy_scribe/features/notes/widgets/flavor_entry_card.dart';
import 'package:cheesy_scribe/features/notes/widgets/flavor_list.dart';
import 'package:cheesy_scribe/features/notes/widgets/flavor_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support.dart';

void main() {
  group('FlavorWheelGeometry', () {
    final g = FlavorWheelGeometry(300);

    test('every spoke × ring point hit-tests back to itself', () {
      for (var spoke = 0; spoke < 16; spoke++) {
        for (var ring = 1; ring <= 5; ring++) {
          final hit = g.hitTest(g.pointFor(spoke, ring.toDouble()));
          expect(hit, (FlavorNote.values[spoke], ring), reason: '$spoke/$ring');
        }
      }
    });

    test('12 o\'clock boundary resolves to spoke 0 on both sides', () {
      final r = g.radius * 0.8;
      final justLeft = g.center + Offset(-0.5, -r);
      final justRight = g.center + Offset(0.5, -r);
      expect(g.hitTest(justLeft)?.$1, FlavorNote.salty);
      expect(g.hitTest(justRight)?.$1, FlavorNote.salty);
      // Halfway between spoke 15 and spoke 0 rounds to whichever is nearer.
      final a = FlavorWheelGeometry.angleOf(15) + math.pi / 16 - 0.01;
      final p = g.center + Offset.fromDirection(a, r);
      expect(g.hitTest(p)?.$1, FlavorNote.crystalline);
    });

    test('centre is ring 0 and far outside is a miss', () {
      expect(g.hitTest(g.center)?.$2, 0);
      expect(g.hitTest(g.center + Offset(0, -g.radius * 2)), isNull);
      // Just past the rim (label zone) still counts as ring 5.
      expect(g.hitTest(g.pointFor(4, 5.9))?.$2, 5);
    });
  });

  group('FlavorWheel', () {
    testWidgets('tap sets the score, tapping the same ring clears it', (
      tester,
    ) async {
      Map<FlavorNote, int>? changed;
      var values = const <FlavorNote, int>{FlavorNote.salty: 2};
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 300,
            child: StatefulBuilder(
              builder: (context, setState) => FlavorWheel(
                values: values,
                onChanged: (v) => setState(() => values = changed = v),
              ),
            ),
          ),
        ),
      );
      final origin = tester.getTopLeft(find.byType(FlavorWheel));
      final g = FlavorWheelGeometry(300);

      await tester.tapAt(origin + g.pointFor(7, 3)); // nutty
      await tester.pumpAndSettle();
      expect(changed, {FlavorNote.salty: 2, FlavorNote.nutty: 3});

      await tester.tapAt(origin + g.pointFor(7, 3));
      await tester.pumpAndSettle();
      expect(changed, {FlavorNote.salty: 2});

      // Near the centre on the salty spoke rounds to ring 0 = clear.
      await tester.tapAt(origin + g.pointFor(0, 0.3));
      await tester.pumpAndSettle();
      expect(changed, isEmpty);
    });

    testWidgets('read-only wheel ignores taps and renders in dark', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 300,
            child: FlavorWheel(values: {FlavorNote.caramel: 4}),
          ),
          dark: true,
        ),
      );
      final origin = tester.getTopLeft(find.byType(FlavorWheel));
      await tester.tapAt(origin + FlavorWheelGeometry(300).pointFor(0, 5));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('FlavorList', () {
    testWidgets('pip N sets N; the current pip clears', (tester) async {
      Map<FlavorNote, int>? changed;
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: FlavorList(
                values: const {FlavorNote.sweet: 2},
                onChanged: (v) => changed = v,
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(FlavorList.pipKey(FlavorNote.salty, 4)));
      expect(changed, {FlavorNote.sweet: 2, FlavorNote.salty: 4});
      await tester.tap(find.byKey(FlavorList.pipKey(FlavorNote.sweet, 2)));
      expect(changed, isEmpty);
      expect(find.text('SHARP/TANGY'), findsOneWidget);
    });
  });

  group('FlavorEntryCard', () {
    testWidgets('switching modes keeps the values; read-only hides toggle', (
      tester,
    ) async {
      var values = const <FlavorNote, int>{FlavorNote.earthy: 5};
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) => FlavorEntryCard(
                  values: values,
                  onChanged: (v) => setState(() => values = v),
                ),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(FlavorWheel), findsOneWidget);
      expect(find.textContaining('Tap a spoke'), findsOneWidget);

      await tester.tap(find.text('List'));
      await tester.pumpAndSettle();
      expect(find.byType(FlavorList), findsOneWidget);
      expect(find.textContaining('Tap the pips'), findsOneWidget);
      await tester.tap(find.byKey(FlavorList.pipKey(FlavorNote.lemon, 3)));
      await tester.pumpAndSettle();
      expect(values, {FlavorNote.earthy: 5, FlavorNote.lemon: 3});

      await tester.tap(find.text('Wheel'));
      await tester.pumpAndSettle();
      final wheel = tester.widget<FlavorWheel>(find.byType(FlavorWheel));
      expect(wheel.values, {FlavorNote.earthy: 5, FlavorNote.lemon: 3});

      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 360,
            child: FlavorEntryCard(values: {FlavorNote.earthy: 5}),
          ),
        ),
      );
      expect(find.byType(SegmentedButton<FlavorEntryMode>), findsNothing);
      expect(find.byType(FlavorWheel), findsOneWidget);
    });
  });
}
