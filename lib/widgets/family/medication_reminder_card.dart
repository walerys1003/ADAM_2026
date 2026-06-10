import 'package:flutter/material.dart';
import '../../models/medication.dart';

/// Card widget for family members to see upcoming medication
/// reminders for their senior. Shows medication name, dosage,
/// time, and adherence status at a glance.
class MedicationReminderCard extends StatelessWidget {
  final Medication medication;
  final bool isAdhered;
  final bool isLate;
  final VoidCallback? onMarkTaken;
  final VoidCallback? onRemind;
  final VoidCallback? onTap;

  const MedicationReminderCard({
    super.key,
    required this.medication,
    this.isAdhered = false,
    this.isLate = false,
    this.onMarkTaken,
    this.onRemind,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _statusColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildStatusIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${medication.dosage ?? ''}  •  ${medication.frequency ?? ''}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medication.timeFormatted,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isAdhered)
                    _ActionButton(
                      icon: Icons.check_circle_outline,
                      label: 'Taken',
                      color: Colors.green,
                      onTap: onMarkTaken,
                    ),
                  const SizedBox(height: 8),
                  _ActionButton(
                    icon: isLate ? Icons.warning_amber : Icons.notifications_outlined,
                    label: 'Remind',
                    color: isLate ? Colors.orange : theme.colorScheme.primary,
                    onTap: onRemind,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _statusColor {
    if (isAdhered) return Colors.green;
    if (isLate) return Colors.orange;
    return Colors.blue;
  }

  Widget _buildStatusIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isAdhered
            ? Icons.check_circle
            : isLate
                ? Icons.access_time
                : Icons.medication_outlined,
        color: _statusColor,
        size: 28,
      ),
    );
  }

}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
