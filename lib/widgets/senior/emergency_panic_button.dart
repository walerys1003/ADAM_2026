import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Emergency Panic Button Widget
/// Large, animated SOS button with long-press activation (3s hold) to prevent accidental triggers
/// Used across senior-facing screens for quick emergency access
class EmergencyPanicButton extends StatefulWidget {
  final VoidCallback onActivate;
  final double size;
  final bool compact;

  const EmergencyPanicButton({
    super.key,
    required this.onActivate,
    this.size = 80,
    this.compact = false,
  });

  @override
  State<EmergencyPanicButton> createState() => _EmergencyPanicButtonState();
}

class _EmergencyPanicButtonState extends State<EmergencyPanicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late Animation<double> _scaleAnim;

  bool _isHolding = false;
  double _holdProgress = 0.0;
  Timer? _holdTimer;
  Timer? _progressTimer;
  static const _holdDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startHold() {
    setState(() {
      _isHolding = true;
      _holdProgress = 0.0;
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _holdProgress += 0.05 / 3.0;
        if (_holdProgress >= 1.0) {
          _holdProgress = 1.0;
          _activateSOS();
          timer.cancel();
        }
      });
    });

    _holdTimer = Timer(_holdDuration, () {
      _activateSOS();
    });
  }

  void _cancelHold() {
    _progressTimer?.cancel();
    _holdTimer?.cancel();
    setState(() {
      _isHolding = false;
      _holdProgress = 0.0;
    });
  }

  void _activateSOS() {
    _progressTimer?.cancel();
    _holdTimer?.cancel();
    setState(() {
      _isHolding = false;
      _holdProgress = 1.0;
    });
    widget.onActivate();
    // Reset after a moment
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _holdProgress = 0.0);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressTimer?.cancel();
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = widget.size;

    return GestureDetector(
      onLongPressStart: (_) => _startHold(),
      onLongPressEnd: (_) => _cancelHold(),
      onLongPressCancel: _cancelHold,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulse glow ring
                Container(
                  width: buttonSize + 24,
                  height: buttonSize + 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withValues(alpha: _isHolding ? 0.5 : _pulseAnim.value),
                  ),
                ),
                // Main button
                Container(
                  width: buttonSize,
                  height: buttonSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFF44336), Color(0xFFD32F2F)],
                      center: Alignment(-0.3, -0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _SOSLoadingPainter(
                      progress: _holdProgress,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SOS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: buttonSize * 0.35,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          if (!widget.compact && _isHolding)
                            Text(
                              '${(3 - (_holdProgress * 3)).ceil()}s',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SOSLoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _SOSLoadingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(3, 3, size.width - 6, size.height - 6);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SOSLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
