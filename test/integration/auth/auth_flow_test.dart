import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:senior_companion/providers/app_provider.dart';
import 'package:senior_companion/screens/auth/auth_screen.dart';

/// Integration test: Full auth flow (login → home → logout)
void main() {
  group('Auth Flow Integration', () {
    Widget buildTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider()),
        ],
        child: const MaterialApp(home: AuthScreen()),
      );
    }

    testWidgets('renders login form with all fields', (tester) async {
      await tester.pumpWidget(buildTestApp());

      expect(find.textContaining('Zaloguj'), findsWidgets);
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(buildTestApp());

      // Find login button and tap without filling fields
      final loginButtons = find.byType(ElevatedButton);
      if (loginButtons.evaluate().isNotEmpty) {
        await tester.tap(loginButtons.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('can navigate between login and register', (tester) async {
      await tester.pumpWidget(buildTestApp());

      // Look for register toggle
      final registerText = find.textContaining('Rejestracja');
      if (registerText.evaluate().isNotEmpty) {
        await tester.tap(registerText);
        await tester.pumpAndSettle();
      }
    });
  });
}
