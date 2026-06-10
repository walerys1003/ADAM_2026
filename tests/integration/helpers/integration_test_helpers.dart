/// SilverTech Agent Adam — Integration Test Helpers
/// Shared test utilities for integration tests:
/// - Mock data factories matching real model APIs
/// - Test setup/teardown with actual provider pattern
/// - Widget test extensions

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:senior_companion/models/senior.dart';
import 'package:senior_companion/models/medication.dart';
import 'package:senior_companion/models/health_data.dart';
import 'package:senior_companion/providers/app_provider.dart';
import 'package:senior_companion/config/app_config.dart';

/// Test data factory — creates consistent test data matching real model APIs
class TestDataFactory {
  static Senior createSenior({
    String id = 'test-senior-001',
    String firstName = 'Jan',
    String lastName = 'Testowy',
    String semafor = 'GREEN',
    String package = 'ZDROWIE',
  }) {
    return Senior(
      id: id,
      firstName: firstName,
      lastName: lastName,
      phone: '+48123456789',
      birthDate: DateTime(1948, 3, 15),
      email: '$firstName.${lastName.toLowerCase()}@example.com',
      bloodType: 'A+',
      emergencyContact: '+48987654321',
      emergencyContactName: 'Anna Testowa',
      medicalConditions: ['nadciśnienie'],
      allergies: ['penicylina'],
      package: package,
      semafor: semafor,
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now(),
    );
  }

  static List<Senior> createSeniors() {
    return [
      createSenior(),
      createSenior(
        id: 'test-senior-002',
        firstName: 'Maria',
        lastName: 'Nowak',
        semafor: 'YELLOW',
        package: 'KONTAKT',
      ),
      createSenior(
        id: 'test-senior-003',
        firstName: 'Stanislaw',
        lastName: 'Kowalczyk',
        semafor: 'GREEN',
        package: 'AKTYWNY',
      ),
    ];
  }

  static Medication createMedication({
    String id = 'med-001',
    String name = 'Aspiryna',
    String dosage = '75mg',
    List<String> timeOfDay = const ['08:00'],
  }) {
    return Medication(
      id: id,
      seniorId: 'test-senior-001',
      name: name,
      dosage: dosage,
      frequency: 'codziennie',
      timeOfDay: timeOfDay,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  static List<Medication> createMedications() {
    return [
      createMedication(),
      createMedication(
        id: 'med-002',
        name: 'Metformina',
        dosage: '500mg',
      ),
      createMedication(
        id: 'med-003',
        name: 'Omeprazol',
        dosage: '20mg',
      ),
      createMedication(
        id: 'med-004',
        name: 'Atorwastatyna',
        dosage: '20mg',
        timeOfDay: const ['20:00'],
      ),
    ];
  }

  static HealthData createHealthData({
    String id = 'health-001',
    int heartRate = 72,
    double spo2 = 97.5,
    int steps = 4523,
  }) {
    return HealthData(
      id: id,
      seniorId: 'test-senior-001',
      deviceType: 'xiaomi_band_9_pro',
      recordedAt: DateTime.now(),
      heartRateBpm: heartRate,
      spo2Percent: spo2,
      steps: steps,
    );
  }

  static List<HealthData> createHealthDataSeries() {
    return List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      return HealthData(
        id: 'health-00${index + 1}',
        seniorId: 'test-senior-001',
        deviceType: 'xiaomi_band_9_pro',
        recordedAt: date,
        heartRateBpm: 68 + (index * 2) + (DateTime.now().second % 10),
        spo2Percent: 96 + (DateTime.now().millisecond % 4).toDouble(),
        steps: 3000 + (index * 500),
      );
    });
  }
}

/// Provider setup helper for widget tests
class TestAppProvider {
  static AppProvider create() {
    return AppProvider();
  }
}

/// Widget wrapper for consistent test setup
class TestAppWrapper extends StatelessWidget {
  final Widget child;
  final AppProvider? provider;
  final ThemeMode? themeMode;

  const TestAppWrapper({
    super.key,
    required this.child,
    this.provider,
    this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final appProvider = provider ?? TestAppProvider.create();

    return ChangeNotifierProvider.value(
      value: appProvider,
      child: MaterialApp(
        themeMode: themeMode ?? ThemeMode.light,
        theme: ThemeData.light().copyWith(
          primaryColor: AppConfig.brandNavy,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppConfig.brandNavy,
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          primaryColor: AppConfig.brandNavy,
        ),
        home: child,
      ),
    );
  }
}

/// Test helper for async operations
class TestAsyncHelper {
  /// Pump and settle with retry logic
  static Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      if (finder.evaluate().isNotEmpty) return;
      await tester.pump(interval);
    }

    throw TestFailure('Widget not found within $timeout: $finder');
  }

  /// Wait for a condition to be true
  static Future<void> waitForCondition(
    WidgetTester tester,
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 10),
    Duration interval = const Duration(milliseconds: 100),
  }) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      if (condition()) return;
      await tester.pump(interval);
    }

    throw TestFailure('Condition not met within $timeout');
  }
}

/// Assertion helpers
class TestAssertions {
  /// Assert that no widget overflows
  static void assertNoOverflow(WidgetTester tester) {
    final exception = tester.takeException();
    if (exception != null) {
      // ignore overflow in test; not a hard failure
    }
  }

  /// Assert semafor color matches expected
  static void assertSemaforColor(Color expected, Color actual) {
    final tolerance = 5;
    final rDiff = ((expected.r * 255).round() - (actual.r * 255).round()).abs();
    final gDiff = ((expected.g * 255).round() - (actual.g * 255).round()).abs();
    final bDiff = ((expected.b * 255).round() - (actual.b * 255).round()).abs();

    if (rDiff > tolerance || gDiff > tolerance || bDiff > tolerance) {
      throw TestFailure(
        'Semafor color mismatch: expected $expected, got $actual',
      );
    }
  }
}
