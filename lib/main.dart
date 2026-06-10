import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/theme.dart';
import 'providers/app_provider.dart';
import 'services/health_connect/health_connect_service.dart';
import 'services/notifications/notification_service.dart';
import 'models/medication.dart';

// ── Auth ──
import 'screens/auth/auth_screen.dart';

// ── Senior screens ──
import 'screens/senior/senior_home_screen.dart';
import 'screens/senior/senior_health_screen.dart';
import 'screens/senior/senior_medications_screen.dart';
import 'screens/senior/senior_marketplace_screen.dart';
import 'screens/senior/senior_sos_screen.dart';
import 'screens/senior/contacts/senior_contacts_screen.dart';
import 'screens/senior/emergency/senior_sos_flow_screen.dart';
import 'screens/senior/medications/senior_medication_detail_screen.dart';
import 'screens/senior/marketplace/senior_marketplace_detail_screen.dart';
import 'screens/senior/onboarding/senior_onboarding_screen.dart';
import 'screens/senior/settings/senior_settings_screen.dart';
import 'screens/senior/voice/senior_voice_chat_screen.dart';
import 'screens/senior/wellness/senior_breathing_screen.dart';
import 'screens/senior/wellness/senior_mood_journal_screen.dart';
import 'screens/senior/wellness/senior_wellness_screen.dart';

// ── Family screens ──
import 'screens/family/family_dashboard_screen.dart';
import 'screens/family/alerts/family_alert_rules_screen.dart';
import 'screens/family/calendar/family_calendar_screen.dart';
import 'screens/family/health/family_health_trends_screen.dart';
import 'screens/family/notifications/family_notifications_screen.dart';
import 'screens/family/reports/family_health_report_screen.dart';

// ── Admin screens ──
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_analytics_screen.dart';
import 'screens/admin/admin_conversations_screen.dart';
import 'screens/admin/admin_cost_optimization_screen.dart';
import 'screens/admin/admin_seniors_screen.dart';

// ── Landing screens ──
import 'screens/landing/landing_page_screen.dart';
import 'screens/landing/blog/landing_blog_screen.dart';
import 'screens/landing/blog/landing_blog_detail_screen.dart';
import 'screens/landing/contact/landing_contact_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Local storage (Hive) ──
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('cache');

  // ── App provider ──
  final appProvider = AppProvider();

  // ── Health Connect ──
  final healthConnect = HealthConnectService();
  healthConnect.initialize(); // fire-and-forget, non-blocking

  // ── Notifications ──
  final notificationService = NotificationService();
  notificationService.initialize();

  // ── Check auth state ──
  final isLoggedIn = await appProvider.checkAuthState();

  runApp(SeniorCompanionApp(
    appProvider: appProvider,
    healthConnectService: healthConnect,
    notificationService: notificationService,
    initialRoute: isLoggedIn ? '/home' : '/landing',
  ));
}

class SeniorCompanionApp extends StatelessWidget {
  final AppProvider appProvider;
  final HealthConnectService healthConnectService;
  final NotificationService notificationService;
  final String initialRoute;

