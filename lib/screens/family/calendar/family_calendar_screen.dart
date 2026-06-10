import 'package:flutter/material.dart';
import '../../../mixins/accessibility/accessibility_mixin.dart';

/// Family Calendar Screen
/// Displays senior's appointments, medication schedule, and events
class FamilyCalendarScreen extends StatefulWidget {
  const FamilyCalendarScreen({super.key});

  @override
  State<FamilyCalendarScreen> createState() => _FamilyCalendarScreenState();
}

class _FamilyCalendarScreenState extends State<FamilyCalendarScreen>
    with AccessibilityMixin {
  DateTime _selectedDate = DateTime.now();
  String _filter = 'all'; // all, appointments, medications, events

  final List<CalendarEvent> _events = [
    CalendarEvent(
      id: 'e1',
      title: 'Wizyta u kardiologa',
      date: DateTime.now().add(const Duration(days: 2)),
      time: '11:30',
      type: CalendarEventType.appointment,
      location: 'Centrum Medyczne "Serce", ul. Zdrowa 15',
      notes: 'Zabierz wyniki badań z ostatniego miesiąca',
      doctor: 'Dr Piotr Zalewski',
    ),
    CalendarEvent(
      id: 'e2',
      title: 'Metformina — dawka wieczorna',
      date: DateTime.now(),
      time: '20:00',
      type: CalendarEventType.medication,
      notes: '500mg, po posiłku',
    ),
    CalendarEvent(
      id: 'e3',
      title: 'Spacer z grupą seniora',
      date: DateTime.now().add(const Duration(days: 1)),
      time: '10:00',
      type: CalendarEventType.event,
      location: 'Park Miejski, wejście główne',
    ),
    CalendarEvent(
      id: 'e4',
      title: 'Badania kontrolne krwi',
      date: DateTime.now().add(const Duration(days: 5)),
      time: '08:00',
      type: CalendarEventType.appointment,
      location: 'Laboratorium "MedLab", ul. Diagnostyczna 3',
      notes: 'Na czczo (minimum 8h)',
    ),
    CalendarEvent(
      id: 'e5',
      title: 'Enalapryl — dawka poranna',
      date: DateTime.now(),
      time: '08:00',
      type: CalendarEventType.medication,
      notes: '10mg, przed śniadaniem',
    ),
  ];

  List<CalendarEvent> get _filteredEvents {
    var events = _events.where((e) =>
        e.date.year == _selectedDate.year &&
        e.date.month == _selectedDate.month &&
        e.date.day == _selectedDate.day);

    if (_filter != 'all') {
      events = events.where((e) => e.type.name == _filter);
    }

    return events.toList()..sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Kalendarz', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list, color: Colors.white.withValues(alpha: 0.8)),
            onSelected: (v) => setState(() => _filter = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'all', child: Text('Wszystko')),
              const PopupMenuItem(value: 'appointments', child: Text('Wizyty')),
              const PopupMenuItem(value: 'medications', child: Text('Leki')),
              const PopupMenuItem(value: 'event', child: Text('Wydarzenia')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Date selector
            _buildDateSelector(),
            // Events list
            Expanded(
              child: _filteredEvents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text('Brak wydarzeń', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 18)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredEvents.length,
                      itemBuilder: (context, index) => _buildEventCard(_filteredEvents[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final today = DateTime.now();
    final dates = List.generate(14, (i) => today.add(Duration(days: i - 1)));

    return Container(
      height: 100,
      color: Colors.white.withValues(alpha: 0.05),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = date.day == _selectedDate.day &&
              date.month == _selectedDate.month &&
              date.year == _selectedDate.year;
          final isToday = date.day == today.day &&
              date.month == today.month &&
              date.year == today.year;

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 64,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isToday && !isSelected
                    ? Border.all(color: const Color(0xFF4CAF50), width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayNames[date.weekday - 1],
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    final config = _eventTypeConfig[event.type]!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: config.color.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time column
            Column(
              children: [
                Icon(config.icon, color: config.color, size: 28),
                const SizedBox(height: 4),
                Text(event.time, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                  if (event.location != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.location_on, size: 14, color: Colors.white.withValues(alpha: 0.4)),
                      const SizedBox(width: 4),
                      Expanded(child: Text(event.location!, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5)))),
                    ]),
                  ],
                  if (event.notes != null) ...[
                    const SizedBox(height: 4),
                    Text(event.notes!, style: TextStyle(fontSize: 13, color: config.color.withValues(alpha: 0.8))),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _dayNames = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];

  static const _eventTypeConfig = {
    CalendarEventType.appointment: _EventStyle(Icons.local_hospital, Color(0xFF2196F3)),
    CalendarEventType.medication: _EventStyle(Icons.medication, Color(0xFF4CAF50)),
    CalendarEventType.event: _EventStyle(Icons.event, Color(0xFFFF9800)),
  };
}

class CalendarEvent {
  final String id;
  final String title;
  final DateTime date;
  final String time;
  final CalendarEventType type;
  final String? location;
  final String? notes;
  final String? doctor;

  const CalendarEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.type,
    this.location,
    this.notes,
    this.doctor,
  });
}

enum CalendarEventType { appointment, medication, event }

class _EventStyle {
  final IconData icon;
  final Color color;
  const _EventStyle(this.icon, this.color);
}
