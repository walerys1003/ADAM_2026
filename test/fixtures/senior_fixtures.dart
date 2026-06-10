import 'dart:convert';

/// Test fixtures for Senior model testing.
/// Provides JSON strings and parsed maps representing various
/// senior profile scenarios for consistent test data.
class SeniorFixtures {
  SeniorFixtures._();

  /// Standard senior profile — healthy, basic package
  static const String standardSeniorJson = '''
  {
    "id": "senior-001",
    "email": "jan.kowalski@example.com",
    "firstName": "Jan",
    "lastName": "Kowalski",
    "phone": "+48123456789",
    "dateOfBirth": "1952-03-15",
    "gender": "MALE",
    "address": "ul. Marszałkowska 1, 00-001 Warszawa",
    "emergencyContact": {
      "name": "Anna Kowalska",
      "phone": "+48987654321",
      "relationship": "Córka"
    },
    "package": "ZDROWIE",
    "semaforLevel": "GREEN",
    "healthScore": 0.92,
    "isActive": true,
    "consents": {
      "rodo": true,
      "healthDataProcessing": true,
      "voiceRecording": true,
      "dataSharing": true
    },
    "linkedFamilyIds": ["family-001"],
    "createdAt": "2025-01-15T10:30:00Z",
    "updatedAt": "2025-06-01T08:00:00Z"
  }
  ''';

  /// Senior with elevated semafor — health concerns
  static const String semaforOrangeSeniorJson = '''
  {
    "id": "senior-002",
    "email": "maria.nowak@example.com",
    "firstName": "Maria",
    "lastName": "Nowak",
    "phone": "+48333555666",
    "dateOfBirth": "1948-07-22",
    "gender": "FEMALE",
    "address": "ul. Długa 15/7, 31-001 Kraków",
    "emergencyContact": {
      "name": "Piotr Nowak",
      "phone": "+48777888999",
      "relationship": "Syn"
    },
    "package": "AKTYWNY",
    "semaforLevel": "ORANGE",
    "healthScore": 0.55,
    "isActive": true,
    "consents": {
      "rodo": true,
      "healthDataProcessing": true,
      "voiceRecording": true,
      "dataSharing": false
    },
    "linkedFamilyIds": ["family-002", "family-003"],
    "createdAt": "2024-11-03T14:00:00Z",
    "updatedAt": "2025-06-02T16:30:00Z"
  }
  ''';

  /// Senior with RED semafor — critical alert
  static const String semaforRedSeniorJson = '''
  {
    "id": "senior-003",
    "email": "zbigniew.wisniewski@example.com",
    "firstName": "Zbigniew",
    "lastName": "Wiśniewski",
    "phone": "+48666999888",
    "dateOfBirth": "1942-12-01",
    "gender": "MALE",
    "address": "ul. Leśna 3, 50-001 Wrocław",
    "emergencyContact": {
      "name": "Katarzyna Wiśniewska",
      "phone": "+48555666777",
      "relationship": "Żona"
    },
    "package": "ZDROWIE",
    "semaforLevel": "RED",
    "healthScore": 0.31,
    "isActive": true,
    "consents": {
      "rodo": true,
      "healthDataProcessing": true,
      "voiceRecording": true,
      "dataSharing": true
    },
    "linkedFamilyIds": ["family-004"],
    "createdAt": "2024-06-10T09:00:00Z",
    "updatedAt": "2025-06-02T18:45:00Z"
  }
  ''';

  /// New senior — minimal profile, onboarding not complete
  static const String newSeniorJson = '''
  {
    "id": "senior-004",
    "email": "alicja.dabrowska@example.com",
    "firstName": "Alicja",
    "lastName": "Dąbrowska",
    "phone": "+48444999888",
    "dateOfBirth": "1955-05-10",
    "gender": "FEMALE",
    "package": "KONTAKT",
    "semaforLevel": "GREEN",
    "healthScore": 1.0,
    "isActive": false,
    "consents": {
      "rodo": false,
      "healthDataProcessing": false,
      "voiceRecording": false,
      "dataSharing": false
    },
    "linkedFamilyIds": [],
    "createdAt": "2025-06-03T07:00:00Z",
    "updatedAt": "2025-06-03T07:00:00Z"
  }
  ''';

  /// List of all senior fixture JSONs
  static List<String> get allSeniorJsons => [
    standardSeniorJson,
    semaforOrangeSeniorJson,
    semaforRedSeniorJson,
    newSeniorJson,
  ];

  /// Parse a fixture JSON string to Map
  static Map<String, dynamic> parse(String json) {
    return jsonDecode(json) as Map<String, dynamic>;
  }

  /// Get all seniors as parsed Maps
  static List<Map<String, dynamic>> get allSeniors =>
      allSeniorJsons.map(parse).toList();
}

/// Test fixtures for HealthData model testing.
class HealthDataFixtures {
  HealthDataFixtures._();

  static const String normalHealthJson = '''
  {
    "id": "health-001",
    "seniorId": "senior-001",
    "heartRate": 72,
    "bloodPressureSystolic": 125,
    "bloodPressureDiastolic": 82,
    "bloodOxygen": 97,
    "steps": 4500,
    "sleepHours": 7.5,
    "sleepQuality": "GOOD",
    "temperature": 36.6,
    "weight": 78.5,
    "recordedAt": "2025-06-03T08:00:00Z",
    "source": "XIAOMI_BAND_9"
  }
  ''';

