import 'package:senior_companion/models/senior.dart';
import 'package:senior_companion/models/health_data.dart';
import 'package:senior_companion/models/medication.dart';
import 'package:senior_companion/models/conversation.dart';

/// Mock data factory for testing
/// Provides consistent, realistic test data across all test suites
class MockData {
  // ─── Seniors ────────────────────────────────────────────────────
  static Senior get seniorJanina => Senior(
        id: 'senior-mock-001',
        firstName: 'Janina',
        lastName: 'Kowalska',
        phone: '+48 601 111 222',
        email: 'janina.k@example.pl',
        dateOfBirth: DateTime(1948, 3, 15),
        address: 'ul. Słoneczna 12/4, 00-001 Warszawa',
        bloodType: 'A+',
        chronicConditions: ['nadciśnienie', 'cukrzyca typu 2'],
        allergies: ['penicylina'],
        emergencyContact: '+48 601 333 444',
        emergencyContactName: 'Tomasz Kowalski (syn)',
        semaforLevel: 'GREEN',
        package: 'AKTYWNY',
        onboardingCompleted: true,
        voiceRecordingConsent: true,
        healthDataConsent: true,
        familySharingConsent: true,
      );

  static Senior get seniorStanislaw => Senior(
        id: 'senior-mock-002',
        firstName: 'Stanisław',
        lastName: 'Nowak',
        phone: '+48 602 222 333',
        email: 'stanislaw.n@example.pl',
        dateOfBirth: DateTime(1945, 11, 2),
        address: 'ul. Leśna 5, 30-001 Kraków',
        bloodType: '0+',
        chronicConditions: ['arytmia', 'osteoporoza'],
        allergies: [],
        emergencyContact: '+48 602 444 555',
        emergencyContactName: 'Anna Nowak (córka)',
        semaforLevel: 'YELLOW',
        package: 'ZDROWIE',
        onboardingCompleted: true,
        voiceRecordingConsent: true,
        healthDataConsent: true,
        familySharingConsent: false,
      );

  static Senior get seniorHelena => Senior(
        id: 'senior-mock-003',
        firstName: 'Helena',
        lastName: 'Wiśniewska',
        phone: '+48 603 333 444',
        email: 'helena.w@example.pl',
        dateOfBirth: DateTime(1952, 7, 20),
        bloodType: 'B+',
        chronicConditions: ['astma'],
        allergies: ['sulfonamidy', 'lateks'],
        emergencyContact: '+48 603 555 666',
        emergencyContactName: 'Marek Wiśniewski (mąż)',
        semaforLevel: 'GREEN',
        package: 'KONTAKT',
        onboardingCompleted: true,
        voiceRecordingConsent: true,
        healthDataConsent: true,
        familySharingConsent: true,
      );

  static List<Senior> get allSeniors => [seniorJanina, seniorStanislaw, seniorHelena];

  // ─── Health Data ────────────────────────────────────────────────
  static HealthData get normalHealthData => HealthData(
        id: 'health-mock-001',
        seniorId: 'senior-mock-001',
        heartRate: 72,
        systolic: 125,
        diastolic: 80,
        spo2: 98,
        steps: 5200,
        sleepHours: 7.5,
        temperature: 36.6,
        weight: 68.0,
        source: 'health_connect',
        recordedAt: DateTime.now(),
      );

  static HealthData get elevatedHealthData => HealthData(
        id: 'health-mock-002',
        seniorId: 'senior-mock-002',
        heartRate: 95,
        systolic: 155,
        diastolic: 95,
        spo2: 96,
        steps: 1200,
        sleepHours: 4.5,
        temperature: 37.2,
        weight: 82.0,
        source: 'health_connect',
        recordedAt: DateTime.now(),
      );

  static HealthData get criticalHealthData => HealthData(
        id: 'health-mock-003',
        seniorId: 'senior-mock-001',
        heartRate: 130,
        systolic: 190,
        diastolic: 110,
        spo2: 88,
        steps: 200,
        sleepHours: 2.0,
        temperature: 38.5,
        weight: 68.0,
        source: 'manual',
        recordedAt: DateTime.now(),
      );

  // ─── Medications ────────────────────────────────────────────────
  static Medication get metformina => Medication(
        id: 'med-mock-001',
        seniorId: 'senior-mock-001',
        name: 'Metformina',
        dosage: '500mg',
        frequency: '2x dziennie (rano + wieczór)',
        prescribingDoctor: 'Dr Maria Wiśniewska',
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 12, 31),
        refillReminder: true,
      );

  static Medication get enalapryl => Medication(
        id: 'med-mock-002',
        seniorId: 'senior-mock-001',
        name: 'Enalapryl',
        dosage: '10mg',
        frequency: '1x dziennie (rano)',
        prescribingDoctor: 'Dr Maria Wiśniewska',
        startDate: DateTime(2026, 5, 15),
        endDate: DateTime(2026, 11, 15),
        refillReminder: true,
      );

  static Medication get bisoprolol => Medication(
        id: 'med-mock-003',
        seniorId: 'senior-mock-002',
        name: 'Bisoprolol',
        dosage: '5mg',
        frequency: '1x dziennie (rano)',
        prescribingDoctor: 'Dr Piotr Zalewski',
        startDate: DateTime(2026, 4, 1),
        endDate: DateTime(2026, 10, 1),
        refillReminder: true,
      );

  static List<Medication> get allMedications => [metformina, enalapryl, bisoprolol];

  // ─── Conversations ──────────────────────────────────────────────
  static List<Conversation> get sampleConversations => [
        Conversation(
          id: 'conv-mock-001',
          seniorId: 'senior-mock-001',
          seniorText: 'Adam, jaką dziś mamy pogodę?',
          adamResponse: 'Dzień dobry Pani Janino! Dziś w Warszawie słonecznie, 22°C. ☀️',
          mood: 'neutral',
          durationSeconds: 15,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Conversation(
          id: 'conv-mock-002',
          seniorId: 'senior-mock-001',
          seniorText: 'Przypomnij mi o lekach o 20:00',
          adamResponse: 'Oczywiście! Ustawiłem przypomnienie na 20:00.',
          mood: 'neutral',
          durationSeconds: 12,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        Conversation(
          id: 'conv-mock-003',
          seniorId: 'senior-mock-001',
          seniorText: 'Trochę się źle czuję dzisiaj...',
          adamResponse: 'Przykro mi to słyszeć. Sprawdziłem Pani ostatnie pomiary — ciśnienie jest w normie.',
          mood: 'negative',
          durationSeconds: 20,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  // ─── Weekly Health Summary ─────────────────────────────────────
  static WeeklyHealthSummary get weeklySummary => WeeklyHealthSummary(
        seniorId: 'senior-mock-001',
        weekStart: DateTime.now().subtract(const Duration(days: 7)),
        weekEnd: DateTime.now(),
        avgHeartRate: 71.2,
        avgSystolic: 124.0,
        avgDiastolic: 79.0,
        avgSteps: 4800,
        avgSleepHours: 7.1,
        totalSteps: 33600,
        medicationAdherence: 0.85,
        dominantMood: 'neutral',
        semaforLevel: 'GREEN',
      );
}
