import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:senior_companion/providers/app_provider.dart';
import 'package:senior_companion/screens/senior/contacts/senior_contacts_screen.dart';

void main() {
  group('SeniorContactsScreen', () {
    Widget buildTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AppProvider>(create: (_) => AppProvider()),
        ],
        child: const MaterialApp(
          home: SeniorContactsScreen(),
        ),
      );
    }

    testWidgets('renders title and search bar', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Kontakty'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders emergency section header', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.textContaining('Kontakty alarmowe'), findsOneWidget);
      expect(find.textContaining('Pozostałe kontakty'), findsOneWidget);
    });

    testWidgets('renders all emergency contacts', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.textContaining('Pogotowie Ratunkowe'), findsOneWidget);
      expect(find.textContaining('112'), findsOneWidget);
    });

    testWidgets('search filters contacts', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Type in search
      await tester.enterText(find.byType(TextField), 'Pogotowie');
      await tester.pump();

      // Only emergency services matching should show
      expect(find.textContaining('Pogotowie'), findsOneWidget);
      expect(find.textContaining('Jan Kowalski'), findsNothing);
    });

    testWidgets('renders call buttons', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      final callButtons = find.byIcon(Icons.call);
      // 10 contacts = at least 10 call buttons
      expect(callButtons, findsWidgets);
    });

    testWidgets('renders contact avatars with initials', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Uppercase first letter of each contact
      expect(find.text('J'), findsWidgets);
    });
  });
}
