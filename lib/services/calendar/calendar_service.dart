import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Calendar event types
enum CalendarEventType {
  doctorVisit,
  medication,
  familyVisit,
  serviceBooking,
  birthday,
  reminder,
}

/// Calendar event model
class CalendarEvent {
  final String id;
  final String title;
  final String? description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final CalendarEventType type;
  final bool isAllDay;
  final String? seniorId;
  final String? contactName;
  final String? contactPhone;

  const CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    this.type = CalendarEventType.reminder,
    this.isAllDay = false,
    this.seniorId,
    this.contactName,
    this.contactPhone,
  });

  Color get typeColor {
    switch (type) {
      case CalendarEventType.doctorVisit: return const Color(0xFFFF6B6B);
      case CalendarEventType.medication: return const Color(0xFF4ECDC4);
      case CalendarEventType.familyVisit: return const Color(0xFF45B7D1);
      case CalendarEventType.serviceBooking: return const Color(0xFFFFD93D);
      case CalendarEventType.birthday: return const Color(0xFF96CEB4);
      case CalendarEventType.reminder: return const Color(0xFF6C5CE7);
    }
  }

  String get formattedTime {
    if (isAllDay) return 'Cały dzień';
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = startTime.difference(now).inDays;

    if (diff == 0) return 'Dziś';
    if (diff == 1) return 'Jutro';
    if (diff > 1 && diff < 7) return 'Za $diff dni';
    return '${startTime.day}.${startTime.month}.${startTime.year}';
  }
}

class CalendarService extends ChangeNotifier {
  List<CalendarEvent> _events = [];
  List<CalendarEvent> _upcomingEvents = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Getters
  List<CalendarEvent> get events => List.unmodifiable(_events);
  List<CalendarEvent> get upcomingEvents => List.unmodifiable(_upcomingEvents);
  DateTime get selectedDate => _selectedDate;

  /// Load events from backend
  Future<void> loadEvents() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    _events = [
      CalendarEvent(
        id: 'e1',
        title: 'Wizyta u dr Kowalskiego',
        description: 'Kontrolna wizyta kardiologiczna',
        location: 'Przychodnia Rejonowa, ul. Zdrowa 12',
        startTime: now.add(const Duration(days: 3, hours: 2)),
        endTime: now.add(const Duration(days: 3, hours: 3)),
        type: CalendarEventType.doctorVisit,
        contactName: 'Dr Kowalski',
        contactPhone: '+48 123 456 789',
      ),
      CalendarEvent(
        id: 'e2',
        title: 'Fizjoterapeuta — wizyta domowa',
        location: 'Dom seniora',
        startTime: now.add(const Duration(days: 5, hours: 4)),
        endTime: now.add(const Duration(days: 5, hours: 5)),
        type: CalendarEventType.serviceBooking,
        contactName: 'mgr Anna Nowak',
        contactPhone: '+48 987 654 321',
      ),
      CalendarEvent(
        id: 'e3',
        title: 'Urodziny wnuczki Zosi',
        startTime: DateTime(now.year, now.month + 1, 15),
        endTime: DateTime(now.year, now.month + 1, 15, 23, 59),
        type: CalendarEventType.birthday,
        isAllDay: true,
      ),
      CalendarEvent(
        id: 'e4',
        title: 'Wizyta córki — Anna',
        startTime: now.add(const Duration(days: 1, hours: 8)),
        endTime: now.add(const Duration(days: 1, hours: 10)),
        type: CalendarEventType.familyVisit,
        contactName: 'Anna Kowalska',
        contactPhone: '+48 555 111 222',
      ),
      CalendarEvent(
        id: 'e5',
        title: 'Badanie krwi (na czczo!)',
        description: 'Morfologia + lipidogram',
        location: 'Laboratorium Medyczne, ul. Biała 5',
        startTime: now.add(const Duration(days: 7)),
        endTime: now.add(const Duration(days: 7, hours: 1)),
        type: CalendarEventType.doctorVisit,
      ),
      CalendarEvent(
        id: 'e6',
        title: 'Przypomnienie: zamówić leki',
        startTime: now.add(const Duration(days: 10)),
        endTime: now.add(const Duration(days: 10, hours: 1)),
        type: CalendarEventType.reminder,
      ),
    ];

    _upcomingEvents = _events
        .where((e) => e.startTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    _isLoading = false;
    notifyListeners();
  }

  /// Get events for a specific date
  List<CalendarEvent> getEventsForDay(DateTime date) {
    return _events.where((e) {
      return e.startTime.year == date.year &&
          e.startTime.month == date.month &&
          e.startTime.day == date.day;
    }).toList();
  }

  /// Get events for a specific month
  Map<int, List<CalendarEvent>> getEventsForMonth(DateTime date) {
    final map = <int, List<CalendarEvent>>{};
    for (final event in _events) {
      if (event.startTime.year == date.year && event.startTime.month == date.month) {
        map.putIfAbsent(event.startTime.day, () => []).add(event);
      }
    }
    return map;
  }

  /// Check if a date has events
  bool hasEvents(DateTime date) {
    return _events.any((e) =>
        e.startTime.year == date.year &&
        e.startTime.month == date.month &&
        e.startTime.day == date.day);
  }

  /// Add event to Android calendar via Intent
  Future<void> addToDeviceCalendar(CalendarEvent event) async {
    // In production: use url_launcher or platform channel
    // final uri = Uri.parse(
    //   'content://com.android.calendar/events?' +
    //   'title=${Uri.encodeComponent(event.title)}&' +
    //   'begin=${event.startTime.millisecondsSinceEpoch}&' +
    //   'end=${event.endTime.millisecondsSinceEpoch}'
    // );
    if (kDebugMode) {
      debugPrint('Calendar: Added event "${event.title}" to device calendar');
    }
  }

  /// Get today's events sorted
  List<CalendarEvent> get todayEvents => getEventsForDay(DateTime.now());

  /// Get this week's events
  List<CalendarEvent> get weekEvents {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    return _events.where((e) =>
        e.startTime.isAfter(weekStart) && e.startTime.isBefore(weekEnd)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  @override
  void dispose() {
    _events.clear();
    _upcomingEvents.clear();
    super.dispose();
  }
}
