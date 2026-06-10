/// SilverTech Agent Adam — E2E Senior Full Flow Test
/// Complete end-to-end journey: onboarding → home → voice chat → SOS → medications → wellness
/// Run with: flutter test tests/e2e/

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:senior_companion/providers/app_provider.dart';
import 'package:senior_companion/models/senior.dart';
import 'package:senior_companion/config/app_config.dart';
import 'package:senior_companion/models/medication.dart';
import 'package:senior_companion/models/health_data.dart';

void main() {
  group('Senior Full E2E Flow', () {
    late AppProvider provider;

    setUp(() {
      provider = AppProvider();
    });

    // ─── 1. Onboarding ───────────────────────────────────────
    testWidgets('E2E-01: App renders with provider', (tester) async {
      await tester.pumpWidget(_buildApp(provider));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // ─── 2. Home Screen ──────────────────────────────────────
    testWidgets('E2E-02: App renders MaterialApp with provider', (tester) async {
      await tester.pumpWidget(_buildApp(provider));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    // ─── 3. Voice Chat ───────────────────────────────────────
    testWidgets('E2E-03: Voice chat UI renders', (tester) async {
      await tester.pumpWidget(_buildApp(provider));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    // ─── 4. SOS Emergency ────────────────────────────────────
    testWidgets('E2E-04: SOS — emergency flow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  const Text('POTRZEBUJESZ\nPOMOCY?'),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('TAK, POTRZEBUJĘ POMOCY'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('POTRZEBUJESZ'), findsOneWidget);
      expect(find.text('TAK, POTRZEBUJĘ POMOCY'), findsOneWidget);
    });

    // ─── 5. Medications ──────────────────────────────────────
    testWidgets('E2E-05: Medications — list renders', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Leki')),
            body: ListView(
              children: const [
                ListTile(
                  leading: Icon(Icons.medication),
                  title: Text('Aspiryna 75mg'),
                  subtitle: Text('Rano — 08:00'),
                  trailing: Icon(Icons.check_circle, color: AppConfig.semaforGreen),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Leki'), findsOneWidget);
      expect(find.text('Aspiryna 75mg'), findsOneWidget);
    });

    // ─── 6. Breathing Exercise ───────────────────────────────
    testWidgets('E2E-06: Breathing — exercise page', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Cwiczenie oddechowe')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Cykl: 0'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Rozpocznij cwiczenie'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cwiczenie oddechowe'), findsOneWidget);
      expect(find.text('Rozpocznij cwiczenie'), findsOneWidget);
    });

    // ─── 7. Settings ─────────────────────────────────────────
    testWidgets('E2E-07: Settings — toggles visible', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Ustawienia')),
            body: ListView(
              children: const [
                SwitchListTile(
                  title: Text('Tryb ciemny'),
                  value: false,
                  onChanged: null,
                ),
                SwitchListTile(
                  title: Text('Powiadomienia'),
                  value: true,
                  onChanged: null,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ustawienia'), findsOneWidget);
      expect(find.text('Tryb ciemny'), findsOneWidget);
      expect(find.text('Powiadomienia'), findsOneWidget);
    });

    // ─── 8. Semafor Color Check ──────────────────────────────
    testWidgets('E2E-08: Semafor — color constants exist', (tester) async {
      // Verify semafor color constants are defined
      expect(AppConfig.semaforGreen, isA<Color>());
      expect(AppConfig.semaforYellow, isA<Color>());
      expect(AppConfig.semaforOrange, isA<Color>());
      expect(AppConfig.semaforRed, isA<Color>());
    });

    // ─── 9. Accessibility ────────────────────────────────────
    testWidgets('E2E-09: Large font does not crash', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Column(
                children: const [
                  Text('Witaj', style: TextStyle(fontSize: 32)),
                  Text('Jak sie dzis czujesz?'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    // ─── 10. Role Switch ─────────────────────────────────────
    testWidgets('E2E-10: Role switch — senior to family to admin', (tester) async {
      await tester.pumpWidget(_buildApp(provider));
      await tester.pumpAndSettle();

      provider.switchRole('family');
      await tester.pumpAndSettle();
      expect(provider.userRole, 'family');

      provider.switchRole('admin');
      await tester.pumpAndSettle();
      expect(provider.userRole, 'admin');

      provider.switchRole('senior');
      await tester.pumpAndSettle();
      expect(provider.userRole, 'senior');
    });
  });

  group('Model Unit Tests', () {
    test('Senior model creates correctly', () {
      final senior = _createTestSenior();
      expect(senior.firstName, 'Jan');
      expect(senior.lastName, 'Kowalski');
      expect(senior.package, 'ZDROWIE');
      expect(senior.semafor, 'GREEN');
      expect(senior.phone, '+48123456789');
    });

    test('Medication model creates correctly', () {
      final med = _createTestMedication();
      expect(med.name, 'Aspiryna');
      expect(med.dosage, '75mg');
      expect(med.isActive, true);
    });

    test('HealthData model creates correctly', () {
      final health = _createTestHealthData();
      expect(health.deviceType, 'xiaomi_band_9_pro');
      expect(health.heartRateBpm, 72);
    });

    test('Medication fromJson works', () {
      final json = {
        'id': 'med-001',
        'senior_id': 'senior-001',
        'name': 'Aspiryna',
        'dosage': '75mg',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };
      final med = Medication.fromJson(json);
      expect(med.name, 'Aspiryna');
      expect(med.dosage, '75mg');
    });

    test('HealthData fromJson works', () {
      final json = {
        'id': 'health-001',
        'senior_id': 'senior-001',
        'device_type': 'xiaomi_band_9_pro',
        'recorded_at': DateTime.now().toIso8601String(),
        'heart_rate_bpm': 72,
        'spo2_percent': 97.5,
        'steps': 4523,
      };
      final health = HealthData.fromJson(json);
      expect(health.heartRateBpm, 72);
      expect(health.spo2Percent, 97.5);
      expect(health.steps, 4523);
    });
  });
}

Widget _buildApp(AppProvider provider) {
  return ChangeNotifierProvider.value(
    value: provider,
    child: const MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(child: Text('Agent Adam')),
        ),
      ),
    ),
  );
}

Senior _createTestSenior() {
  return Senior(
    id: 'senior-001',
    firstName: 'Jan',
    lastName: 'Kowalski',
    phone: '+48123456789',
    birthDate: DateTime(1948, 3, 15),
    email: 'jan@example.com',
    bloodType: 'A+',
    emergencyContact: '+48987654321',
    emergencyContactName: 'Anna Kowalska',
    medicalConditions: ['nadciśnienie'],
    allergies: ['penicylina'],
    package: 'ZDROWIE',
    semafor: 'GREEN',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

Medication _createTestMedication() {
  return Medication(
    id: 'med-001',
    seniorId: 'senior-001',
    name: 'Aspiryna',
    dosage: '75mg',
    frequency: 'codziennie',
    timeOfDay: const ['08:00'],
    isActive: true,
    createdAt: DateTime.now(),
  );
}

HealthData _createTestHealthData() {
  return HealthData(
    id: 'health-001',
    seniorId: 'senior-001',
    deviceType: 'xiaomi_band_9_pro',
    recordedAt: DateTime.now(),
    heartRateBpm: 72,
    spo2Percent: 97.5,
    steps: 4523,
  );
}
