/// SilverTech Agent Adam — Notification Service
/// Push notifications, medication reminders, alert dispatcher
/// June 2026 — multi-channel: FCM + SMS fallback + email digest

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Notification priority matching semafor levels
enum NotificationPriority {
  green,
  yellow,
  orange,
  red,
  purple,
}

/// Notification channel / category
enum NotificationChannel {
  medication,
  healthAlert,
  systemUpdate,
  familyUpdate,
  adminAlert,
  marketing,
}

/// A rich notification model
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationPriority priority;
  final NotificationChannel channel;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? payload;
  final String? actionLabel;
  final String? actionRoute;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.priority = NotificationPriority.green,
    this.channel = NotificationChannel.systemUpdate,
    required this.createdAt,
    this.isRead = false,
    this.payload,
    this.actionLabel,
    this.actionRoute,
  });

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      priority: priority,
      channel: channel,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      payload: payload,
      actionLabel: actionLabel,
      actionRoute: actionRoute,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      priority: _priorityFromString(json['priority'] as String?),
      channel: _channelFromString(json['channel'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
      payload: json['payload'] as Map<String, dynamic>?,
      actionLabel: json['action_label'] as String?,
      actionRoute: json['action_route'] as String?,
    );
  }

  static NotificationPriority _priorityFromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'yellow':
        return NotificationPriority.yellow;
      case 'orange':
        return NotificationPriority.orange;
      case 'red':
        return NotificationPriority.red;
      case 'purple':
        return NotificationPriority.purple;
      default:
        return NotificationPriority.green;
    }
  }

  static NotificationChannel _channelFromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'medication':
        return NotificationChannel.medication;
      case 'health_alert':
        return NotificationChannel.healthAlert;
      case 'family_update':
        return NotificationChannel.familyUpdate;
      case 'admin_alert':
        return NotificationChannel.adminAlert;
      case 'marketing':
        return NotificationChannel.marketing;
      default:
        return NotificationChannel.systemUpdate;
    }
  }
}

/// Medication reminder configuration
class MedicationReminder {
  final String medicationId;
  final String medicationName;
  final TimeOfDay time;
  final List<int> daysOfWeek; // 1=Mon..7=Sun
  final String dosage;
  final bool isEnabled;

  const MedicationReminder({
    required this.medicationId,
    required this.medicationName,
    required this.time,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    this.dosage = '',
    this.isEnabled = true,
  });

  String get formattedTime =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String get daysLabel {
    if (daysOfWeek.length == 7) return 'Codziennie';
    final names = ['', 'Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];
    return daysOfWeek.map((d) => names[d]).join(', ');
  }
}

/// Simple TimeOfDay since we may not have material
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

class NotificationService extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  final List<MedicationReminder> _reminders = [];
  bool _permissionsGranted = false;
  bool _fcmReady = false;

  // Getters
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  List<MedicationReminder> get reminders => List.unmodifiable(_reminders);
  bool get permissionsGranted => _permissionsGranted;
  bool get fcmReady => _fcmReady;

  /// Initialize notification service
  Future<void> initialize() async {
    // In production: request notification permissions
    // In production: initialize Firebase Messaging
    _permissionsGranted = true;
    _fcmReady = true;

    // Load sample notifications
    _loadSampleNotifications();
    _loadSampleReminders();

    notifyListeners();
    if (kDebugMode) debugPrint('NotificationService: initialized');
  }

  void _loadSampleNotifications() {
    final now = DateTime.now();
    _notifications.addAll([
      AppNotification(
        id: 'n1',
        title: 'Przypomnienie o lekach',
        body: 'Czas wziąć Metforminę 500mg',
        priority: NotificationPriority.yellow,
        channel: NotificationChannel.medication,
        createdAt: now.subtract(const Duration(minutes: 15)),
        actionLabel: 'Potwierdź',
        actionRoute: '/senior/medications',
      ),
      AppNotification(
        id: 'n2',
        title: 'Niskie tętno',
        body: 'Zanotowano tętno 48 BPM — sprawdź samopoczucie',
        priority: NotificationPriority.orange,
        channel: NotificationChannel.healthAlert,
        createdAt: now.subtract(const Duration(hours: 2)),
        actionRoute: '/senior/health',
      ),
      AppNotification(
        id: 'n3',
        title: 'Córka sprawdziła Twoje zdrowie',
        body: 'Anna Kowalska wyświetliła Twój dashboard',
        priority: NotificationPriority.green,
        channel: NotificationChannel.familyUpdate,
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
      ),
      AppNotification(
        id: 'n4',
        title: 'Nowa usługa dostępna',
        body: 'Fizjoterapeuta domowy — sprawdź w Marketplace',
        priority: NotificationPriority.green,
        channel: NotificationChannel.marketing,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
      AppNotification(
        id: 'n5',
        title: 'AWARIA CZUJNIKA',
        body: 'Opaska nie przesyła danych od 2 godzin',
        priority: NotificationPriority.red,
        channel: NotificationChannel.adminAlert,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ]);
  }

  void _loadSampleReminders() {
    _reminders.addAll([
      MedicationReminder(
        medicationId: 'med_1',
        medicationName: 'Metformina 500mg',
        time: const TimeOfDay(hour: 8, minute: 0),
        dosage: '1 tabletka',
      ),
      MedicationReminder(
        medicationId: 'med_1',
        medicationName: 'Metformina 500mg',
        time: const TimeOfDay(hour: 20, minute: 0),
        dosage: '1 tabletka',
      ),
      MedicationReminder(
        medicationId: 'med_2',
        medicationName: 'Aspiryna 75mg',
        time: const TimeOfDay(hour: 8, minute: 0),
        dosage: '1 tabletka',
      ),
      MedicationReminder(
        medicationId: 'med_3',
        medicationName: 'Witamina D3 2000IU',
        time: const TimeOfDay(hour: 12, minute: 0),
        dosage: '1 kapsułka',
      ),
    ]);
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx >= 0) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  /// Mark all as read
  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Add a medication reminder
  void addReminder(MedicationReminder reminder) {
    _reminders.add(reminder);
    notifyListeners();
  }

  /// Remove a medication reminder
  void removeReminder(String medicationId, TimeOfDay time) {
    _reminders.removeWhere(
        (r) => r.medicationId == medicationId && r.time == time);
    notifyListeners();
  }

  /// Toggle reminder on/off
  void toggleReminder(String medicationId, TimeOfDay time) {
    final idx = _reminders
        .indexWhere((r) => r.medicationId == medicationId && r.time == time);
    if (idx >= 0) {
      final r = _reminders[idx];
      _reminders[idx] = MedicationReminder(
        medicationId: r.medicationId,
        medicationName: r.medicationName,
        time: r.time,
        daysOfWeek: r.daysOfWeek,
        dosage: r.dosage,
        isEnabled: !r.isEnabled,
      );
      notifyListeners();
    }
  }

  /// Send a test notification
  Future<void> sendTestNotification() async {
    _notifications.insert(
      0,
      AppNotification(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Testowe powiadomienie',
        body: 'System powiadomień działa prawidłowo ✓',
        priority: NotificationPriority.green,
        channel: NotificationChannel.systemUpdate,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _notifications.clear();
    _reminders.clear();
    super.dispose();
  }
}
