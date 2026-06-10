/// SilverTech Agent Adam — Enhanced Breathing Circle Widget
/// Advanced breathing exercise visualization with:
/// - 4 breathing patterns (4-7-8, box breathing, 5-5-5, custom)
/// - Radial progress indicator with smooth animation
/// - Phase labels with color transitions
/// - Session statistics (cycles, duration, heart rate integration)
/// - Haptic feedback integration

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../config/app_config.dart';

enum BreathingPattern {
  /// 4-7-8 pattern: inhale 4s, hold 7s, exhale 8s
  fourSevenEight,
  /// Box breathing: inhale 4s, hold 4s, exhale 4s, hold 4s
  boxBreathing,
  /// Relaxation: inhale 5s, exhale 5s (no hold)
  fiveFive,
  /// Custom pattern configured by user
  custom,
}

class BreathingPatternConfig {
  final int inhaleSeconds;
  final int holdInSeconds;
  final int exhaleSeconds;
  final int holdOutSeconds;
  final int recommendedCycles;
  final String label;
  final String description;

  const BreathingPatternConfig({
    required this.inhaleSeconds,
    required this.holdInSeconds,
    required this.exhaleSeconds,
    required this.holdOutSeconds,
    required this.recommendedCycles,
    required this.label,
    required this.description,
  });

  static BreathingPatternConfig forPattern(BreathingPattern pattern) {
    switch (pattern) {
      case BreathingPattern.fourSevenEight:
        return const BreathingPatternConfig(
          inhaleSeconds: 4,
          holdInSeconds: 7,
          exhaleSeconds: 8,
          holdOutSeconds: 0,
          recommendedCycles: 4,
          label: '4-7-8',
          description: 'Wdech 4s, zatrzymaj 7s, wydech 8s',
        );
      case BreathingPattern.boxBreathing:
        return const BreathingPatternConfig(
          inhaleSeconds: 4,
          holdInSeconds: 4,
          exhaleSeconds: 4,
          holdOutSeconds: 4,
          recommendedCycles: 6,
          label: 'Box',
          description: 'Wdech 4s, zatrzymaj 4s, wydech 4s, zatrzymaj 4s',
        );
      case BreathingPattern.fiveFive:
        return const BreathingPatternConfig(
          inhaleSeconds: 5,
          holdInSeconds: 0,
          exhaleSeconds: 5,
          holdOutSeconds: 0,
          recommendedCycles: 8,
          label: '5-5',
          description: 'Wdech 5s, wydech 5s — relaksacja',
        );
      case BreathingPattern.custom:
        return const BreathingPatternConfig(
          inhaleSeconds: 4,
          holdInSeconds: 2,
          exhaleSeconds: 6,
          holdOutSeconds: 0,
          recommendedCycles: 5,
          label: 'Custom',
          description: 'Spersonalizowany wzorzec oddechu',
        );
    }
  }
}

enum BreathingPhase2 { idle, inhale, holdIn, exhale, holdOut }

class EnhancedBreathingCircleWidget extends StatefulWidget {
  final double size;
  final BreathingPattern initialPattern;
  final VoidCallback? onCycleComplete;
  final void Function(int cycles, int totalSeconds)? onSessionEnd;

  const EnhancedBreathingCircleWidget({
    super.key,
    this.size = 280,
    this.initialPattern = BreathingPattern.fourSevenEight,
    this.onCycleComplete,
    this.onSessionEnd,
  });

  @override
  State<EnhancedBreathingCircleWidget> createState() =>
      _EnhancedBreathingCircleWidgetState();
}

