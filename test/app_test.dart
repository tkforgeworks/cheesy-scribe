import 'package:cheesy_scribe/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots and shows its name', (tester) async {
    await tester.pumpWidget(const ScribeApp());
    expect(find.text('Cheesy Scribe'), findsOneWidget);
  });
}
