import 'package:flutter/services.dart';

/// Service for haptic feedback across the app.
/// Enhances accessibility for seniors by providing tactile confirmation
/// of important actions (button presses, alerts, navigation).
class HapticFeedbackService {
  static final HapticFeedbackService _instance = HapticFeedbackService._();
  factory HapticFeedbackService() => _instance;
  HapticFeedbackService._();

  bool _isEnabled = true;

  bool get isEnabled => _isEnabled;

  /// Enable or disable haptic feedback globally
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Light tap — subtle confirmation of touch
  void lightImpact() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// Medium tap — standard button press feedback
  void mediumImpact() {
    if (!_isEnabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Heavy tap — important action confirmation (e.g., SOS, send message)
  void heavyImpact() {
    if (!_isEnabled) return;
    HapticFeedback.heavyImpact();
  }

  /// Selection click — toggle/switch state change
  void selectionClick() {
    if (!_isEnabled) return;
    HapticFeedback.selectionClick();
  }

  /// Success pattern — light → medium → light (3 pulses)
  void success() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 80), () {
      HapticFeedback.mediumImpact();
    });
    Future.delayed(const Duration(milliseconds: 160), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Warning pattern — heavy → heavy (2 pulses)
  void warning() {
    if (!_isEnabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 120), () {
      HapticFeedback.heavyImpact();
    });
  }

  /// Emergency pattern — 3 rapid heavy pulses
  void emergency() {
    if (!_isEnabled) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 60), () {
      HapticFeedback.heavyImpact();
    });
    Future.delayed(const Duration(milliseconds: 120), () {
      HapticFeedback.heavyImpact();
    });
  }

  /// Semafor escalation haptics based on level
  void semaforLevel(String level) {
    switch (level.toUpperCase()) {
      case 'GREEN':
        lightImpact();
        break;
      case 'YELLOW':
        mediumImpact();
        break;
      case 'ORANGE':
        warning();
        break;
      case 'RED':
        emergency();
        break;
      case 'PURPLE':
        // Most urgent: double emergency
        emergency();
        Future.delayed(const Duration(milliseconds: 300), () {
          emergency();
        });
        break;
      default:
        lightImpact();
    }
  }

  /// Voice assistant listening started
  void voiceListeningStart() {
    if (!_isEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// Voice assistant processing complete
  void voiceResponseReady() {
    if (!_isEnabled) return;
    HapticFeedback.mediumImpact();
  }

  /// Medication reminder confirmation
  void medicationConfirmed() {
    if (!_isEnabled) return;
    success();
  }
}
