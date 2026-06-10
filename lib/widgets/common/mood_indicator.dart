import 'package:flutter/material.dart';

class MoodIndicator extends StatelessWidget {
  final int moodScore; // 1-5
  final double size;

  const MoodIndicator({
    super.key,
    required this.moodScore,
    this.size = 32,
  });

  String get _emoji {
    switch (moodScore) {
      case 5:
        return '😊';
      case 4:
        return '🙂';
      case 3:
        return '😐';
      case 2:
        return '😕';
      case 1:
        return '😢';
      default:
        return '😐';
    }
  }

  Color get _color {
    switch (moodScore) {
      case 5:
        return const Color(0xFF4CAF50);
      case 4:
        return const Color(0xFF8BC34A);
      case 3:
        return const Color(0xFFFFC107);
      case 2:
        return const Color(0xFFFF9800);
      case 1:
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          _emoji,
          style: TextStyle(fontSize: size * 0.55),
        ),
      ),
    );
  }
}
