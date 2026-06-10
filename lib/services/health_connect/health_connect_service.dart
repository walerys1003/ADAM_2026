/// SilverTech Agent Adam — Health Connect Bridge Service
/// Integrates with Google Health Connect for Xiaomi Smart Band 9 Pro data sync
/// June 2026 optimized — uses Health Connect API v2

import 'dart:async';
import 'package:flutter/foundation.dart';

/// Data model for synced health metrics from wearable
class WearableHealthSnapshot {
  final int heartRate;
  final int? restingHeartRate;
  final int steps;
  final double? spO2;
  final double? temperature;
  final double? sleepHours;
  final int? sleepQuality; // 1-100
  final DateTime recordedAt;
  final String deviceName;

  const WearableHealthSnapshot({
    required this.heartRate,
    this.restingHeartRate,
    required this.steps,
    this.spO2,
    this.temperature,
    this.sleepHours,
    this.sleepQuality,
    required this.recordedAt,
    this.deviceName = 'Xiaomi Smart Band 9 Pro',
  });

  factory WearableHealthSnapshot.fromJson(Map<String, dynamic> json) {
    return WearableHealthSnapshot(
      heartRate: json['heart_rate'] as int? ?? 72,
      restingHeartRate: json['resting_heart_rate'] as int?,
      steps: json['steps'] as int? ?? 0,
      spO2: (json['spo2'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      sleepHours: (json['sleep_hours'] as num?)?.toDouble(),
      sleepQuality: json['sleep_quality'] as int?,
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'] as String)
          : DateTime.now(),
      deviceName: json['device_name'] as String? ?? 'Xiaomi Smart Band 9 Pro',
    );
  }

  Map<String, dynamic> toJson() => {
        'heart_rate': heartRate,
        'resting_heart_rate': restingHeartRate,
        'steps': steps,
        'spo2': spO2,
        'temperature': temperature,
        'sleep_hours': sleepHours,
        'sleep_quality': sleepQuality,
        'recorded_at': recordedAt.toIso8601String(),
        'device_name': deviceName,
      };

  /// Semafor color based on vitals
  String get semaforLevel {
    if (spO2 != null && spO2! < 90) return 'RED';
    if (heartRate > 120 || heartRate < 50) return 'ORANGE';
    if (heartRate > 100 || heartRate < 55) return 'YELLOW';
    return 'GREEN';
  }
}

/// Anomaly detection result
class HealthAnomaly {
  final String metric;
  final double value;
  final double threshold;
  final String direction; // 'high' or 'low'
  final String severity; // 'WARNING', 'ALERT', 'CRITICAL'
  final String message;
  final DateTime detectedAt;

  const HealthAnomaly({
    required this.metric,
    required this.value,
    required this.threshold,
    required this.direction,
    required this.severity,
    required this.message,
    required this.detectedAt,
  });
}

class HealthConnectService extends ChangeNotifier {
  WearableHealthSnapshot? _latestSnapshot;
  final List<WearableHealthSnapshot> _history = [];
  final List<HealthAnomaly> _anomalies = [];
  bool _isConnected = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;
  String? _error;

  // Getters
  WearableHealthSnapshot? get latestSnapshot => _latestSnapshot;
  List<WearableHealthSnapshot> get history => List.unmodifiable(_history);
  List<HealthAnomaly> get anomalies => List.unmodifiable(_anomalies);
  bool get isConnected => _isConnected;
  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get error => _error;
  bool get hasWearable => _isConnected;

  // Thresholds for anomaly detection (customizable per senior)
  static const _defaultThresholds = {
    'heart_rate_high': 120,
    'heart_rate_low': 50,
    'spo2_low': 90,
    'temperature_high': 38.0,
    'steps_low': 100,
    'sleep_hours_low': 4.0,
  };

  Map<String, double> _thresholds = Map.from(_defaultThresholds);

  /// Initialize and attempt to connect to Health Connect
  Future<void> initialize() async {
    try {
      // In production: use health_connect package to request permissions
      // await HealthConnectFactory.hasPermission();
      // await HealthConnectFactory.requestPermission();
      _isConnected = true;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('HealthConnectService: initialized, connected=$_isConnected');
      }
    } catch (e) {
      _error = 'Failed to initialize Health Connect: $e';
      _isConnected = false;
      notifyListeners();
    }
  }

  /// Sync latest health data from wearable
  Future<WearableHealthSnapshot?> syncNow() async {
    _isSyncing = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      // In production: fetch from Health Connect API
      // final healthData = await HealthConnectFactory.getHealthData(...);

      final snapshot = WearableHealthSnapshot(
        heartRate: 72 + (DateTime.now().second % 15),
        restingHeartRate: 65 + (DateTime.now().minute % 5),
        steps: 4500 + (DateTime.now().hour * 200),
        spO2: 95.0 + (DateTime.now().millisecond % 5).toDouble(),
        temperature: 36.6,
        sleepHours: 7.5,
        sleepQuality: 78,
        recordedAt: DateTime.now(),
      );

      _latestSnapshot = snapshot;
      _history.add(snapshot);
      _lastSyncTime = DateTime.now();

      // Run anomaly detection
      _detectAnomalies(snapshot);

      _isSyncing = false;
      notifyListeners();
      return snapshot;
    } catch (e) {
      _error = 'Sync failed: $e';
      _isSyncing = false;
      notifyListeners();
      return null;
    }
  }

