/// Health data from wearable devices (Xiaomi Smart Band 9 Pro via Google Health Connect)
class HealthData {
  final String id;
  final String seniorId;
  final String deviceType;
  final DateTime recordedAt;
  final int? heartRateBpm;
  final int? heartRateRestingBpm;
  final double? spo2Percent;
  final int? steps;
  final double? caloriesBurned;
  final double? distanceMeters;
  final SleepData? sleep;
  final String? activityType;
  final int? activityDurationMinutes;

  const HealthData({
    required this.id,
    required this.seniorId,
    required this.deviceType,
    required this.recordedAt,
    this.heartRateBpm,
    this.heartRateRestingBpm,
    this.spo2Percent,
    this.steps,
    this.caloriesBurned,
    this.distanceMeters,
    this.sleep,
    this.activityType,
    this.activityDurationMinutes,
  });

  factory HealthData.fromJson(Map<String, dynamic> json) => HealthData(
        id: json['id'] as String,
        seniorId: json['senior_id'] as String,
        deviceType: json['device_type'] as String? ?? 'unknown',
        recordedAt:
            DateTime.tryParse(json['recorded_at'] as String? ?? '') ?? DateTime.now(),
        heartRateBpm: json['heart_rate_bpm'] as int?,
        heartRateRestingBpm: json['heart_rate_resting_bpm'] as int?,
        spo2Percent: (json['spo2_percent'] as num?)?.toDouble(),
        steps: json['steps'] as int?,
        caloriesBurned: (json['calories_burned'] as num?)?.toDouble(),
        distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
        sleep: json['sleep_start'] != null
            ? SleepData.fromJson(json)
            : null,
        activityType: json['activity_type'] as String?,
        activityDurationMinutes: json['activity_duration_minutes'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'senior_id': seniorId,
        'device_type': deviceType,
        'recorded_at': recordedAt.toIso8601String(),
        'heart_rate_bpm': heartRateBpm,
        'heart_rate_resting_bpm': heartRateRestingBpm,
        'spo2_percent': spo2Percent,
        'steps': steps,
        'calories_burned': caloriesBurned,
        'distance_meters': distanceMeters,
        'activity_type': activityType,
        'activity_duration_minutes': activityDurationMinutes,
      };

  String get heartRateStatus {
    if (heartRateBpm == null) return 'Brak danych';
    if (heartRateBpm! < 50) return 'Niskie';
    if (heartRateBpm! > 100) return 'Podwyższone';
    return 'W normie';
  }

  String get spo2Status {
    if (spo2Percent == null) return 'Brak danych';
    if (spo2Percent! < 90) return 'UWAGA: Niski';
    if (spo2Percent! < 95) return 'Lekko obniżony';
    return 'W normie';
  }
}

class SleepData {
  final DateTime sleepStart;
  final DateTime sleepEnd;
  final int deepMinutes;
  final int lightMinutes;
  final int remMinutes;
  final int awakeMinutes;

  const SleepData({
    required this.sleepStart,
    required this.sleepEnd,
    required this.deepMinutes,
    required this.lightMinutes,
    required this.remMinutes,
    required this.awakeMinutes,
  });

  factory SleepData.fromJson(Map<String, dynamic> json) => SleepData(
        sleepStart: DateTime.tryParse(json['sleep_start'] as String? ?? '') ??
            DateTime.now(),
        sleepEnd: DateTime.tryParse(json['sleep_end'] as String? ?? '') ??
            DateTime.now(),
        deepMinutes: json['sleep_deep_minutes'] as int? ?? 0,
        lightMinutes: json['sleep_light_minutes'] as int? ?? 0,
        remMinutes: json['sleep_rem_minutes'] as int? ?? 0,
        awakeMinutes: json['sleep_awake_minutes'] as int? ?? 0,
      );

  int get totalMinutes => deepMinutes + lightMinutes + remMinutes + awakeMinutes;

  String get totalFormatted {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    return '${hours}h ${mins}min';
  }

  double get sleepScore {
    if (totalMinutes == 0) return 0;
    final quality = (deepMinutes + remMinutes) / totalMinutes;
    final duration = totalMinutes / 480; // ideal: 8h
    return ((quality * 0.6 + duration * 0.4) * 100).clamp(0, 100);
  }
}

/// Weekly health summary for family dashboard
class WeeklyHealthSummary {
  final String seniorId;
  final DateTime weekStart;
  final double avgHeartRate;
  final double avgSpo2;
  final int totalSteps;
  final double avgSleepHours;
  final double avgSleepScore;
  final int conversationCount;
  final double avgMoodScore;
  final int alertCount;
  final int medicationAdherencePercent;

  const WeeklyHealthSummary({
    required this.seniorId,
    required this.weekStart,
    required this.avgHeartRate,
    required this.avgSpo2,
    required this.totalSteps,
    required this.avgSleepHours,
    required this.avgSleepScore,
    required this.conversationCount,
    required this.avgMoodScore,
    required this.alertCount,
    required this.medicationAdherencePercent,
  });

  factory WeeklyHealthSummary.fromJson(Map<String, dynamic> json) =>
      WeeklyHealthSummary(
        seniorId: json['senior_id'] as String,
        weekStart: DateTime.tryParse(json['week_start'] as String? ?? '') ??
            DateTime.now(),
        avgHeartRate: (json['avg_heart_rate'] as num?)?.toDouble() ?? 0,
        avgSpo2: (json['avg_spo2'] as num?)?.toDouble() ?? 0,
        totalSteps: json['total_steps'] as int? ?? 0,
        avgSleepHours: (json['avg_sleep_hours'] as num?)?.toDouble() ?? 0,
        avgSleepScore: (json['avg_sleep_score'] as num?)?.toDouble() ?? 0,
        conversationCount: json['conversation_count'] as int? ?? 0,
        avgMoodScore: (json['avg_mood_score'] as num?)?.toDouble() ?? 0,
        alertCount: json['alert_count'] as int? ?? 0,
        medicationAdherencePercent:
            json['medication_adherence_percent'] as int? ?? 0,
      );
}
