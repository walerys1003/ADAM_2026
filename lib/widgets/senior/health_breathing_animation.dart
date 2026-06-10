import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Health Breathing Animation Widget
/// Animated lung/heart visualization that reflects health state
/// Used on senior health dashboard and wellness screen
class HealthBreathingAnimation extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final AnimationType type;
  final bool isActive;
  final double healthScore; // 0.0 - 1.0

  const HealthBreathingAnimation({
    super.key,
    this.size = 120,
    this.primaryColor = const Color(0xFF4CAF50),
    this.type = AnimationType.heart,
    this.isActive = true,
    this.healthScore = 0.8,
  });

  @override
  State<HealthBreathingAnimation> createState() =>
      _HealthBreathingAnimationState();
}

enum AnimationType { heart, lungs, circle }

class _HealthBreathingAnimationState extends State<HealthBreathingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breatheAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _breatheAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _healthColor {
    if (widget.healthScore >= 0.8) return const Color(0xFF4CAF50);
    if (widget.healthScore >= 0.5) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breatheAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isActive ? _breatheAnim.value : 1.0,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: widget.type == AnimationType.heart
                ? _HeartPainter(
                    color: _healthColor,
                    healthScore: widget.healthScore,
                  )
                : widget.type == AnimationType.lungs
                    ? _LungsPainter(
                        color: _healthColor,
                        healthScore: widget.healthScore,
                      )
                    : _CirclePainter(
                        color: _healthColor,
                        healthScore: widget.healthScore,
                      ),
          ),
        );
      },
    );
  }
}

class _HeartPainter extends CustomPainter {
  final Color color;
  final double healthScore;

  _HeartPainter({required this.color, required this.healthScore});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = _buildHeartPath(size);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, strokePaint);

    // Inner glow
    final innerPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final innerScale = 0.6 + (healthScore * 0.2);
    final innerSize = Size(size.width * innerScale, size.height * innerScale);
    final innerPath = _buildHeartPath(innerSize);
    canvas.save();
    canvas.translate(
      (size.width - innerSize.width) / 2,
      (size.height - innerSize.height) / 2,
    );
    canvas.drawPath(innerPath, innerPaint);
    canvas.restore();
  }

  Path _buildHeartPath(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(w / 2, h * 0.3);
    path.cubicTo(w / 2, h * 0.15, w * 0.75, h * 0.1, w * 0.85, h * 0.3);
    path.cubicTo(w * 0.95, h * 0.5, w / 2, h * 0.85, w / 2, h * 0.85);
    path.cubicTo(w / 2, h * 0.85, w * 0.05, h * 0.5, w * 0.15, h * 0.3);
    path.cubicTo(w * 0.25, h * 0.1, w / 2, h * 0.15, w / 2, h * 0.3);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _HeartPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.healthScore != healthScore;
}

class _LungsPainter extends CustomPainter {
  final Color color;
  final double healthScore;

  _LungsPainter({required this.color, required this.healthScore});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    // Left lung
    final leftPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..cubicTo(size.width * 0.35, size.height * 0.15, size.width * 0.15,
          size.height * 0.35, size.width * 0.2, size.height * 0.55)
      ..cubicTo(size.width * 0.25, size.height * 0.75, size.width * 0.45,
          size.height * 0.85, size.width * 0.5, size.height * 0.95);
    canvas.drawPath(leftPath, paint);

    // Right lung
    final rightPath = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..cubicTo(size.width * 0.65, size.height * 0.15, size.width * 0.85,
          size.height * 0.35, size.width * 0.8, size.height * 0.55)
      ..cubicTo(size.width * 0.75, size.height * 0.75, size.width * 0.55,
          size.height * 0.85, size.width * 0.5, size.height * 0.95);
    canvas.drawPath(rightPath, paint);

    // Health indicator: inner fill
    final innerPaint = Paint()
      ..color = color.withValues(alpha: 0.2 * healthScore)
      ..style = PaintingStyle.fill;

    canvas.drawPath(leftPath, innerPaint);
    canvas.drawPath(rightPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _LungsPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.healthScore != healthScore;
}

class _CirclePainter extends CustomPainter {
  final Color color;
  final double healthScore;

  _CirclePainter({required this.color, required this.healthScore});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer ring
    final outerPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, outerPaint);

    // Progress arc
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      2 * math.pi * healthScore,
      false,
      arcPaint,
    );

    // Center text area
    final textPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.55, textPaint);
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.healthScore != healthScore;
}
