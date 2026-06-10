import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Weekly medication adherence visualization.
///
/// Shows a 7-day circle chart where each day is a colored segment.
/// Green = taken on time, Yellow = taken late, Red = missed, Grey = future.
class MedicationAdherenceChart extends StatelessWidget {
  final List<DayAdherence> adherenceData;
  final double size;
  final double strokeWidth;

  const MedicationAdherenceChart({
    super.key,
    required this.adherenceData,
    this.size = 160,
    this.strokeWidth = 20,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final takenCount = adherenceData.where((d) => d.status == AdherenceStatus.taken).length;
    final lateCount = adherenceData.where((d) => d.status == AdherenceStatus.late).length;
    final missedCount = adherenceData.where((d) => d.status == AdherenceStatus.missed).length;
    final totalTracked = takenCount + lateCount + missedCount;
    final adherenceRate = totalTracked > 0 ? takenCount / totalTracked : 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(size, size),
                  painter: _AdherenceCirclePainter(
                    adherenceData: adherenceData,
                    strokeWidth: strokeWidth,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(adherenceRate * 100).round()}%',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getRateColor(adherenceRate),
                      ),
                    ),
                    Text(
                      'adherencji',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildLegend(theme),
        ],
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: Colors.green, label: 'Zażyto'),
        const SizedBox(width: 16),
        _LegendItem(color: Colors.orange, label: 'Opóźnienie'),
        const SizedBox(width: 16),
        _LegendItem(color: Colors.red, label: 'Pominięto'),
      ],
    );
  }

  Color _getRateColor(double rate) {
    if (rate >= 0.9) return Colors.green;
    if (rate >= 0.7) return Colors.orange;
    return Colors.red;
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _AdherenceCirclePainter extends CustomPainter {
  final List<DayAdherence> adherenceData;
  final double strokeWidth;

  _AdherenceCirclePainter({
    required this.adherenceData,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final segmentAngle = (2 * math.pi) / 7;
    final gapAngle = 0.04; // Small gap between segments

    for (int i = 0; i < 7; i++) {
      final day = adherenceData.length > i
          ? adherenceData[i]
          : DayAdherence(
              day: _dayName(i),
              status: AdherenceStatus.future,
            );

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = _getSegmentColor(day.status);

      final startAngle = -math.pi / 2 + i * segmentAngle + gapAngle;
      final sweepAngle = segmentAngle - gapAngle * 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      // Draw day label outside the circle
      final labelAngle = startAngle + sweepAngle / 2;
      final labelRadius = radius + strokeWidth + 14;
      final labelPos = Offset(
        center.dx + labelRadius * math.cos(labelAngle),
        center.dy + labelRadius * math.sin(labelAngle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: day.day.substring(0, 2),
          style: TextStyle(
            color: _getSegmentColor(day.status),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          labelPos.dx - textPainter.width / 2,
          labelPos.dy - textPainter.height / 2,
        ),
      );
    }
  }

  Color _getSegmentColor(AdherenceStatus status) {
    switch (status) {
      case AdherenceStatus.taken:
        return Colors.green;
      case AdherenceStatus.late:
        return Colors.orange;
      case AdherenceStatus.missed:
        return Colors.red;
      case AdherenceStatus.future:
        return Colors.grey.shade300;
    }
  }

  @override
  bool shouldRepaint(covariant _AdherenceCirclePainter oldDelegate) {
    return oldDelegate.adherenceData != adherenceData;
  }

  String _dayName(int index) {
    const days = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];
    return days[index % 7];
  }
}

/// Day-by-day medication adherence record
class DayAdherence {
  final String day;
  final AdherenceStatus status;
  final DateTime? takenAt;

  const DayAdherence({
    required this.day,
    required this.status,
    this.takenAt,
  });
}

enum AdherenceStatus { taken, late, missed, future }

/// Generate sample adherence data for the past 7 days
List<DayAdherence> generateSampleAdherence() {
  final now = DateTime.now();
  final days = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];

  return List.generate(7, (index) {
    final dayIndex = (now.weekday - 1 - (6 - index)) % 7;
    final normalizedIndex = dayIndex < 0 ? dayIndex + 7 : dayIndex;
    final date = now.subtract(Duration(days: 6 - index));

    // Weighted random: mostly taken, occasional late/missed
    final rand = (math.sin(index * 3.7) + 1) / 2; // Deterministic but varied

    AdherenceStatus status;
    if (date.isAfter(now)) {
      status = AdherenceStatus.future;
    } else if (rand > 0.8) {
      status = AdherenceStatus.missed;
    } else if (rand > 0.6) {
      status = AdherenceStatus.late;
    } else {
      status = AdherenceStatus.taken;
    }

    return DayAdherence(
      day: days[normalizedIndex % 7],
      status: status,
      takenAt: status != AdherenceStatus.future ? date : null,
    );
  });
}
