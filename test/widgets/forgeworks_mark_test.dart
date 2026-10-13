import 'package:cheesy_scribe/app/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mark geometry is the SVG, normalised to its viewBox', () {
    expect(ForgeWorksMark.anvil, hasLength(18));
    expect(ForgeWorksMark.hammer, hasLength(35));
    for (final p in [...ForgeWorksMark.anvil, ...ForgeWorksMark.hammer]) {
      expect(p.dx, inInclusiveRange(0, 1));
      expect(p.dy, inInclusiveRange(0, 1));
    }
    // Closed outlines: the first and last points coincide.
    expect(ForgeWorksMark.anvil.first, ForgeWorksMark.anvil.last);
    expect(
      (ForgeWorksMark.hammer.first - ForgeWorksMark.hammer.last).distance,
      lessThan(0.001),
    );
  });

  testWidgets('paints tinted and in brand colours at the requested size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              ForgeWorksMark(size: 18, color: Colors.grey),
              ForgeWorksMark(size: 96),
            ],
          ),
        ),
      ),
    );
    expect(find.byType(ForgeWorksMark), findsNWidgets(2));
    expect(
      tester.getSize(find.byType(ForgeWorksMark).first),
      const Size(18, 18),
    );
    expect(
      tester.getSize(find.byType(ForgeWorksMark).last),
      const Size(96, 96),
    );
    expect(tester.takeException(), isNull);
  });
}
