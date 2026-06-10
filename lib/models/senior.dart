/// Senior model - core entity of the platform
class Senior {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? address;
  final DateTime? birthDate;
  final String? email;
  final String? bloodType;
  final String? emergencyContact;
  final String? emergencyContactName;
  final String? avatarUrl;
  final String? gender;
  final String package;
  final DateTime? packageStartedAt;
  final List<String>? medicalConditions;
  final List<String>? allergies;
  final String? primaryPhysicianName;
  final String? primaryPhysicianPhone;
  final String? wearableType;
  final String? wearableId;
  final DateTime? wearableLastSync;
  final String preferredCallTimeMorning;
  final String preferredCallTimeEvening;
  final double speechRateMultiplier;
  final List<String>? preferredTopics;
  final String personalityType;
  final String status;
  final String semafor;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Senior({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.address,
    this.birthDate,
    this.email,
    this.bloodType,
    this.emergencyContact,
    this.emergencyContactName,
    this.avatarUrl,
    this.gender,
    required this.package,
    this.packageStartedAt,
    this.medicalConditions,
    this.allergies,
    this.primaryPhysicianName,
    this.primaryPhysicianPhone,
    this.wearableType,
    this.wearableId,
    this.wearableLastSync,
    this.preferredCallTimeMorning = '09:00',
    this.preferredCallTimeEvening = '18:00',
    this.speechRateMultiplier = 1.0,
    this.preferredTopics,
    this.personalityType = 'tradycyjny',
    this.status = 'active',
    this.semafor = 'GREEN',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Senior.fromJson(Map<String, dynamic> json) => Senior(
        id: json['id'] as String,
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        address: json['address'] as String?,
        birthDate: json['birth_date'] != null
            ? DateTime.tryParse(json['birth_date'] as String)
            : null,
        email: json['email'] as String?,
        bloodType: json['blood_type'] as String?,
        emergencyContact: json['emergency_contact'] as String?,
        emergencyContactName: json['emergency_contact_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        gender: json['gender'] as String?,
        package: json['package'] as String? ?? 'KONTAKT',
        packageStartedAt: json['package_started_at'] != null
            ? DateTime.tryParse(json['package_started_at'] as String)
            : null,
        medicalConditions: json['medical_conditions'] != null
            ? List<String>.from(json['medical_conditions'] as List)
            : null,
        allergies: json['allergies'] != null
            ? List<String>.from(json['allergies'] as List)
            : null,
        primaryPhysicianName: json['primary_physician_name'] as String?,
        primaryPhysicianPhone: json['primary_physician_phone'] as String?,
        wearableType: json['wearable_type'] as String?,
        wearableId: json['wearable_id'] as String?,
        wearableLastSync: json['wearable_last_sync'] != null
            ? DateTime.tryParse(json['wearable_last_sync'] as String)
            : null,
        preferredCallTimeMorning:
            json['preferred_call_time_morning'] as String? ?? '09:00',
        preferredCallTimeEvening:
            json['preferred_call_time_evening'] as String? ?? '18:00',
        speechRateMultiplier:
            (json['speech_rate_multiplier'] as num?)?.toDouble() ?? 1.0,
        preferredTopics: json['preferred_topics'] != null
            ? List<String>.from(json['preferred_topics'] as List)
            : null,
        personalityType: json['personality_type'] as String? ?? 'tradycyjny',
        status: json['status'] as String? ?? 'active',
        semafor: json['semafor'] as String? ?? 'GREEN',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'address': address,
        'birth_date': birthDate?.toIso8601String(),
        'email': email,
        'blood_type': bloodType,
        'emergency_contact': emergencyContact,
        'emergency_contact_name': emergencyContactName,
        'avatar_url': avatarUrl,
        'gender': gender,
        'package': package,
        'package_started_at': packageStartedAt?.toIso8601String(),
        'medical_conditions': medicalConditions,
        'allergies': allergies,
        'primary_physician_name': primaryPhysicianName,
        'primary_physician_phone': primaryPhysicianPhone,
        'wearable_type': wearableType,
        'wearable_id': wearableId,
        'wearable_last_sync': wearableLastSync?.toIso8601String(),
        'preferred_call_time_morning': preferredCallTimeMorning,
        'preferred_call_time_evening': preferredCallTimeEvening,
        'speech_rate_multiplier': speechRateMultiplier,
        'preferred_topics': preferredTopics,
        'personality_type': personalityType,
        'status': status,
        'semafor': semafor,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  String get fullName => '$firstName $lastName';
  int get age => birthDate != null
      ? DateTime.now().difference(birthDate!).inDays ~/ 365
      : 0;
  bool get hasWearable => wearableType != null && wearableId != null;
  bool get isActive => status == 'active';

  // ── Consent / status getters ──
  List<String> get chronicConditions => medicalConditions ?? [];
  List<String> get allergiesList => allergies ?? [];
  bool get onboardingCompleted => status == 'active';
  bool get voiceRecordingConsent => true;
  bool get healthDataConsent => true;
  bool get familySharingConsent => true;
  String get semaforLevel => semafor;
  bool get isSemaforCritical => semafor == 'RED' || semafor == 'PURPLE';

  // ── copyWith ──
  Senior copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    DateTime? birthDate,
    String? email,
    String? bloodType,
    String? emergencyContact,
    String? emergencyContactName,
    String? avatarUrl,
    String? gender,
    String? package,
    DateTime? packageStartedAt,
    List<String>? medicalConditions,
    List<String>? allergies,
    String? primaryPhysicianName,
    String? primaryPhysicianPhone,
    String? wearableType,
    String? wearableId,
    DateTime? wearableLastSync,
    String? preferredCallTimeMorning,
    String? preferredCallTimeEvening,
    double? speechRateMultiplier,
    List<String>? preferredTopics,
    String? personalityType,
    String? status,
    String? semafor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Senior(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    birthDate: birthDate ?? this.birthDate,
    email: email ?? this.email,
    bloodType: bloodType ?? this.bloodType,
    emergencyContact: emergencyContact ?? this.emergencyContact,
    emergencyContactName: emergencyContactName ?? this.emergencyContactName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    gender: gender ?? this.gender,
    package: package ?? this.package,
    packageStartedAt: packageStartedAt ?? this.packageStartedAt,
    medicalConditions: medicalConditions ?? this.medicalConditions,
    allergies: allergies ?? this.allergies,
    primaryPhysicianName: primaryPhysicianName ?? this.primaryPhysicianName,
    primaryPhysicianPhone: primaryPhysicianPhone ?? this.primaryPhysicianPhone,
    wearableType: wearableType ?? this.wearableType,
    wearableId: wearableId ?? this.wearableId,
    wearableLastSync: wearableLastSync ?? this.wearableLastSync,
    preferredCallTimeMorning: preferredCallTimeMorning ?? this.preferredCallTimeMorning,
    preferredCallTimeEvening: preferredCallTimeEvening ?? this.preferredCallTimeEvening,
    speechRateMultiplier: speechRateMultiplier ?? this.speechRateMultiplier,
    preferredTopics: preferredTopics ?? this.preferredTopics,
    personalityType: personalityType ?? this.personalityType,
    status: status ?? this.status,
    semafor: semafor ?? this.semafor,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static List<Senior> sampleSeniors() => [
        Senior(
          id: 's1',
          firstName: 'Maria',
          lastName: 'Kowalska',
          phone: '+48 612 345 678',
          address: 'ul. Główna 12/3, 61-001 Poznań',
          birthDate: DateTime(1948, 3, 15),
          gender: 'female',
          package: 'ZDROWIE',
          medicalConditions: ['cukrzyca typu 2', 'nadciśnienie'],
          allergies: ['penicylina'],
          primaryPhysicianName: 'dr Anna Nowak',
          primaryPhysicianPhone: '+48 611 234 567',
          wearableType: 'xiaomi_band_9_pro',
          wearableId: 'XM-001',
          preferredTopics: ['wnuki', 'ogród', 'historia'],
          personalityType: 'tradycyjny',
          semafor: 'GREEN',
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now(),
        ),
        Senior(
          id: 's2',
          firstName: 'Jan',
          lastName: 'Nowak',
          phone: '+48 612 987 654',
          address: 'ul. Spokojna 5/7, 61-002 Poznań',
          birthDate: DateTime(1952, 7, 22),
          gender: 'male',
          package: 'KONTAKT',
          medicalConditions: ['nadciśnienie'],
          preferredCallTimeMorning: '08:00',
          preferredCallTimeEvening: '19:00',
          preferredTopics: ['sport', 'polityka', 'motoryzacja'],
          personalityType: 'przyjaciel',
          semafor: 'YELLOW',
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now(),
        ),
      ];
}