  const SeniorCompanionApp({
    super.key,
    required this.appProvider,
    required this.healthConnectService,
    required this.notificationService,
    this.initialRoute = '/landing',
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>.value(value: appProvider),
        ChangeNotifierProvider<HealthConnectService>.value(
          value: healthConnectService,
        ),
        Provider<NotificationService>.value(value: notificationService),
      ],
      child: MaterialApp(
        title: 'Senior Companion - Agent Adam',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.seniorTheme,
        initialRoute: initialRoute,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  /// Complete route table — all 30+ screens accessible by named routes
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    // ── Auth ──
    if (settings.name == '/login') {
      return _page(const AuthScreen(), settings);
    }

    // ── App Shell (role-based home) ──
    if (settings.name == '/home') {
      return _page(const AppShell(), settings);
    }

    // ── Landing ──
    if (settings.name == '/landing') {
      return _page(const LandingPageScreen(), settings);
    }
    if (settings.name == '/landing/blog') {
      return _page(const LandingBlogScreen(), settings);
    }
    if (settings.name == '/landing/blog/detail') {
      final post = args as BlogPost;
      return _page(LandingBlogDetailScreen(post: post), settings);
    }
    if (settings.name == '/landing/contact') {
      return _page(const LandingContactScreen(), settings);
    }

    // ── Senior ──
    if (settings.name == '/senior/home') {
      return _page(const SeniorHomeScreen(), settings);
    }
    if (settings.name == '/senior/health') {
      return _page(const SeniorHealthScreen(seniorId: ''), settings);
    }
    if (settings.name == '/senior/medications') {
      return _page(const SeniorMedicationsScreen(seniorId: ''), settings);
    }
    if (settings.name == '/senior/medications/detail') {
      final medication = args as Medication;
      return _page(SeniorMedicationDetailScreen(medication: medication), settings);
    }
    if (settings.name == '/senior/marketplace') {
      return _page(const SeniorMarketplaceScreen(seniorId: ''), settings);
    }
    if (settings.name == '/senior/marketplace/detail') {
      final serviceArgs = args as Map<String, dynamic>? ?? {};
      return _page(SeniorMarketplaceDetailScreen(
        serviceId: serviceArgs['serviceId'] as String? ?? '',
        serviceName: serviceArgs['serviceName'] as String? ?? '',
        serviceDescription: serviceArgs['serviceDescription'] as String? ?? '',
        pricePLN: (serviceArgs['pricePLN'] as num?)?.toDouble() ?? 49.0,
      ), settings);
    }
    if (settings.name == '/senior/sos') {
      return _page(const SeniorSOSScreen(seniorId: ''), settings);
    }
    if (settings.name == '/senior/sos/flow') {
      return _page(const SeniorSosFlowScreen(), settings);
    }
    if (settings.name == '/senior/contacts') {
      return _page(const SeniorContactsScreen(), settings);
    }
    if (settings.name == '/senior/onboarding') {
      return _page(const SeniorOnboardingScreen(), settings);
    }
    if (settings.name == '/senior/settings') {
      return _page(const SeniorSettingsScreen(), settings);
    }
    if (settings.name == '/senior/voice') {
      return _page(const SeniorVoiceChatScreen(), settings);
    }
    if (settings.name == '/senior/wellness') {
      return _page(const SeniorWellnessScreen(), settings);
    }
    if (settings.name == '/senior/wellness/breathing') {
      return _page(const SeniorBreathingScreen(), settings);
    }
    if (settings.name == '/senior/wellness/mood') {
      return _page(const SeniorMoodJournalScreen(), settings);
    }

    // ── Family ──
    if (settings.name == '/family/dashboard') {
      return _page(const FamilyDashboardScreen(), settings);
    }
    if (settings.name == '/family/alerts') {
      return _page(const FamilyAlertRulesScreen(), settings);
    }
    if (settings.name == '/family/calendar') {
      return _page(const FamilyCalendarScreen(), settings);
    }
    if (settings.name == '/family/health') {
      return _page(const FamilyHealthTrendsScreen(), settings);
    }
    if (settings.name == '/family/notifications') {
      return _page(const FamilyNotificationsScreen(), settings);
    }
    if (settings.name == '/family/reports') {
      final reportArgs = args as Map<String, dynamic>? ?? {};
      return _page(FamilyHealthReportScreen(
        seniorName: reportArgs['seniorName'] as String? ?? '',
        seniorId: reportArgs['seniorId'] as String? ?? '',
      ), settings);
    }

    // ── Admin ──
    if (settings.name == '/admin/dashboard') {
      return _page(const AdminDashboardScreen(), settings);
    }
    if (settings.name == '/admin/analytics') {
      return _page(const AdminAnalyticsScreen(), settings);
    }
    if (settings.name == '/admin/conversations') {
      return _page(const AdminConversationsScreen(), settings);
    }
    if (settings.name == '/admin/costs') {
      return _page(const AdminCostOptimizationScreen(), settings);
    }
    if (settings.name == '/admin/seniors') {
      return _page(const AdminSeniorsScreen(), settings);
    }

    // Fallback
    return _page(
      Scaffold(
        appBar: AppBar(title: const Text('Nie znaleziono')),
        body: const Center(child: Text('404 — Strona nie istnieje')),
      ),
      settings,
    );
  }

  MaterialPageRoute<dynamic> _page(Widget child, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => child,
      settings: settings,
    );
  }
}

/// Main shell that shows different UI based on user role
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        switch (provider.userRole) {
          case 'senior':
            return const SeniorHomeScreen();
          case 'family':
            return const FamilyDashboardScreen();
          case 'admin':
          case 'coordinator':
            return const AdminDashboardScreen();
          default:
            return const LandingPageScreen();
        }
      },
    );
  }
}
