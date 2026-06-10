import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/providers/app_provider.dart';
import 'package:senior_companion/models/senior.dart';

void main() {
  group('AppProvider', () {
    late AppProvider provider;

    setUp(() {
      provider = AppProvider();
    });

    test('initial state has correct defaults', () {
      expect(provider.currentSenior, isNull);
      expect(provider.seniors, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.currentThemeMode, 'senior');
      expect(provider.currentLocale, 'pl');
      expect(provider.isAuthenticated, false);
    });

    test('setCurrentSenior updates the senior', () {
      final senior = Senior(
        id: 'test-1',
        firstName: 'Jan',
        lastName: 'Kowalski',
        phone: '+48 600 000 000',
        dateOfBirth: DateTime(1950, 1, 1),
        semaforLevel: 'GREEN',
        package: 'KONTAKT',
        onboardingCompleted: true,
        voiceRecordingConsent: true,
        healthDataConsent: true,
        familySharingConsent: true,
      );

      provider.setCurrentSenior(senior);
      expect(provider.currentSenior?.id, 'test-1');
      expect(provider.currentSenior?.fullName, 'Jan Kowalski');
    });

    test('setSeniors updates the list', () {
      final seniors = [
        Senior(
          id: 's1',
          firstName: 'A',
          lastName: 'B',
          phone: '+48 600 000 001',
          dateOfBirth: DateTime(1950, 1, 1),
          semaforLevel: 'GREEN',
          package: 'KONTAKT',
          onboardingCompleted: true,
          voiceRecordingConsent: true,
          healthDataConsent: true,
          familySharingConsent: true,
        ),
        Senior(
          id: 's2',
          firstName: 'C',
          lastName: 'D',
          phone: '+48 600 000 002',
          dateOfBirth: DateTime(1955, 2, 2),
          semaforLevel: 'YELLOW',
          package: 'ZDROWIE',
          onboardingCompleted: true,
          voiceRecordingConsent: true,
          healthDataConsent: true,
          familySharingConsent: true,
        ),
      ];

      provider.setSeniors(seniors);
      expect(provider.seniors.length, 2);
    });

    test('setLoading toggles loading state', () {
      provider.setLoading(true);
      expect(provider.isLoading, true);

      provider.setLoading(false);
      expect(provider.isLoading, false);
    });

    test('setThemeMode updates theme preference', () {
      provider.setThemeMode('admin');
      expect(provider.currentThemeMode, 'admin');

      provider.setThemeMode('senior');
      expect(provider.currentThemeMode, 'senior');
    });

    test('login sets authenticated state', () {
      provider.login();
      expect(provider.isAuthenticated, true);
    });

    test('logout clears state', () {
      provider.login();
      final senior = Senior(
        id: 'test-1',
        firstName: 'X',
        lastName: 'Y',
        phone: '+48 600 000 000',
        dateOfBirth: DateTime(1950, 1, 1),
        semaforLevel: 'GREEN',
        package: 'KONTAKT',
        onboardingCompleted: true,
        voiceRecordingConsent: true,
        healthDataConsent: true,
        familySharingConsent: true,
      );
      provider.setCurrentSenior(senior);

      provider.logout();

      expect(provider.isAuthenticated, false);
      expect(provider.currentSenior, isNull);
    });

    test('semaforLevel getter returns GREEN when no senior', () {
      expect(provider.semaforLevel, 'GREEN');
    });

    test('semaforLevel getter returns senior level', () {
      final senior = Senior(
        id: 'test-1',
        firstName: 'X',
        lastName: 'Y',
        phone: '+48 600 000 000',
        dateOfBirth: DateTime(1950, 1, 1),
        semaforLevel: 'ORANGE',
        package: 'KONTAKT',
        onboardingCompleted: true,
        voiceRecordingConsent: true,
        healthDataConsent: true,
        familySharingConsent: true,
      );
      provider.setCurrentSenior(senior);

      expect(provider.semaforLevel, 'ORANGE');
    });

    test('notifyListeners is called on state changes', () {
      var callCount = 0;
      provider.addListener(() => callCount++);

      provider.setLoading(true);
      expect(callCount, 1);

      provider.setLoading(false);
      expect(callCount, 2);
    });
  });
}
