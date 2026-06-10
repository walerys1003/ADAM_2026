import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/providers/app_provider.dart';
import 'package:senior_companion/models/senior.dart';

void main() {
  group('AppProvider', () {
    late AppProvider provider;

    setUp(() {
      provider = AppProvider();
    });

    Senior _testSenior({String id = 'test-1', String semafor = 'GREEN'}) => Senior(
          id: id,
          firstName: 'Test',
          lastName: 'User',
          phone: '+48 600 000 000',
          package: 'KONTAKT',
          semafor: semafor,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    test('initial state has correct defaults', () {
      expect(provider.currentSenior, isNull);
      expect(provider.seniors, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.currentThemeMode, 'admin');
      expect(provider.currentLocale, 'pl');
      expect(provider.isAuthenticated, false);
    });

    test('setCurrentSenior updates the senior', () async {
      final senior = _testSenior();
      await provider.setCurrentSenior(senior);
      expect(provider.currentSenior?.id, 'test-1');
      expect(provider.currentSenior?.fullName, 'Test User');
    });

    test('setSeniors updates the list', () {
      final seniors = [
        _testSenior(id: 's1'),
        _testSenior(id: 's2', semafor: 'YELLOW'),
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
      provider.setCurrentSenior(_testSenior());

      provider.logout();

      expect(provider.isAuthenticated, false);
      expect(provider.currentSenior, isNull);
    });

    test('semaforLevel getter returns GREEN when no senior', () {
      expect(provider.semaforLevel, 'GREEN');
    });

    test('semaforLevel getter returns senior level', () async {
      final senior = _testSenior(semafor: 'ORANGE');
      await provider.setCurrentSenior(senior);

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
