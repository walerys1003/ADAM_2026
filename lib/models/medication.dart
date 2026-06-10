class Medication {
  final String id;
  final String seniorId;
  final String name;
  final String? dosage;
  final String? frequency;
  final List<String>? timeOfDay;
  final String? instructions;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final DateTime createdAt;

  const Medication({
    required this.id,
    required this.seniorId,
    required this.name,
    this.dosage,
    this.frequency,
    this.timeOfDay,
    this.instructions,
    this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
  });

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'] as String,
        seniorId: json['senior_id'] as String,
        name: json['name'] as String? ?? '',
        dosage: json['dosage'] as String?,
        frequency: json['frequency'] as String?,
        timeOfDay: json['time_of_day'] != null
            ? List<String>.from(json['time_of_day'] as List)
            : null,
        instructions: json['instructions'] as String?,
        startDate: json['start_date'] != null
            ? DateTime.tryParse(json['start_date'] as String)
            : null,
        endDate: json['end_date'] != null
            ? DateTime.tryParse(json['end_date'] as String)
            : null,
        isActive: json['is_active'] as bool? ?? true,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  String get dosageFormatted => dosage != null ? '$name $dosage' : name;
  String get timeFormatted =>
      timeOfDay?.map((t) => '${t.substring(0, 5)}').join(', ') ?? '--';

  static List<Medication> sampleMeds(String seniorId) => [
        Medication(
          id: 'm1', seniorId: seniorId, name: 'Metformina', dosage: '500mg',
          frequency: 'codziennie', timeOfDay: ['08:00'],
          instructions: 'Po posiłku', isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        Medication(
          id: 'm2', seniorId: seniorId, name: 'Amlodypina', dosage: '5mg',
          frequency: 'codziennie', timeOfDay: ['08:00'],
          instructions: 'Rano', isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
        Medication(
          id: 'm3', seniorId: seniorId, name: 'Apixaban', dosage: '2.5mg',
          frequency: 'codziennie', timeOfDay: ['20:00'],
          instructions: 'Wieczorem', isActive: true,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
        ),
      ];
}

class MedicationAdherence {
  final String id;
  final String seniorId;
  final String medicationId;
  final DateTime scheduledTime;
  final bool taken;
  final String confirmedBy;
  final String? conversationId;
  final DateTime createdAt;

  const MedicationAdherence({
    required this.id,
    required this.seniorId,
    required this.medicationId,
    required this.scheduledTime,
    required this.taken,
    required this.confirmedBy,
    this.conversationId,
    required this.createdAt,
  });

  factory MedicationAdherence.fromJson(Map<String, dynamic> json) =>
      MedicationAdherence(
        id: json['id'] as String,
        seniorId: json['senior_id'] as String,
        medicationId: json['medication_id'] as String,
        scheduledTime: DateTime.tryParse(json['scheduled_time'] as String? ?? '') ??
            DateTime.now(),
        taken: json['taken'] as bool? ?? false,
        confirmedBy: json['confirmed_by'] as String? ?? 'adam_auto',
        conversationId: json['conversation_id'] as String?,
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );
}
