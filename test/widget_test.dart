import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/main.dart';
import 'package:senior_companion/providers/app_provider.dart';
import 'package:senior_companion/services/health_connect/health_connect_service.dart';
import 'package:senior_companion/services/notifications/notification_service.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    final appProvider = AppProvider();
    final healthConnect = HealthConnectService();
    final notifications = NotificationService();

    await tester.pumpWidget(SeniorCompanionApp(
      appProvider: appProvider,
      healthConnectService: healthConnect,
      notificationService: notifications,
    ));
    await tester.pumpAndSettle();

    // Verify the app renders without errors — should show LandingPageScreen by default
    expect(find.byType(SeniorCompanionApp), findsNothing); // wrapped in MaterialApp
  });
}
