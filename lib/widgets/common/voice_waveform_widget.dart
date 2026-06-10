import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable Voice Waveform Animation Widget
/// 60-bar animated waveform with sinusoidal modulation, color & size configurable
class VoiceWaveformWidget extends StatefulWidget {
  final double height;
  final Color activeColor;
  final Color idleColor;
  final int barCount;
  final bool isActive;
  final double amplitude;

  const VoiceWaveformWidget({
    super.key,
    this.height = 80,
    this.activeColor = const Color(0xFF4CAF50),
    this.idleColor = const Color(0xFFBDBDBD),
    this.barCount = 60,
    this.isActive = false,
    this.amplitude = 1.0,
  });

  @override
  State<VoiceWaveformWidget> createState() => _VoiceWaveformWidgetState();
}

class _VoiceWaveformWidgetState extends State<VoiceWaveformWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size(double.infinity, widget.height),
          painter: _WaveformPainter(
            progress: _controller.value,
            isActive: widget.isActive,
            activeColor: widget.activeColor,
            idleColor: widget.idleColor,
            barCount: widget.barCount,
            amplitude: widget.amplitude,
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final bool isActive;
  final Color activeColor;
  final Color idleColor;
  final int barCount;
  final double amplitude;

  _WaveformPainter({
    required this.progress,
    required this.isActive,
    required this.activeColor,
    required this.idleColor,
    required this.barCount,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / barCount;
    final centerY = size.height / 2;

    for (var i = 0; i < barCount; i++) {
      final x = i * barWidth + barWidth / 2;
      final normProgress = (progress + i * 0.05) % 1.0;

      double barAmplitude;
      if (isActive) {
        barAmplitude = (math.sin(normProgress * math.pi * 2) * 0.5 + 0.5) * centerY * 0.85 * amplitude;
        barAmplitude += math.sin((progress * 3 + i * 0.3)) * 8 * amplitude;
      } else {
        barAmplitude = 3.0;
      }

      final alpha = isActive ? 0.4 + (barAmplitude / centerY) * 0.6 : 0.2;
      paint.color = (isActive ? activeColor : idleColor).withValues(alpha: alpha);

      final barRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, centerY), width: barWidth * 0.6, height: barAmplitude * 2 + 2),
        const Radius.circular(2),
      );
      canvas.drawRRect(barRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.isActive != isActive ||
      oldDelegate.amplitude != amplitude;
}
