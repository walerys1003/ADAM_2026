import 'package:flutter/material.dart';
import '../../config/app_config.dart';

/// 4-color semafor badge for senior status visualization
class SemaforBadge extends StatelessWidget {
  final String semafor;
  final double size;
  final bool showLabel;

  const SemaforBadge({
    super.key,
    required this.semafor,
    this.size = 16,
    this.showLabel = true,
  });

  Color get _color => Color(AppConfig.semaforColors[semafor] ?? 0xFF4CAF50);

  String get _label {
    switch (semafor) {
      case 'GREEN':
        return 'OK';
      case 'YELLOW':
        return 'UWAGA';
      case 'ORANGE':
        return 'ALERT';
      case 'RED':
        return 'KRYZYS';
      case 'PURPLE':
        return '112';
      default:
        return 'OK';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!showLabel) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _color.withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        _label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
