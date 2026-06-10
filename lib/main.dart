import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/app_provider.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/senior/senior_home_screen.dart';
import 'screens/family/family_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/landing/landing_page_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SeniorCompanionApp());
}

class SeniorCompanionApp extends StatelessWidget {
  const SeniorCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()..initialize()),
      ],
      child: MaterialApp(
        title: 'Senior Companion - Agent Adam',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.seniorTheme,
        home: const AppShell(),
        routes: {
          '/login': (context) => const AuthScreen(),
          '/home': (context) => const AppShell(),
          '/landing': (context) => const LandingPageScreen(),
        },
      ),
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
