import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:senior_companion/providers/app_provider.dart';
import 'package:senior_companion/screens/senior/wellness/senior_breathing_screen.dart';

void main() {
  group('SeniorBreathingScreen', () {
    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider()),
        ],
        child: const MaterialApp(
          home: SeniorBreathingScreen(),
        ),
      );
    }

    testWidgets('renders title and initial state', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Ćwiczenie oddechowe'), findsOneWidget);
      expect(find.text('Cykl: 0'), findsOneWidget);
      expect(find.text('Gotowy?'), findsOneWidget);
      expect(find.text('Rozpocznij ćwiczenie'), findsOneWidget);
    });

    testWidgets('start button begins breathing exercise', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Tap start
      await tester.tap(find.text('Rozpocznij ćwiczenie'));
      await tester.pump();

      // Should show inhale phase
      expect(find.text('Wdech (4s)'), findsOneWidget);
      expect(find.text('Zatrzymaj'), findsOneWidget);
    });

    testWidgets('stop button halts exercise', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Start
      await tester.tap(find.text('Rozpocznij ćwiczenie'));
      await tester.pump();

      // Stop
      await tester.tap(find.text('Zatrzymaj'));
      await tester.pump();

      // Back to ready
      expect(find.text('Gotowy?'), findsOneWidget);
      expect(find.text('Rozpocznij ćwiczenie'), findsOneWidget);
    });

    testWidgets('renders tips section', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Wskazówka'), findsOneWidget);
      expect(
        find.textContaining('Usiądź wygodnie'),
        findsOneWidget,
      );
    });

    testWidgets('renders in dark theme', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF0D1B2A));
    });
  });
}
