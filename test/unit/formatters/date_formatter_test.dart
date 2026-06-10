import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/utils/formatters/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    group('formatDate', () {
      test('formats date in Polish format', () {
        final date = DateTime(2026, 6, 15);
        final result = DateFormatter.formatDate(date);
        expect(result, '15.06.2026');
      });

      test('pads single-digit days and months', () {
        final date = DateTime(2026, 1, 5);
        final result = DateFormatter.formatDate(date);
        expect(result, '05.01.2026');
      });

      test('handles end-of-year dates', () {
        final date = DateTime(2026, 12, 31);
        final result = DateFormatter.formatDate(date);
        expect(result, '31.12.2026');
      });
    });

    group('formatDateTime', () {
      test('formats with time in 24h format', () {
        final date = DateTime(2026, 6, 15, 14, 30);
        final result = DateFormatter.formatDateTime(date);
        expect(result, contains('14:30'));
      });

      test('includes date in result', () {
        final date = DateTime(2026, 6, 15);
        final result = DateFormatter.formatDateTime(date);
        expect(result, contains('15.06.2026'));
      });
    });

    group('formatRelative', () {
      test('returns relative time for recent dates', () {
        final justNow = DateTime.now().subtract(const Duration(minutes: 5));
        final result = DateFormatter.formatRelative(justNow.toIso8601String());
        expect(result, '5 min temu');
      });

      test('returns hours ago for older today', () {
        final hoursAgo = DateTime.now().subtract(const Duration(hours: 3));
        final result = DateFormatter.formatRelative(hoursAgo.toIso8601String());
        expect(result, contains('h temu'));
      });

      test('returns days ago for recent dates', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        final result = DateFormatter.formatRelative(threeDaysAgo.toIso8601String());
        expect(result, contains('dni temu'));
      });

      test('returns formatted date for older dates', () {
        final oldDate = DateTime.now().subtract(const Duration(days: 30));
        final result = DateFormatter.formatRelative(oldDate.toIso8601String());
        expect(result, contains('.'));
      });
    });

    group('formatTime', () {
      test('formats in 24h HH:MM', () {
        final date = DateTime(2026, 6, 15, 9, 5);
        final result = DateFormatter.formatTime(date);
        expect(result, '09:05');
      });

      test('handles midnight and noon', () {
        expect(DateFormatter.formatTime(DateTime(2026, 6, 15, 0, 0)), '00:00');
        expect(DateFormatter.formatTime(DateTime(2026, 6, 15, 12, 0)), '12:00');
      });
    });

    group('formatDuration', () {
      test('formats minutes only', () {
        final result = DateFormatter.formatDuration(const Duration(minutes: 5));
        expect(result, '5 min');
      });

      test('formats hours and minutes', () {
        final result = DateFormatter.formatDuration(const Duration(hours: 2, minutes: 30));
        expect(result, '2h 30min');
      });

      test('formats hours only', () {
        final result = DateFormatter.formatDuration(const Duration(hours: 3));
        expect(result, '3h');
      });

      test('formats seconds', () {
        final result = DateFormatter.formatDuration(const Duration(seconds: 45));
        expect(result, '45s');
      });
    });

    group('isToday', () {
      test('returns true for today', () {
        expect(DateFormatter.isToday(DateTime.now()), true);
      });

      test('returns false for yesterday', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        expect(DateFormatter.isToday(yesterday), false);
      });
    });

    group('getWeekDay', () {
      test('returns Polish day names', () {
        // 2026-06-15 is Monday
        expect(DateFormatter.getWeekDay(DateTime(2026, 6, 15)), 'Poniedziałek');
        expect(DateFormatter.getWeekDay(DateTime(2026, 6, 16)), 'Wtorek');
        expect(DateFormatter.getWeekDay(DateTime(2026, 6, 17)), 'Środa');
        expect(DateFormatter.getWeekDay(DateTime(2026, 6, 18)), 'Czwartek');
        expect(DateFormatter.getWeekDay(DateTime(2026, 6, 19)), 'Piątek');
        expect(DateFormatter.getWeekDay(DateTime(2026, 6, 20)), 'Sobota');
        expect(DateFormatter.getWeekDay(DateTime(2026, 6, 21)), 'Niedziela');
      });
    });
  });
}
