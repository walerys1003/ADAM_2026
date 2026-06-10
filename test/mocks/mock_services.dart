import 'package:flutter/foundation.dart';
import '../mocks/mock_data.dart';

/// Mock service implementations for testing
/// These replace real services during widget and integration tests

/// Mock Supabase service — returns mock data without network calls
class MockSupabaseService {
  final Map<String, dynamic> _store = {};

  Future<Map<String, dynamic>?> getSeniorProfile(String seniorId) async {
    final senior = MockData.allSeniors.firstWhere(
      (s) => s.id == seniorId,
      orElse: () => MockData.seniorJanina,
    );
    return senior.toJson();
  }

  Future<List<Map<String, dynamic>>> getHealthRecords(
      String seniorId, {int limit = 200}) async {
    return [
      MockData.normalHealthData.toJson(),
      MockData.elevatedHealthData.toJson(),
    ];
  }

  Future<List<Map<String, dynamic>>> getMedications(String seniorId) async {
    return MockData.allMedications.where((m) => m.seniorId == seniorId).map((m) => m.toJson()).toList();
  }

  Future<List<Map<String, dynamic>>> getConversations(String seniorId,
      {int limit = 50}) async {
    return MockData.sampleConversations
        .where((c) => c.seniorId == seniorId)
        .map((c) => c.toJson())
        .toList();
  }

  Future<List<Map<String, dynamic>>> getConsentRecords(String seniorId) async {
    return [
      {
        'type': 'voice_recording',
        'granted': true,
        'granted_at': '2026-06-01T00:00:00.000Z',
      },
      {
        'type': 'health_data',
        'granted': true,
        'granted_at': '2026-06-01T00:00:00.000Z',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> getAppointments(String seniorId,
      {int limit = 100}) async {
    return [
      {
        'doctor': 'Dr Maria Wiśniewska',
        'date': '2026-06-25T11:30:00.000Z',
        'type': 'Kardiolog',
        'location': 'Centrum Medyczne "Serce"',
      },
    ];
  }
}

/// Mock voice call service — simulates voice call without real APIs
class MockVoiceCallService extends ChangeNotifier {
  bool _isCallActive = false;
  String _currentTranscript = '';
  String _adamResponse = '';

  bool get isCallActive => _isCallActive;
  String get currentTranscript => _currentTranscript;
  String get adamResponse => _adamResponse;

  Future<void> startCall() async {
    _isCallActive = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _adamResponse = 'Dzień dobry! Jak mogę pomóc?';
    notifyListeners();
  }

  Future<void> endCall() async {
    _isCallActive = false;
    _currentTranscript = '';
    _adamResponse = '';
    notifyListeners();
  }

  void simulateTranscript(String text) {
    _currentTranscript = text;
    notifyListeners();
  }

  void simulateAdamResponse(String response) {
    _adamResponse = response;
    notifyListeners();
  }
}

/// Mock notification service
class MockNotificationService {
  bool _medicationsEnabled = true;
  bool _healthAlertsEnabled = true;

  bool get medicationsEnabled => _medicationsEnabled;
  bool get healthAlertsEnabled => _healthAlertsEnabled;

  Future<void> scheduleMedicationReminder(
      String medicationName, DateTime time) async {
    if (kDebugMode) {
      debugPrint('Mock: Scheduled reminder for $medicationName at $time');
    }
  }

  Future<void> sendHealthAlert(String title, String message) async {
    if (kDebugMode) {
      debugPrint('Mock: Send health alert: $title - $message');
    }
  }
}
