/// Conversation model - records of AI voice calls with seniors
class Conversation {
  final String id;
  final String seniorId;
  final String type;
  final String direction;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? durationSeconds;
  final List<TranscriptMessage>? transcript;
  final String? audioUrl;
  final double? sentimentScore;
  final int? moodScore;
  final List<String>? topics;
  final String semaforBefore;
  final String semaforAfter;
  final bool escalationFlag;
  final String? escalationLevel;
  final bool escalationResolved;
  final double? costTelecomUsd;
  final double? costSttUsd;
  final double? costLlmUsd;
  final double? costTtsUsd;
  final double? costTotalUsd;
  final DateTime createdAt;

  const Conversation({
    required this.id,
    required this.seniorId,
    required this.type,
    required this.direction,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds,
    this.transcript,
    this.audioUrl,
    this.sentimentScore,
    this.moodScore,
    this.topics,
    this.semaforBefore = 'GREEN',
    this.semaforAfter = 'GREEN',
    this.escalationFlag = false,
    this.escalationLevel,
    this.escalationResolved = false,
    this.costTelecomUsd,
    this.costSttUsd,
    this.costLlmUsd,
    this.costTtsUsd,
    this.costTotalUsd,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => Conversation(
        id: json['id'] as String,
        seniorId: json['senior_id'] as String,
        type: json['type'] as String? ?? 'welfare_check_morning',
        direction: json['direction'] as String? ?? 'outbound',
        startedAt:
            DateTime.tryParse(json['started_at'] as String? ?? '') ?? DateTime.now(),
        endedAt: json['ended_at'] != null
            ? DateTime.tryParse(json['ended_at'] as String)
            : null,
        durationSeconds: json['duration_seconds'] as int?,
        transcript: json['transcript'] != null
            ? (json['transcript'] as List)
                .map((m) => TranscriptMessage.fromJson(m as Map<String, dynamic>))
                .toList()
            : null,
        audioUrl: json['audio_storage_url'] as String?,
        sentimentScore: (json['sentiment_score'] as num?)?.toDouble(),
        moodScore: json['mood_score'] as int?,
        topics: json['topics'] != null
            ? List<String>.from(json['topics'] as List)
            : null,
        semaforBefore: json['semafor_before'] as String? ?? 'GREEN',
        semaforAfter: json['semafor_after'] as String? ?? 'GREEN',
        escalationFlag: json['escalation_flag'] as bool? ?? false,
        escalationLevel: json['escalation_level'] as String?,
        escalationResolved: json['escalation_resolved'] as bool? ?? false,
        costTelecomUsd: (json['cost_telecom_usd'] as num?)?.toDouble(),
        costSttUsd: (json['cost_stt_usd'] as num?)?.toDouble(),
        costLlmUsd: (json['cost_llm_usd'] as num?)?.toDouble(),
        costTtsUsd: (json['cost_tts_usd'] as num?)?.toDouble(),
        costTotalUsd: (json['cost_total_usd'] as num?)?.toDouble(),
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'senior_id': seniorId,
        'type': type,
        'direction': direction,
        'started_at': startedAt.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'duration_seconds': durationSeconds,
        'transcript': transcript?.map((m) => m.toJson()).toList(),
        'audio_storage_url': audioUrl,
        'sentiment_score': sentimentScore,
        'mood_score': moodScore,
        'topics': topics,
        'semafor_before': semaforBefore,
        'semafor_after': semaforAfter,
        'escalation_flag': escalationFlag,
        'escalation_level': escalationLevel,
        'escalation_resolved': escalationResolved,
        'cost_telecom_usd': costTelecomUsd,
        'cost_stt_usd': costSttUsd,
        'cost_llm_usd': costLlmUsd,
        'cost_tts_usd': costTtsUsd,
        'cost_total_usd': costTotalUsd,
        'created_at': createdAt.toIso8601String(),
      };

  String get typeLabel {
    switch (type) {
      case 'welfare_check_morning':
        return 'Poranny check-in';
      case 'welfare_check_evening':
        return 'Wieczorny check-in';
      case 'senior_initiated':
        return 'Senior dzwoni';
      case 'crisis':
        return 'Kryzysowa';
      case 'emotional_support':
        return 'Wsparcie emocjonalne';
      case 'marketplace_request':
        return 'Zamówienie usługi';
      case 'fall_detection_alert':
        return 'Alarm upadku';
      default:
        return type;
    }
  }

  String get durationFormatted {
    if (durationSeconds == null) return '--:--';
    final min = durationSeconds! ~/ 60;
    final sec = durationSeconds! % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String get moodEmoji {
    if (moodScore == null) return '--';
    if (moodScore! >= 5) return '😊';
    if (moodScore! >= 4) return '🙂';
    if (moodScore! >= 3) return '😐';
    if (moodScore! >= 2) return '😕';
    return '😢';
  }

  static List<Conversation> sampleConversations(String seniorId) => [
        Conversation(
          id: 'c1',
          seniorId: seniorId,
          type: 'welfare_check_morning',
          direction: 'outbound',
          startedAt: DateTime.now().subtract(const Duration(hours: 2)),
          endedAt: DateTime.now().subtract(const Duration(hours: 2)).add(const Duration(minutes: 12)),
          durationSeconds: 720,
          transcript: [
            TranscriptMessage(role: 'adam', text: 'Dzień dobry, Pani Mario. Mówi Adam, asystent AI SilverTech. Jak się Pani dzisiaj czuje?', timestamp: '0:00'),
            TranscriptMessage(role: 'senior', text: 'Dzień dobry, Adamie. Dzisiaj czuję się całkiem dobrze. Spałam lepiej niż zwykle.', timestamp: '0:05'),
            TranscriptMessage(role: 'adam', text: 'To wspaniale słyszeć! Czy pamiętała Pani o porannych lekach?', timestamp: '0:10'),
            TranscriptMessage(role: 'senior', text: 'Tak, wzięłam już Metforminę i Amlodypinę po śniadaniu.', timestamp: '0:14'),
            TranscriptMessage(role: 'adam', text: 'Dziękuję za informację. Czy potrzebuje Pani czegoś dzisiaj? Może którąś z naszych usług?', timestamp: '0:20'),
            TranscriptMessage(role: 'senior', text: 'Nie, dziękuję. Dzisiaj odwiedzi mnie syn.', timestamp: '0:25'),
            TranscriptMessage(role: 'adam', text: 'To miło. Życzę Pani pięknego dnia. Do usłyszenia wieczorem!', timestamp: '0:30'),
          ],
          sentimentScore: 0.65,
          moodScore: 4,
          topics: ['samopoczucie', 'leki', 'rodzina'],
          semaforBefore: 'GREEN',
          semaforAfter: 'GREEN',
          costTelecomUsd: 0.029,
          costSttUsd: 0.034,
          costLlmUsd: 0.005,
          costTtsUsd: 0.065,
          costTotalUsd: 0.133,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        Conversation(
          id: 'c2',
          seniorId: seniorId,
          type: 'welfare_check_evening',
          direction: 'outbound',
          startedAt: DateTime.now().subtract(const Duration(hours: 14)),
          endedAt: DateTime.now().subtract(const Duration(hours: 14)).add(const Duration(minutes: 15)),
          durationSeconds: 900,
          transcript: [
            TranscriptMessage(role: 'adam', text: 'Dobry wieczór, Pani Mario. Mówi Adam. Jak minął Pani dzień?', timestamp: '0:00'),
            TranscriptMessage(role: 'senior', text: 'Dobry wieczór. Dzień był dobry, byłam na spacerze z wnukiem.', timestamp: '0:04'),
            TranscriptMessage(role: 'adam', text: 'To wspaniale! Ile kroków Pani dzisiaj zrobiła?', timestamp: '0:10'),
            TranscriptMessage(role: 'senior', text: 'Opaska pokazuje 4500 kroków.', timestamp: '0:14'),
            TranscriptMessage(role: 'adam', text: 'Bardzo dobry wynik! Czy pamięta Pani o wieczornym leku - Apixaban?', timestamp: '0:18'),
            TranscriptMessage(role: 'senior', text: 'Jeszcze nie. Wezmę teraz.', timestamp: '0:23'),
            TranscriptMessage(role: 'adam', text: 'Proszę pamiętać. Życzę Pani spokojnej nocy.', timestamp: '0:27'),
          ],
          sentimentScore: 0.78,
          moodScore: 5,
          topics: ['spacer', 'wnuk', 'leki', 'opaska'],
          semaforBefore: 'GREEN',
          semaforAfter: 'GREEN',
          costTotalUsd: 0.156,
          createdAt: DateTime.now().subtract(const Duration(hours: 14)),
        ),
        Conversation(
          id: 'c3',
          seniorId: seniorId,
          type: 'crisis',
          direction: 'outbound',
          startedAt: DateTime.now().subtract(const Duration(days: 1)),
          endedAt: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(minutes: 5)),
          durationSeconds: 300,
          sentimentScore: -0.45,
          moodScore: 2,
          topics: ['zawroty_głowy', 'lekarz'],
          semaforBefore: 'GREEN',
          semaforAfter: 'YELLOW',
          escalationFlag: true,
          escalationLevel: 'YELLOW',
          escalationResolved: true,
          costTotalUsd: 0.072,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
}

class TranscriptMessage {
  final String role; // 'adam' or 'senior'
  final String text;
  final String timestamp;

  const TranscriptMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  factory TranscriptMessage.fromJson(Map<String, dynamic> json) =>
      TranscriptMessage(
        role: json['role'] as String? ?? 'adam',
        text: json['text'] as String? ?? '',
        timestamp: json['timestamp'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'role': role,
        'text': text,
        'timestamp': timestamp,
      };

  bool get isAdam => role == 'adam';
  bool get isSenior => role == 'senior';
}
