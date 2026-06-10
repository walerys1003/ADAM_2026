import 'package:flutter/material.dart';

/// Reusable empty state widget for screens with no data.
///
/// Displays an icon, title, subtitle, and optional action button.
/// Used across senior, family, and admin screens.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;
  final Color? iconColor;
  final bool compact;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize = 80,
    this.iconColor,
    this.compact = false,
  });

  /// Pre-built "No conversations" state
  factory EmptyStateWidget.noConversations({VoidCallback? onStart}) {
    return EmptyStateWidget(
      icon: Icons.mic_none,
      title: 'Brak rozmów',
      subtitle: 'Rozpocznij rozmowę z Adamem,\naby zobaczyć ją tutaj',
      actionLabel: 'Porozmawiaj z Adamem',
      onAction: onStart,
      iconColor: const Color(0xFF6366F1),
    );
  }

  /// Pre-built "No medications" state
  factory EmptyStateWidget.noMedications({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      icon: Icons.medication_outlined,
      title: 'Brak leków',
      subtitle: 'Dodaj pierwszy lek, aby otrzymywać\nprzypomnienia o dawkach',
      actionLabel: 'Dodaj lek',
      onAction: onAdd,
      iconColor: const Color(0xFF059669),
    );
  }

  /// Pre-built "No health data" state
  factory EmptyStateWidget.noHealthData({VoidCallback? onConnect}) {
    return EmptyStateWidget(
      icon: Icons.favorite_border,
      title: 'Brak danych zdrowotnych',
      subtitle: 'Podłącz opaskę Xiaomi Smart Band 9,\naby śledzić parametry',
      actionLabel: 'Podłącz opaskę',
      onAction: onConnect,
      iconColor: const Color(0xFFDC2626),
    );
  }

  /// Pre-built "No alerts" state
  factory EmptyStateWidget.noAlerts() {
    return EmptyStateWidget(
      icon: Icons.check_circle_outline,
      title: 'Wszystko w porządku',
      subtitle: 'Nie masz żadnych aktywnych alertów.\nTak trzymaj!',
      iconColor: Colors.green,
      compact: true,
    );
  }

  /// Pre-built "No contacts" state
  factory EmptyStateWidget.noContacts({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      icon: Icons.people_outline,
      title: 'Brak kontaktów',
      subtitle: 'Dodaj kontakty alarmowe i bliskich,\naby w razie potrzeby wezwać pomoc',
      actionLabel: 'Dodaj kontakt',
      onAction: onAdd,
      iconColor: const Color(0xFFD97706),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 64 : iconSize + 16,
              height: compact ? 64 : iconSize + 16,
              decoration: BoxDecoration(
                color: (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: compact ? 36 : iconSize,
                color: iconColor ?? theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: compact ? 16 : 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: compact ? 8 : 12),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: compact ? 16 : 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 20),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