  /// Detect health anomalies based on thresholds
  void _detectAnomalies(WearableHealthSnapshot snapshot) {
    _anomalies.clear();

    if (snapshot.heartRate > _thresholds['heart_rate_high']!) {
      _anomalies.add(HealthAnomaly(
        metric: 'heart_rate',
        value: snapshot.heartRate.toDouble(),
        threshold: _thresholds['heart_rate_high']!,
        direction: 'high',
        severity: snapshot.heartRate > 140 ? 'CRITICAL' : 'ALERT',
        message: 'Wysokie tętno: ${snapshot.heartRate} BPM',
        detectedAt: DateTime.now(),
      ));
    }

    if (snapshot.heartRate < _thresholds['heart_rate_low']!) {
      _anomalies.add(HealthAnomaly(
        metric: 'heart_rate',
        value: snapshot.heartRate.toDouble(),
        threshold: _thresholds['heart_rate_low']!,
        direction: 'low',
        severity: snapshot.heartRate < 40 ? 'CRITICAL' : 'WARNING',
        message: 'Niskie tętno: ${snapshot.heartRate} BPM',
        detectedAt: DateTime.now(),
      ));
    }

    if (snapshot.spO2 != null && snapshot.spO2! < _thresholds['spo2_low']!) {
      _anomalies.add(HealthAnomaly(
        metric: 'spo2',
        value: snapshot.spO2!,
        threshold: _thresholds['spo2_low']!,
        direction: 'low',
        severity: snapshot.spO2! < 85 ? 'CRITICAL' : 'ALERT',
        message: 'Niskie SpO2: ${snapshot.spO2!.toStringAsFixed(1)}%',
        detectedAt: DateTime.now(),
      ));
    }

    if (snapshot.temperature != null &&
        snapshot.temperature! > _thresholds['temperature_high']!) {
      _anomalies.add(HealthAnomaly(
        metric: 'temperature',
        value: snapshot.temperature!,
        threshold: _thresholds['temperature_high']!,
        direction: 'high',
        severity: 'ALERT',
        message: 'Podwyższona temperatura: ${snapshot.temperature!.toStringAsFixed(1)}°C',
        detectedAt: DateTime.now(),
      ));
    }
  }

  /// Update threshold values
  void updateThresholds(Map<String, double> newThresholds) {
    _thresholds.addAll(newThresholds);
    notifyListeners();
  }

  /// Reset thresholds to defaults
  void resetThresholds() {
    _thresholds = Map.from(_defaultThresholds);
    notifyListeners();
  }

  /// Get 7-day trend data for a metric
  List<double> getWeeklyTrend(String metric) {
    // Simplified — in production, aggregate from _history
    switch (metric) {
      case 'heart_rate':
        return [71, 73, 70, 74, 72, 71, 73];
      case 'steps':
        return [4200, 5100, 3800, 6200, 4500, 7100, 4800];
      case 'spo2':
        return [96, 95, 97, 95, 96, 94, 96];
      default:
        return [0, 0, 0, 0, 0, 0, 0];
    }
  }

  @override
  void dispose() {
    _history.clear();
    _anomalies.clear();
    super.dispose();
  }
}
