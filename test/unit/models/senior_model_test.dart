import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/models/senior.dart';

void main() {
  group('Senior', () {
    final sampleJson = {
      'id': 'senior-001',
      'first_name': 'Janina',
      'last_name': 'Kowalska',
      'phone': '+48 601 111 222',
      'email': 'janina.k@example.pl',
      'date_of_birth': '1948-03-15T00:00:00.000Z',
      'address': 'ul. Słoneczna 12/4, 00-001 Warszawa',
      'blood_type': 'A+',
      'chronic_conditions': ['nadciśnienie', 'cukrzyca typu 2'],
      'allergies': ['penicylina'],
      'emergency_contact': '+48 601 333 444',
      'emergency_contact_name': 'Tomasz Kowalski (syn)',
      'semafor': 'GREEN',
      'package': 'AKTYWNY',
      'avatar_url': null,
      'created_at': '2026-06-01T00:00:00.000Z',
      'updated_at': '2026-06-15T00:00:00.000Z',
    };

    test('fromJson creates valid Senior object', () {
      final senior = Senior.fromJson(sampleJson);

      expect(senior.id, 'senior-001');
      expect(senior.firstName, 'Janina');
      expect(senior.lastName, 'Kowalska');
      expect(senior.phone, '+48 601 111 222');
      expect(senior.email, 'janina.k@example.pl');
      expect(senior.bloodType, 'A+');
      expect(senior.chronicConditions.length, 2);
      expect(senior.allergies!.length, 1);
      expect(senior.semaforLevel, 'GREEN');
      expect(senior.package, 'AKTYWNY');
      expect(senior.onboardingCompleted, false);
      expect(senior.voiceRecordingConsent, true);
      expect(senior.healthDataConsent, true);
      expect(senior.familySharingConsent, true);
    });

    test('toJson produces correct JSON map', () {
      final senior = Senior.fromJson(sampleJson);
      final json = senior.toJson();

      expect(json['id'], 'senior-001');
      expect(json['first_name'], 'Janina');
      expect(json['last_name'], 'Kowalska');
      expect(json['semafor'], 'GREEN');
    });

    test('fullName property returns correct value', () {
      final senior = Senior.fromJson(sampleJson);
      expect(senior.fullName, 'Janina Kowalska');
    });

    test('age calculates correctly from dateOfBirth', () {
      final senior = Senior.fromJson(sampleJson);
      // Born 1948, should be ~78 in 2026
      expect(senior.age, isPositive);
      expect(senior.age, greaterThan(70));
    });

    test('isSemaforCritical returns true for RED and PURPLE', () {
      final greenSenior = Senior.fromJson(sampleJson);
      expect(greenSenior.isSemaforCritical, false);

      final redJson = Map<String, dynamic>.from(sampleJson)
        ..['semafor'] = 'RED';
      expect(Senior.fromJson(redJson).isSemaforCritical, true);

      final purpleJson = Map<String, dynamic>.from(sampleJson)
        ..['semafor'] = 'PURPLE';
      expect(Senior.fromJson(purpleJson).isSemaforCritical, true);
    });

    test('handles null optional fields', () {
      final minimalJson = {
        'id': 'senior-minimal',
        'first_name': 'Test',
        'last_name': 'User',
        'phone': '+48 000 000 000',
        'date_of_birth': '1950-01-01T00:00:00.000Z',
        'semafor': 'GREEN',
        'package': 'KONTAKT',
      };

      final senior = Senior.fromJson(minimalJson);
      expect(senior.email, isNull);
      expect(senior.bloodType, isNull);
      expect(senior.avatarUrl, isNull);
      expect(senior.allergies, isNull);
      expect(senior.chronicConditions, isEmpty);
    });

    test('copyWith creates modified copy', () {
      final senior = Senior.fromJson(sampleJson);
      final modified = senior.copyWith(
        firstName: 'Krystyna',
        semafor: 'YELLOW',
      );

      expect(modified.firstName, 'Krystyna');
      expect(modified.lastName, 'Kowalska'); // unchanged
      expect(modified.semafor, 'YELLOW');
      expect(modified.id, senior.id); // unchanged
    });
  });
}
