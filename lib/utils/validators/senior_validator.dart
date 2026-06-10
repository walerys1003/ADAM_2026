/// Validators for senior data, phone numbers, medical fields
class SeniorValidator {
  SeniorValidator._();

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Numer telefonu jest wymagany';
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^\+48\d{9}$').hasMatch(cleaned) && !RegExp(r'^\d{9}$').hasMatch(cleaned)) {
      return 'Nieprawidłowy format. Podaj +48 XXX XXX XXX';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Imię jest wymagane';
    if (value.trim().length < 2) return 'Imię musi mieć co najmniej 2 znaki';
    if (!RegExp(r'^[a-zA-ZąćęłńóśźżĄĆĘŁŃÓŚŹŻ\s\-]+$').hasMatch(value)) return 'Niedozwolone znaki';
    return null;
  }

  static String? pesel(String? value) {
    if (value == null || value.isEmpty) return null; // optional
    if (!RegExp(r'^\d{11}$').hasMatch(value)) return 'PESEL musi mieć 11 cyfr';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^[\w\.\-]+@[\w\.\-]+\.\w+$').hasMatch(value)) return 'Nieprawidłowy email';
    return null;
  }

  static String? birthDate(DateTime? value) {
    if (value == null) return null;
    if (value.isAfter(DateTime.now())) return 'Data nie może być w przyszłości';
    if (DateTime.now().difference(value).inDays / 365 > 120) return 'Wiek nie może przekraczać 120 lat';
    return null;
  }

  static String? medicalField(String? value) {
    if (value != null && value.length > 500) return 'Maksymalnie 500 znaków';
    return null;
  }

  static String? crisisLevel(String? value) {
    const valid = ['GREEN', 'YELLOW', 'ORANGE', 'RED', 'PURPLE'];
    if (value != null && !valid.contains(value)) return 'Nieprawidłowy poziom';
    return null;
  }

  // ── Test-facing aliases (backward compat) ──
  static String? validatePhone(String? value) => phone(value);
  static String? validateEmail(String? value) => email(value);
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Hasło jest wymagane';
    if (value.length < 8) return 'Hasło musi mieć minimum 8 znaków';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Hasło musi zawierać cyfrę';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) return 'Hasło musi zawierać znak specjalny';
    return null;
  }
  static String? validateAge(dynamic value) {
    if (value is DateTime) return birthDate(value);
    if (value is String) {
      final age = int.tryParse(value);
      if (age == null) return 'Nieprawidłowy format';
      if (age < 60) return 'Senior musi mieć co najmniej 60 lat';
      if (age > 120) return 'Wiek nie może przekraczać 120 lat';
      return null;
    }
    return 'Nieprawidłowy format';
  }
  static String? validateRequired(String? value, [String? label]) => value == null || value.trim().isEmpty ? '${label ?? 'To pole'} jest wymagane' : null;
  static String? validateSemaforLevel(String? value) => crisisLevel(value);
}
