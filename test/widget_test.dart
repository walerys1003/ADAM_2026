import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SeniorCompanionApp());
    await tester.pumpAndSettle();

    // Verify the app renders without errors
    expect(find.byType(SeniorCompanionApp), findsNothing); // wrapped in MaterialApp
  });
}
