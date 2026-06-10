import 'package:flutter/material.dart';

/// Large-touch-target grid of quick actions for senior home screen.
/// Each action has a large icon, bold label, and optional badge.
/// Designed for accessibility — minimum 56dp touch target.
class QuickActionGrid extends StatelessWidget {
  final List<QuickAction> actions;
  final int crossAxisCount;
  final double iconSize;

  const QuickActionGrid({
    super.key,
    required this.actions,
    this.crossAxisCount = 2,
    this.iconSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = 12.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: 1.1,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        return _QuickActionTile(
          action: actions[index],
          iconSize: iconSize,
        );
      },
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final QuickAction action;
  final double iconSize;

  const _QuickActionTile({
    required this.action,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: action.backgroundColor ?? theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      elevation: action.elevation,
      shadowColor: action.shadowColor,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: (action.iconBackgroundColor ??
                              theme.colorScheme.primary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      action.icon,
                      size: iconSize,
                      color: action.iconColor ?? theme.colorScheme.primary,
                    ),
                  ),
                  if (action.badge != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: action.badgeColor ?? Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          action.badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                action.label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (action.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  action.subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Model for a quick action tile
class QuickAction {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? badge;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? backgroundColor;
  final Color? badgeColor;
  final double elevation;
  final Color? shadowColor;

  const QuickAction({
    required this.icon,
    required this.label,
    this.subtitle,
    this.badge,
    this.onTap,
    this.iconColor,
    this.iconBackgroundColor,
    this.backgroundColor,
    this.badgeColor,
    this.elevation = 2.0,
    this.shadowColor,
  });

  /// Pre-built senior home screen actions
  static List<QuickAction> defaultSeniorActions({
    VoidCallback? onVoiceChat,
    VoidCallback? onMedications,
    VoidCallback? onContacts,
    VoidCallback? onHealth,
    VoidCallback? onWellness,
    VoidCallback? onSettings,
  }) {
    return [
      QuickAction(
        icon: Icons.mic,
        label: 'Porozmawiaj\nz Adamem',
        subtitle: 'Asystent głosowy',
        iconColor: Colors.white,
        iconBackgroundColor: const Color(0xFF6366F1),
        backgroundColor: const Color(0xFFEEF2FF),
        onTap: onVoiceChat,
      ),
      QuickAction(
        icon: Icons.medication_outlined,
        label: 'Leki',
        subtitle: 'Przypomnienia',
        iconColor: const Color(0xFF059669),
        iconBackgroundColor: const Color(0xFF059669),
        backgroundColor: const Color(0xFFECFDF5),
        onTap: onMedications,
      ),
      QuickAction(
        icon: Icons.people_outline,
        label: 'Kontakty',
        subtitle: 'Bliscy i pomoc',
        iconColor: const Color(0xFFD97706),
        iconBackgroundColor: const Color(0xFFD97706),
        backgroundColor: const Color(0xFFFFFBEB),
        onTap: onContacts,
      ),
      QuickAction(
        icon: Icons.favorite_border,
        label: 'Zdrowie',
        subtitle: 'Parametry i trendy',
        iconColor: const Color(0xFFDC2626),
        iconBackgroundColor: const Color(0xFFDC2626),
        backgroundColor: const Color(0xFFFEF2F2),
        onTap: onHealth,
      ),
      QuickAction(
        icon: Icons.self_improvement,
        label: 'Wellness',
        subtitle: 'Oddech i nastrój',
        iconColor: const Color(0xFF7C3AED),
        iconBackgroundColor: const Color(0xFF7C3AED),
        backgroundColor: const Color(0xFFF5F3FF),
        onTap: onWellness,
      ),
      QuickAction(
        icon: Icons.settings_outlined,
        label: 'Ustawienia',
        subtitle: 'Dostosuj aplikację',
        iconColor: Colors.grey.shade700,
        iconBackgroundColor: Colors.grey.shade600,
        backgroundColor: Colors.grey.shade100,
        onTap: onSettings,
      ),
    ];
  }
}