  static const String elevatedHeartRateJson = '''
  {
    "id": "health-002",
    "seniorId": "senior-002",
    "heartRate": 115,
    "bloodPressureSystolic": 148,
    "bloodPressureDiastolic": 92,
    "bloodOxygen": 94,
    "steps": 1200,
    "sleepHours": 4.2,
    "sleepQuality": "POOR",
    "temperature": 37.2,
    "weight": 65.0,
    "recordedAt": "2025-06-03T08:00:00Z",
    "source": "XIAOMI_BAND_9"
  }
  ''';

  static const String criticalHealthJson = '''
  {
    "id": "health-003",
    "seniorId": "senior-003",
    "heartRate": 38,
    "bloodPressureSystolic": 170,
    "bloodPressureDiastolic": 105,
    "bloodOxygen": 88,
    "steps": 200,
    "sleepHours": 3.0,
    "sleepQuality": "VERY_POOR",
    "temperature": 38.5,
    "weight": 72.0,
    "recordedAt": "2025-06-03T08:00:00Z",
    "source": "MANUAL"
  }
  ''';

  static List<String> get allHealthJsons => [
    normalHealthJson,
    elevatedHeartRateJson,
    criticalHealthJson,
  ];

  static List<Map<String, dynamic>> get allHealthData =>
      allHealthJsons.map((j) => jsonDecode(j) as Map<String, dynamic>).toList();
}

/// Test fixtures for Medication model testing.
class MedicationFixtures {
  MedicationFixtures._();

  static const String standardMedicationJson = '''
  {
    "id": "med-001",
    "seniorId": "senior-001",
    "name": "Aspiryna",
    "dosage": "100mg",
    "frequency": "Raz dziennie",
    "timeOfDay": ["MORNING"],
    "reminderTime": "2025-06-03T08:00:00Z",
    "instructions": "Przyjmować po posiłku, popić dużą ilością wody",
    "prescribingDoctor": "Dr n. med. Anna Lewandowska",
    "startDate": "2025-01-01",
    "endDate": null,
    "refillsRemaining": 3,
    "isActive": true,
    "adherenceRate": 0.95,
    "createdAt": "2025-01-01T00:00:00Z"
  }
  ''';

  static const String missedMedicationJson = '''
  {
    "id": "med-002",
    "seniorId": "senior-002",
    "name": "Metformina",
    "dosage": "500mg",
    "frequency": "Dwa razy dziennie",
    "timeOfDay": ["MORNING", "EVENING"],
    "reminderTime": "2025-06-03T20:00:00Z",
    "instructions": "Przyjmować z posiłkiem",
    "prescribingDoctor": "Dr n. med. Tomasz Zieliński",
    "startDate": "2024-06-15",
    "endDate": null,
    "refillsRemaining": 1,
    "isActive": true,
    "adherenceRate": 0.45,
    "createdAt": "2024-06-15T00:00:00Z"
  }
  ''';

  static List<String> get allMedicationJsons => [
    standardMedicationJson,
    missedMedicationJson,
  ];

  static List<Map<String, dynamic>> get allMedications =>
      allMedicationJsons.map((j) => jsonDecode(j) as Map<String, dynamic>).toList();
}

/// Test fixtures for conversation model testing.
class ConversationFixtures {
  ConversationFixtures._();

  static const String shortConversationJson = '''
  {
    "id": "conv-001",
    "seniorId": "senior-001",
    "startedAt": "2025-06-03T10:00:00Z",
    "endedAt": "2025-06-03T10:02:30Z",
    "durationSeconds": 150,
    "transcript": "Senior: Dzień dobry Adamie.\\nAdam: Dzień dobry Panie Janie! Jak się Pan dziś czuje?\\nSenior: Dobrze, dziękuję. Przypomnij mi o lekach.\\nAdam: Oczywiście! Aspiryna o 8:00 została już przyjęta. Następna dawka jutro rano.",
    "topics": ["przywitanie", "zdrowie", "leki"],
    "mood": "DOBRY",
    "semaforLevel": "GREEN",
    "voiceCost": 0.0045,
    "ragDocumentsUsed": ["aspirin_info"],
    "ttsDurationMs": 3200
  }
  ''';

  static const String emergencyConversationJson = '''
  {
    "id": "conv-002",
    "seniorId": "senior-003",
    "startedAt": "2025-06-03T18:40:00Z",
    "endedAt": "2025-06-03T18:44:15Z",
    "durationSeconds": 255,
    "transcript": "Senior: Adam, źle się czuję...\\nAdam: Rozumiem, Panie Zbigniewie. Proszę mi powiedzieć co się dzieje.\\nSenior: Kręci mi się w głowie i boli klatka.\\nAdam: Już sprawdzam Pana parametry. Widzę podwyższone ciśnienie 170/105. Czy ma Pan ochotę, żebyśmy wezwali pomoc?",
    "topics": ["zdrowie", "zagrożenie", "pomoc"],
    "mood": "BARDZO_ZLY",
    "semaforLevel": "RED",
    "voiceCost": 0.0082,
    "ragDocumentsUsed": ["emergency_protocol", "heart_attack_symptoms"],
    "ttsDurationMs": 5800,
    "alertTriggered": true,
    "alertType": "EMERGENCY"
  }
  ''';

  static List<String> get allConversationJsons => [
    shortConversationJson,
    emergencyConversationJson,
  ];

  static List<Map<String, dynamic>> get allConversations =>
      allConversationJsons.map((j) => jsonDecode(j) as Map<String, dynamic>).toList();
}
