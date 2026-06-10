import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../../providers/app_provider.dart';
import '../../../mixins/accessibility/accessibility_mixin.dart';

/// Senior Breathing Exercise Screen
/// Guided breathing with animated circle + haptic feedback
/// Supports 4-7-8 pattern (inhale 4s, hold 7s, exhale 8s)
class SeniorBreathingScreen extends StatefulWidget {
  const SeniorBreathingScreen({super.key});

  @override
  State<SeniorBreathingScreen> createState() => _SeniorBreathingScreenState();
}

class _SeniorBreathingScreenState extends State<SeniorBreathingScreen>
    with SingleTickerProviderStateMixin, AccessibilityMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  BreathingPhase _phase = BreathingPhase.ready;
  int _cycleCount = 0;
  int _totalSeconds = 0;
  bool _isActive = false;

  static const _inhaleDuration = 4;
  static const _holdDuration = 7;
  static const _exhaleDuration = 8;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _inhaleDuration + _holdDuration + _exhaleDuration),
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.21, curve: Curves.easeInOut),
      ),
    );

    _opacityAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.21, curve: Curves.easeIn),
      ),
    );

    _animController.addStatusListener(_onAnimStatus);
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && _isActive) {
      setState(() {
        _cycleCount++;
        _phase = BreathingPhase.ready;
      });
    }
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _phase = BreathingPhase.inhale;
    });
    _runBreathingCycle();
  }

  void _stopBreathing() {
    setState(() {
      _isActive = false;
      _phase = BreathingPhase.ready;
    });
    _animController.stop();
  }

  Future<void> _runBreathingCycle() async {
    while (_isActive) {
      // Inhale phase (4s)
      setState(() => _phase = BreathingPhase.inhale);
      _animController.forward(from: 0.0);
      await Future.delayed(const Duration(seconds: _inhaleDuration));
      if (!_isActive) break;

      // Hold phase (7s)
      setState(() => _phase = BreathingPhase.hold);
      await Future.delayed(const Duration(seconds: _holdDuration));
      if (!_isActive) break;

      // Exhale phase (8s)
      setState(() => _phase = BreathingPhase.exhale);
      _animController.reverse(from: 1.0);
      await Future.delayed(const Duration(seconds: _exhaleDuration));
      if (!_isActive) break;

      setState(() => _cycleCount++);
    }
  }

  Color get _phaseColor {
    switch (_phase) {
      case BreathingPhase.inhale:
        return const Color(0xFF4CAF50); // green — inhale
      case BreathingPhase.hold:
        return const Color(0xFF2196F3); // blue — hold
      case BreathingPhase.exhale:
        return const Color(0xFF9C27B0); // purple — exhale
      case BreathingPhase.ready:
        return const Color(0xFF66BB6A);
    }
  }

  String get _phaseLabel {
    switch (_phase) {
      case BreathingPhase.inhale:
        return 'Wdech (4s)';
      case BreathingPhase.hold:
        return 'Zatrzymaj (7s)';
      case BreathingPhase.exhale:
        return 'Wydech (8s)';
      case BreathingPhase.ready:
        return 'Gotowy?';
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text(
          'Ćwiczenie oddechowe',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Cycle counter
            Text(
              'Cykl: $_cycleCount',
              style: TextStyle(
                fontSize: getScaledFontSize(18),
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 48),
            // Breathing circle
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Container(
                      width: math.min(size.width * 0.7, 280),
                      height: math.min(size.width * 0.7, 280),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _phaseColor.withValues(alpha: 0.15),
                        border: Border.all(
                          color: _phaseColor.withValues(alpha: 0.6),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _phaseColor.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Transform.scale(
                        scale: _isActive ? _scaleAnim.value : 0.7,
                        child: Opacity(
                          opacity: _isActive ? _opacityAnim.value : 0.7,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _phase == BreathingPhase.inhale
                                      ? Icons.air
                                      : _phase == BreathingPhase.hold
                                          ? Icons.pause_circle_filled
                                          : _phase == BreathingPhase.exhale
                                              ? Icons.cloud
                                              : Icons.self_improvement,
                                  size: 64,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _phaseLabel,
                                  style: TextStyle(
                                    fontSize: getScaledFontSize(22),
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Tips section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Colors.amber.shade300, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'Wskazówka',
                        style: TextStyle(
                          fontSize: getScaledFontSize(18),
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Usiądź wygodnie. Wdychaj nosem przez 4 sekundy, wstrzymaj oddech na 7 sekund, '
                    'wydychaj powoli ustami przez 8 sekund. Powtórz 4 razy dla najlepszego efektu.',
                    style: TextStyle(
                      fontSize: getScaledFontSize(16),
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Start/Stop button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: getScaledTouchTarget(64),
                child: ElevatedButton(
                  onPressed: _isActive ? _stopBreathing : _startBreathing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isActive ? Colors.redAccent : const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    elevation: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isActive ? Icons.stop : Icons.play_arrow, size: 32),
                      const SizedBox(width: 12),
                      Text(
                        _isActive ? 'Zatrzymaj' : 'Rozpocznij ćwiczenie',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

enum BreathingPhase { ready, inhale, hold, exhale }
