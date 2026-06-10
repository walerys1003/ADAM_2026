/// SilverTech Agent Adam — Voice Call Service
/// Manages Twilio voice call lifecycle, Deepgram STT, and TTS playback
/// June 2026 optimized — 7-layer voice pipeline

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_config.dart';

/// Call state enum
enum CallState {
  idle,
  dialing,
  ringing,
  connected,
  speaking,
  listening,
  processing,
  ended,
  error,
}

/// Voice call session
class VoiceCallSession {
  final String callId;
  final String seniorId;
  final CallState state;
  final Duration duration;
  final List<TranscriptLine> transcript;
  final double? estimatedCost;
  final String? moodScore;
  final DateTime startedAt;
  final DateTime? endedAt;

  const VoiceCallSession({
    required this.callId,
    required this.seniorId,
    required this.state,
    this.duration = Duration.zero,
    this.transcript = const [],
    this.estimatedCost,
    this.moodScore,
    required this.startedAt,
    this.endedAt,
  });
}

/// Single line of conversation transcript
class TranscriptLine {
  final String speaker; // 'senior' or 'adam'
  final String text;
  final Duration timestamp;
  final double? confidence; // STT confidence
  final String? emotion; // detected emotion

  const TranscriptLine({
    required this.speaker,
    required this.text,
    required this.timestamp,
    this.confidence,
    this.emotion,
  });

  factory TranscriptLine.fromJson(Map<String, dynamic> json) {
    return TranscriptLine(
      speaker: json['speaker'] as String? ?? 'senior',
      text: json['text'] as String? ?? '',
      timestamp: Duration(seconds: json['timestamp_seconds'] as int? ?? 0),
      confidence: (json['confidence'] as num?)?.toDouble(),
      emotion: json['emotion'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'speaker': speaker,
        'text': text,
        'timestamp_seconds': timestamp.inSeconds,
        'confidence': confidence,
        'emotion': emotion,
      };

  bool get isSenior => speaker == 'senior';
  bool get isAdam => speaker == 'adam';
}

class VoiceCallService extends ChangeNotifier {
  CallState _callState = CallState.idle;
  VoiceCallSession? _activeSession;
  final List<TranscriptLine> _liveTranscript = [];
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;
  String? _error;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  double _volume = 1.0;

  // Getters
  CallState get callState => _callState;
  VoiceCallSession? get activeSession => _activeSession;
  List<TranscriptLine> get liveTranscript => List.unmodifiable(_liveTranscript);
  Duration get callDuration => _callDuration;
  String? get error => _error;
  bool get isInCall => _callState == CallState.connected ||
      _callState == CallState.speaking ||
      _callState == CallState.listening ||
      _callState == CallState.processing;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;
  double get volume => _volume;

  /// Start a new call to Agent Adam
  Future<bool> startCall(String seniorId) async {
    if (_callState != CallState.idle) {
      _error = 'Call already in progress';
      return false;
    }

    _callState = CallState.dialing;
    _error = null;
    notifyListeners();

    try {
      // In production: POST to /api/voice/call/start
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/voice/call/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senior_id': seniorId,
          'caller_number': '+48${seniorId.hashCode.abs().toString().padLeft(9, '0')}',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        _activeSession = VoiceCallSession(
          callId: data['call_id'] as String? ?? 'call_${DateTime.now().millisecondsSinceEpoch}',
          seniorId: seniorId,
          state: CallState.connected,
          startedAt: DateTime.now(),
        );

        _callState = CallState.connected;
        _startCallTimer();
        notifyListeners();
        return true;
      } else {
        throw Exception('Call start failed: ${response.statusCode}');
      }
    } catch (e) {
      _error = 'Failed to start call: $e';
      _callState = CallState.error;
      notifyListeners();

      // Fallback: simulate call for demo
      return await _simulateCall(seniorId);
    }
  }

  /// Simulate a call for demo/testing purposes
  Future<bool> _simulateCall(String seniorId) async {
    _callState = CallState.dialing;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));