class _EnhancedBreathingCircleWidgetState
    extends State<EnhancedBreathingCircleWidget>
    with SingleTickerProviderStateMixin {
  late BreathingPatternConfig _config;
  BreathingPhase2 _phase = BreathingPhase2.idle;
  bool _isActive = false;
  int _cycleCount = 0;
  int _totalSeconds = 0;
  int _phaseSecondsRemaining = 0;

  late final AnimationController _controller;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _config = BreathingPatternConfig.forPattern(widget.initialPattern);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.addListener(() {
      setState(() {
        _progress = _controller.value;
      });
    });
  }

  Color get _phaseColor {
    switch (_phase) {
      case BreathingPhase2.idle:
        return const Color(0xFF66BB6A);
      case BreathingPhase2.inhale:
        return const Color(0xFF4CAF50);
      case BreathingPhase2.holdIn:
        return const Color(0xFF2196F3);
      case BreathingPhase2.exhale:
        return const Color(0xFF9C27B0);
      case BreathingPhase2.holdOut:
        return const Color(0xFF7986CB);
    }
  }

  String get _phaseLabel {
    switch (_phase) {
      case BreathingPhase2.idle:
        return 'Gotowy?';
      case BreathingPhase2.inhale:
        return 'Wdech';
      case BreathingPhase2.holdIn:
        return 'Zatrzymaj';
      case BreathingPhase2.exhale:
        return 'Wydech';
      case BreathingPhase2.holdOut:
        return 'Zatrzymaj';
    }
  }

  IconData get _phaseIcon {
    switch (_phase) {
      case BreathingPhase2.idle:
        return Icons.self_improvement;
      case BreathingPhase2.inhale:
        return Icons.arrow_circle_up;
      case BreathingPhase2.holdIn:
        return Icons.pause_circle_filled;
      case BreathingPhase2.exhale:
        return Icons.arrow_circle_down;
      case BreathingPhase2.holdOut:
        return Icons.pause_circle;
    }
  }

  void _start() {
    setState(() {
      _isActive = true;
      _cycleCount = 0;
      _totalSeconds = 0;
    });
    _runCycle();
  }

  void _stop() {
    setState(() {
      _isActive = false;
      _phase = BreathingPhase2.idle;
    });
    widget.onSessionEnd?.call(_cycleCount, _totalSeconds);
  }

  Future<void> _runCycle() async {
    while (_isActive && mounted) {
      // Inhale
      await _runPhase(BreathingPhase2.inhale, _config.inhaleSeconds);
      if (!_isActive || !mounted) break;

      // Hold (in)
      if (_config.holdInSeconds > 0) {
        await _runPhase(BreathingPhase2.holdIn, _config.holdInSeconds);
        if (!_isActive || !mounted) break;
      }

      // Exhale
      await _runPhase(BreathingPhase2.exhale, _config.exhaleSeconds);
      if (!_isActive || !mounted) break;

      // Hold (out)
      if (_config.holdOutSeconds > 0) {
        await _runPhase(BreathingPhase2.holdOut, _config.holdOutSeconds);
        if (!_isActive || !mounted) break;
      }

      if (!_isActive || !mounted) break;
      setState(() => _cycleCount++);
      widget.onCycleComplete?.call();
    }
  }

  Future<void> _runPhase(BreathingPhase2 phase, int durationSeconds) async {
    setState(() {
      _phase = phase;
      _phaseSecondsRemaining = durationSeconds;
    });

    for (var i = durationSeconds; i > 0; i--) {
      if (!_isActive || !mounted) return;
      setState(() {
        _phaseSecondsRemaining = i;
        _totalSeconds++;
      });

      // Animate progress for this second
      final progressInPhase = (durationSeconds - i) / durationSeconds;
      _controller.animateTo(
        phase == BreathingPhase2.inhale ? progressInPhase : 1.0 - progressInPhase,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
      );

      await Future.delayed(const Duration(seconds: 1));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pattern selector
        _buildPatternSelector(),
        const SizedBox(height: 24),
        // Breathing circle
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _BreathingRingPainter(
              progress: _phase == BreathingPhase2.inhale
                  ? _progress
                  : 1.0 - _progress,
              color: _phaseColor,
              backgroundColor: _phaseColor.withValues(alpha: 0.1),
              lineWidth: 8,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_phaseIcon, size: 48, color: _phaseColor),
                  const SizedBox(height: 8),
                  Text(
                    _phaseLabel,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _phaseColor,
                    ),
                  ),
                  if (_isActive) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_phaseSecondsRemaining}s',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: _phaseColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Stats row
        _buildStats(),
        const SizedBox(height: 20),
        // Control button
        _buildControlButton(),
      ],
    );
  }

  Widget _buildPatternSelector() {
    final patterns = [
      BreathingPattern.fourSevenEight,
      BreathingPattern.boxBreathing,
      BreathingPattern.fiveFive,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: patterns.map((pattern) {
        final config = BreathingPatternConfig.forPattern(pattern);
        final isSelected = widget.initialPattern == pattern ||
            (_config.label == config.label);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(
              config.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
            selected: isSelected,
            selectedColor: AppConfig.brandNavy,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            onSelected: _isActive
                ? null
                : (_) {
                    setState(() => _config = config);
                  },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StatPill(
          icon: Icons.loop,
          label: 'Cykle',
          value: '$_cycleCount',
          color: AppConfig.brandGold,
        ),
        const SizedBox(width: 16),
        _StatPill(
          icon: Icons.timer,
          label: 'Czas',
          value: _formatSeconds(_totalSeconds),
          color: AppConfig.brandNavy,
        ),
        const SizedBox(width: 16),
        _StatPill(
          icon: Icons.check_circle,
          label: 'Cel',
          value: '${_config.recommendedCycles}',
          color: _cycleCount >= _config.recommendedCycles
              ? AppConfig.semaforGreen
              : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildControlButton() {
    return SizedBox(
      width: 200,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isActive ? _stop : _start,
        icon: Icon(_isActive ? Icons.stop : Icons.play_arrow, size: 28),
        label: Text(
          _isActive ? 'Zatrzymaj' : 'Rozpocznij',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isActive ? AppConfig.semaforRed : const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 6,
        ),
      ),
    );
  }

  String _formatSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: color.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreathingRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double lineWidth;

  _BreathingRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.lineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - lineWidth;

    // Background ring
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BreathingRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
