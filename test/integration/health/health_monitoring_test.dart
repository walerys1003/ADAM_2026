import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:senior_companion/providers/app_provider.dart';
import 'package:senior_companion/screens/senior/senior_health_screen.dart';
import '../../mocks/mock_data.dart';

/// Integration test: Health monitoring dashboard
void main() {
  group('Health Monitoring Integration', () {
    Widget buildTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>(
            create: (_) {
              final provider = AppProvider();
              provider.setCurrentSenior(MockData.seniorJanina);
              return provider;
            },
          ),
        ],
        child: const MaterialApp(home: SeniorHealthScreen()),
      );
    }

    testWidgets('renders health dashboard with data', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.textContaining('Zdrowie'), findsWidgets);
    });

    testWidgets('displays health metrics sections', (tester) async {
      await tester.pumpWidget(buildTestApp());

      // Should have at least some metric displays
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('handles loading state', (tester) async {
      final provider = AppProvider();
      provider.setLoading(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider<AppProvider>.value(value: provider)],
          child: const MaterialApp(home: SeniorHealthScreen()),
        ),
      );

      // Should handle loading gracefully
    });
  });
}