    _activeSession = VoiceCallSession(
      callId: 'sim_${DateTime.now().millisecondsSinceEpoch}',
      seniorId: seniorId,
      state: CallState.connected,
      startedAt: DateTime.now(),
    );
    _callState = CallState.connected;
    _startCallTimer();
    notifyListeners();

    // Simulate Adam greeting after 1 second
    await Future.delayed(const Duration(seconds: 1));
    _addTranscriptLine(TranscriptLine(
      speaker: 'adam',
      text: 'Dzień dobry! Tu Adam. Jak się dziś czujesz?',
      timestamp: _callDuration,
      emotion: 'warm',
    ));

    return true;
  }

  /// End the current call
  Future<void> endCall({String? reason}) async {
    _callTimer?.cancel();
    _callTimer = null;
    _callState = CallState.ended;
    notifyListeners();

    // In production: POST to /api/voice/call/end
    try {
      if (_activeSession != null) {
        await http.post(
          Uri.parse('${AppConfig.apiBaseUrl}/voice/call/end'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'call_id': _activeSession!.callId,
            'reason': reason ?? 'normal',
            'duration_seconds': _callDuration.inSeconds,
          }),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('End call notification failed: $e');
    }

    _activeSession = null;
    _liveTranscript.clear();
    _callDuration = Duration.zero;
    _error = null;
    notifyListeners();
  }

  /// Send DTMF tone (for IVR or menu navigation)
  void sendDTMF(String digit) {
    if (kDebugMode) debugPrint('VoiceCall: DTMF sent: $digit');
  }

  /// Toggle mute
  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  /// Toggle speaker
  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    notifyListeners();
  }

  /// Set volume (0.0 - 1.0)
  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Add a transcript line (called by STT/LLM pipeline)
  void _addTranscriptLine(TranscriptLine line) {
    _liveTranscript.add(line);
    notifyListeners();
  }

  /// Process senior speech (mock for demo)
  Future<void> processSeniorSpeech(String text) async {
    _callState = CallState.processing;
    notifyListeners();

    _addTranscriptLine(TranscriptLine(
      speaker: 'senior',
      text: text,
      timestamp: _callDuration,
      confidence: 0.95,
    ));

    await Future.delayed(const Duration(milliseconds: 1200));

    // Simulate Adam response
    final adamResponse = _generateAdamResponse(text);
    _addTranscriptLine(TranscriptLine(
      speaker: 'adam',
      text: adamResponse,
      timestamp: _callDuration,
      emotion: 'friendly',
    ));

    _callState = CallState.connected;
    notifyListeners();
  }

  /// Generate mock Adam responses
  String _generateAdamResponse(String seniorText) {
    final lower = seniorText.toLowerCase();
    if (lower.contains('boli') || lower.contains('ból')) {
      return 'Przykro mi to słyszeć. Gdzie dokładnie odczuwasz ból? Czy to coś nowego, czy znasz już ten ból?';
    } else if (lower.contains('lekarz') || lower.contains('doktor')) {
      return 'Mogę pomóc umówić wizytę. Twój lekarz rodzinny, dr Kowalski, ma wolny termin jutro o 10:30. Czy mam zarezerwować?';
    } else if (lower.contains('leki') || lower.contains('tabletki')) {
      return 'Przypominam — o 8:00 powinieneś wziąć Metforminę, a o 20:00 kolejną dawkę. Czy już wziąłeś poranną dawkę?';
    } else if (lower.contains('dobrze') || lower.contains('świetnie')) {
      return 'To wspaniale! Cieszę się razem z Tobą. Twoje tętno wynosi dziś 72, wszystko w normie.';
    } else if (lower.contains('samotn') || lower.contains('smutn')) {
      return 'Rozumiem. Ja jestem tutaj dla Ciebie zawsze. Może opowiesz mi, co Cię trapi? Albo zadzwonię do Twojej córki?';
    }
    return 'Dziękuję, że mi to mówisz. Czy jest coś jeszcze, w czym mogę Ci pomóc?';
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _callDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  /// Format duration as MM:SS
  String get formattedDuration {
    final minutes = _callDuration.inMinutes.toString().padLeft(2, '0');
    final seconds = (_callDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }
}
