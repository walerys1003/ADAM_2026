import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/utils/validators/senior_validator.dart';

void main() {
  group('SeniorValidator', () {
    group('validatePhone', () {
      test('accepts valid Polish phone numbers', () {
        expect(SeniorValidator.validatePhone('+48 601 234 567'), isNull);
        expect(SeniorValidator.validatePhone('601234567'), isNull);
        expect(SeniorValidator.validatePhone('+48601234567'), isNull);
        expect(SeniorValidator.validatePhone('12 345 67 89'), isNull);
      });

      test('accepts +48 prefix format', () {
        expect(SeniorValidator.validatePhone('+48123456789'), isNull);
        expect(SeniorValidator.validatePhone('+48 123 456 789'), isNull);
      });

      test('rejects invalid phone numbers', () {
        expect(SeniorValidator.validatePhone(''), isNotNull);
        expect(SeniorValidator.validatePhone('abc'), isNotNull);
        expect(SeniorValidator.validatePhone('123'), isNotNull);
      });

      test('rejects too short numbers', () {
        expect(SeniorValidator.validatePhone('12345'), isNotNull);
      });
    });

    group('validateEmail', () {
      test('accepts valid emails', () {
        expect(SeniorValidator.validateEmail('test@example.com'), isNull);
        expect(SeniorValidator.validateEmail('jan.kowalski@domena.pl'), isNull);
      });

      test('rejects invalid emails', () {
        expect(SeniorValidator.validateEmail(''), isNotNull);
        expect(SeniorValidator.validateEmail('not-an-email'), isNotNull);
        expect(SeniorValidator.validateEmail('@example.com'), isNotNull);
      });
    });

    group('validatePassword', () {
      test('accepts strong passwords', () {
        expect(SeniorValidator.validatePassword('StrongP@ss1'), isNull);
        expect(SeniorValidator.validatePassword('C0mplex!Pass'), isNull);
      });

      test('rejects weak passwords', () {
        expect(SeniorValidator.validatePassword(''), isNotNull);
        expect(SeniorValidator.validatePassword('123'), isNotNull);
        expect(SeniorValidator.validatePassword('abcdefgh'), isNotNull);
      });

      test('rejects passwords without digits/special chars', () {
        expect(SeniorValidator.validatePassword('abcdefghij'), isNotNull);
        expect(SeniorValidator.validatePassword('ABCDEFGHIJ'), isNotNull);
      });
    });

    group('validateAge', () {
      test('accepts valid ages', () {
        expect(SeniorValidator.validateAge('65'), isNull);
        expect(SeniorValidator.validateAge('80'), isNull);
        expect(SeniorValidator.validateAge('100'), isNull);
      });

      test('rejects too young seniors', () {
        expect(SeniorValidator.validateAge('17'), isNotNull);
        expect(SeniorValidator.validateAge('59'), isNotNull);
      });

      test('rejects invalid inputs', () {
        expect(SeniorValidator.validateAge('abc'), isNotNull);
        expect(SeniorValidator.validateAge('-5'), isNotNull);
      });
    });

    group('validateRequired', () {
      test('returns error for empty strings', () {
        expect(SeniorValidator.validateRequired('', 'Imię'), isNotNull);
        expect(SeniorValidator.validateRequired('   ', 'Imię'), isNotNull);
      });

      test('returns null for non-empty strings', () {
        expect(SeniorValidator.validateRequired('Jan', 'Imię'), isNull);
      });
    });

    group('validateSemaforLevel', () {
      test('accepts valid levels', () {
        for (final level in ['GREEN', 'YELLOW', 'ORANGE', 'RED', 'PURPLE']) {
          expect(SeniorValidator.validateSemaforLevel(level), isNull);
        }
      });

      test('rejects invalid levels', () {
        expect(SeniorValidator.validateSemaforLevel('BLUE'), isNotNull);
        expect(SeniorValidator.validateSemaforLevel(''), isNotNull);
      });
    });
  });
}
