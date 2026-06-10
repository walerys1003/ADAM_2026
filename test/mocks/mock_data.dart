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
        address: 'ul. Słoneczna 12/4, 00-001 Warszawa',
        birthDate: DateTime(1948, 3, 15),
        gender: 'female',
        package: 'AKTYWNY',
        medicalConditions: ['nadciśnienie', 'cukrzyca typu 2'],
        allergies: ['penicylina'],
        primaryPhysicianName: 'Dr Maria Wiśniewska',
        primaryPhysicianPhone: '+48 601 333 444',
        preferredTopics: ['wnuki', 'ogród', 'historia'],
        personalityType: 'tradycyjny',
        status: 'active',
        semafor: 'GREEN',
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now(),
      );

  static Senior get seniorStanislaw => Senior(
        id: 'senior-mock-002',
        firstName: 'Stanisław',
        lastName: 'Nowak',
        phone: '+48 602 222 333',
        address: 'ul. Leśna 5, 30-001 Kraków',
        birthDate: DateTime(1945, 11, 2),
        gender: 'male',
        package: 'ZDROWIE',
        medicalConditions: ['arytmia', 'osteoporoza'],
        allergies: [],
        primaryPhysicianName: 'Dr Piotr Zalewski',
        primaryPhysicianPhone: '+48 602 444 555',
        preferredTopics: ['sport', 'polityka', 'motoryzacja'],
        personalityType: 'przyjaciel',
        status: 'active',
        semafor: 'YELLOW',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      );

  static Senior get seniorHelena => Senior(
        id: 'senior-mock-003',
        firstName: 'Helena',
        lastName: 'Wiśniewska',
        phone: '+48 603 333 444',
        birthDate: DateTime(1952, 7, 20),
        gender: 'female',
        package: 'KONTAKT',
        medicalConditions: ['astma'],
        allergies: ['sulfonamidy', 'lateks'],
        primaryPhysicianName: 'Dr Anna Nowak',
        preferredTopics: ['książki', 'kuchnia', 'podróże'],
        personalityType: 'tradycyjny',
        status: 'active',
        semafor: 'GREEN',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );

  static List<Senior> get allSeniors => [seniorJanina, seniorStanislaw, seniorHelena];

  // ─── Health Data ────────────────────────────────────────────────
  static HealthData get normalHealthData => HealthData(
        id: 'health-mock-001',
        seniorId: 'senior-mock-001',
        deviceType: 'xiaomi_band_9_pro',
        recordedAt: DateTime.now(),
        heartRateBpm: 72,
        heartRateRestingBpm: 64,
        spo2Percent: 98.0,
        steps: 5200,
        caloriesBurned: 210.0,
        distanceMeters: 3400.0,
        activityType: 'walking',
        activityDurationMinutes: 45,
      );

  static HealthData get elevatedHealthData => HealthData(
        id: 'health-mock-002',
        seniorId: 'senior-mock-002',
        deviceType: 'xiaomi_band_9_pro',
        recordedAt: DateTime.now(),
        heartRateBpm: 95,
        heartRateRestingBpm: 78,
        spo2Percent: 96.0,
        steps: 1200,
        caloriesBurned: 55.0,
        distanceMeters: 800.0,
        activityType: 'resting',
        activityDurationMinutes: 10,
      );

  static HealthData get criticalHealthData => HealthData(
        id: 'health-mock-003',
        seniorId: 'senior-mock-001',
        deviceType: 'xiaomi_band_9_pro',
        recordedAt: DateTime.now(),
        heartRateBpm: 130,
        heartRateRestingBpm: 105,
        spo2Percent: 88.0,
        steps: 200,
        caloriesBurned: 10.0,
        distanceMeters: 130.0,
        activityType: 'resting',
        activityDurationMinutes: 2,
      );

  // ─── Medications ────────────────────────────────────────────────
  static Medication get metformina => Medication(
        id: 'med-mock-001',
        seniorId: 'senior-mock-001',
        name: 'Metformina',
        dosage: '500mg',
        frequency: '2x dziennie (rano + wieczór)',
        timeOfDay: ['08:00', '20:00'],
        instructions: 'Po posiłku',
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 12, 31),
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );

  static Medication get enalapryl => Medication(
        id: 'med-mock-002',
        seniorId: 'senior-mock-001',
        name: 'Enalapryl',
        dosage: '10mg',
        frequency: '1x dziennie (rano)',
        timeOfDay: ['08:00'],
        instructions: 'Rano na czczo',
        startDate: DateTime(2026, 5, 15),
        endDate: DateTime(2026, 11, 15),
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      );

  static Medication get bisoprolol => Medication(
        id: 'med-mock-003',
        seniorId: 'senior-mock-002',
        name: 'Bisoprolol',
        dosage: '5mg',
        frequency: '1x dziennie (rano)',
        timeOfDay: ['08:00'],
        instructions: 'Przed śniadaniem',
        startDate: DateTime(2026, 4, 1),
        endDate: DateTime(2026, 10, 1),
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      );

  static List<Medication> get allMedications => [metformina, enalapryl, bisoprolol];

  // ─── Conversations ──────────────────────────────────────────────
  static List<Conversation> get sampleConversations => [
        Conversation(
          id: 'conv-mock-001',
          seniorId: 'senior-mock-001',
          type: 'welfare_check_morning',
          direction: 'outbound',
          startedAt: DateTime.now().subtract(const Duration(hours: 2)),
          endedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: -1)),
          durationSeconds: 60,
          transcript: [
            TranscriptMessage(role: 'adam', text: 'Dzień dobry Pani Janino! Jak się Pani dzisiaj czuje?', timestamp: '0:00'),
            TranscriptMessage(role: 'senior', text: 'Dobrze, dziękuję. Jaką dziś mamy pogodę?', timestamp: '0:05'),
          ],
          sentimentScore: 0.5,
          moodScore: 4,
          topics: ['pogoda', 'samopoczucie'],
          semaforBefore: 'GREEN',
          semaforAfter: 'GREEN',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Conversation(
          id: 'conv-mock-002',
          seniorId: 'senior-mock-001',
          type: 'senior_initiated',
          direction: 'inbound',
          startedAt: DateTime.now().subtract(const Duration(hours: 5)),
          endedAt: DateTime.now().subtract(const Duration(hours: 5, minutes: -1)),
          durationSeconds: 60,
          transcript: [
            TranscriptMessage(role: 'senior', text: 'Przypomnij mi o lekach o 20:00', timestamp: '0:00'),
            TranscriptMessage(role: 'adam', text: 'Oczywiście! Ustawiłem przypomnienie na 20:00.', timestamp: '0:05'),
          ],
          sentimentScore: 0.3,
          moodScore: 3,
          topics: ['leki', 'przypomnienia'],
          semaforBefore: 'GREEN',
          semaforAfter: 'GREEN',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        Conversation(
          id: 'conv-mock-003',
          seniorId: 'senior-mock-001',
          type: 'emotional_support',
          direction: 'inbound',
          startedAt: DateTime.now().subtract(const Duration(days: 1)),
          endedAt: DateTime.now().subtract(const Duration(days: 1, hours: -1)),
          durationSeconds: 300,
          transcript: [
            TranscriptMessage(role: 'senior', text: 'Trochę się źle czuję dzisiaj...', timestamp: '0:00'),
            TranscriptMessage(role: 'adam', text: 'Przykro mi to słyszeć. Sprawdziłem Pani ostatnie pomiary — ciśnienie jest w normie.', timestamp: '0:05'),
          ],
          sentimentScore: -0.4,
          moodScore: 2,
          topics: ['samopoczucie', 'zdrowie'],
          semaforBefore: 'GREEN',
          semaforAfter: 'GREEN',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  // ─── Weekly Health Summary ─────────────────────────────────────
  static WeeklyHealthSummary get weeklySummary => WeeklyHealthSummary(
        seniorId: 'senior-mock-001',
        weekStart: DateTime.now().subtract(const Duration(days: 7)),
        avgHeartRate: 71.2,
        avgSpo2: 97.5,
        totalSteps: 33600,
        avgSleepHours: 7.1,
        avgSleepScore: 78.0,
        conversationCount: 14,
        avgMoodScore: 4.1,
        alertCount: 0,
        medicationAdherencePercent: 85,
      );
}
