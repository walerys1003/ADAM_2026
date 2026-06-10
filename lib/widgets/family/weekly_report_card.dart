import 'package:flutter/material.dart';

/// Weekly report card for family dashboard.
///
/// Shows a summary of the senior's week:
/// - Mood trend
/// - Medication adherence
/// - Activity level
/// - Voice conversations count
/// - Alert summary
class WeeklyReportCard extends StatelessWidget {
  final String seniorName;
  final DateTime weekStart;
  final DateTime weekEnd;
  final String moodTrend;
  final double adherenceRate;
  final int stepAverage;
  final int conversationCount;
  final int alertCount;
  final String semaforLevel;
  final VoidCallback? onViewDetails;

  const WeeklyReportCard({
    super.key,
    required this.seniorName,
    required this.weekStart,
    required this.weekEnd,
    required this.moodTrend,
    required this.adherenceRate,
    required this.stepAverage,
    required this.conversationCount,
    required this.alertCount,
    required this.semaforLevel,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: _semaforColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Raport tygodniowy',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${seniorName}  •  ${_formatDateRange()}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _semaforColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _semaforColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        semaforLevel,
                        style: TextStyle(
                          color: _semaforColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.mood,
                    label: 'Nastrój',
                    value: moodTrend,
                    color: _moodColor,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.medication_outlined,
                    label: 'Leki',
                    value: '${(adherenceRate * 100).round()}%',
                    color: _adherenceColor,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.directions_walk,
                    label: 'Kroki/ dzień',
                    value: '$stepAverage',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.mic,
                    label: 'Rozmowy',
                    value: '$conversationCount',
                    color: const Color(0xFF6366F1),
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.warning_amber,
                    label: 'Alerty',
                    value: '$alertCount',
                    color: alertCount > 0 ? Colors.orange : Colors.green,
                  ),
                ),
                const Expanded(child: SizedBox()),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // View details button
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onViewDetails,
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('Zobacz szczegółowy raport'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _semaforColor {
    switch (semaforLevel.toUpperCase()) {
      case 'GREEN': return Colors.green;
      case 'YELLOW': return Colors.amber;
      case 'ORANGE': return Colors.orange;
      case 'RED': return Colors.red;
      case 'PURPLE': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Color get _moodColor {
    switch (moodTrend) {
      case 'Poprawa': return Colors.green;
      case 'Stabilny': return Colors.blue;
      case 'Pogorszenie': return Colors.red;
      default: return Colors.grey;
    }
  }

  Color get _adherenceColor {
    if (adherenceRate >= 0.9) return Colors.green;
    if (adherenceRate >= 0.7) return Colors.orange;
    return Colors.red;
  }

  String _formatDateRange() {
    final months = ['sty', 'lut', 'mar', 'kwi', 'maj', 'cze',
        'lip', 'sie', 'wrz', 'paź', 'lis', 'gru'];
    return '${weekStart.day} ${months[weekStart.month - 1]} – '
        '${weekEnd.day} ${months[weekEnd.month - 1]}';
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
