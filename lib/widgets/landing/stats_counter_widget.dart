import 'package:flutter/material.dart';

/// Animated statistics counter for the landing page.
///
/// Displays platform statistics with animated number counting
/// when the widget scrolls into view.
class StatsCounterWidget extends StatefulWidget {
  final List<StatItem> stats;

  const StatsCounterWidget({
    super.key,
    this.stats = defaultStats,
  });

  @override
  State<StatsCounterWidget> createState() => _StatsCounterWidgetState();
}

class _StatsCounterWidgetState extends State<StatsCounterWidget> {
  bool _hasAnimated = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Start animation on first build
    if (!_hasAnimated) {
      _hasAnimated = true;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 40 : 60,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.05),
            theme.colorScheme.secondary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        children: widget.stats.map((stat) {
          return SizedBox(
            width: isMobile ? 140 : 200,
            child: _AnimatedStatItem(stat: stat),
          );
        }).toList(),
      ),
    );
  }
}

class _AnimatedStatItem extends StatefulWidget {
  final StatItem stat;

  const _AnimatedStatItem({required this.stat});

  @override
  State<_AnimatedStatItem> createState() => _AnimatedStatItemState();
}

class _AnimatedStatItemState extends State<_AnimatedStatItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final displayValue = (widget.stat.value * _animation.value).round();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.stat.icon,
              size: 40,
              color: widget.stat.iconColor,
            ),
            const SizedBox(height: 12),
            Text(
              '$displayValue${widget.stat.suffix}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: widget.stat.iconColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.stat.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}

/// Statistics item for the counter
class StatItem {
  final IconData icon;
  final int value;
  final String suffix;
  final String label;
  final Color iconColor;

  const StatItem({
    required this.icon,
    required this.value,
    required this.suffix,
    required this.label,
    required this.iconColor,
  });
}

/// Default platform statistics
const List<StatItem> defaultStats = [
  StatItem(
    icon: Icons.people,
    value: 2500,
    suffix: '+',
    label: 'Aktywnych\nSeniorów',
    iconColor: Color(0xFF6366F1),
  ),
  StatItem(
    icon: Icons.mic,
    value: 150000,
    suffix: '+',
    label: 'Rozmów\nGłosowych',
    iconColor: Color(0xFFDC2626),
  ),
  StatItem(
    icon: Icons.favorite,
    value: 98,
    suffix: '%',
    label: 'Zadowolonych\nUżytkowników',
    iconColor: Color(0xFF059669),
  ),
  StatItem(
    icon: Icons.star,
    value: 96,
    suffix: '%',
    label: 'Terminowo\nPrzyjętych Leków',
    iconColor: Color(0xFFD97706),
  ),
  StatItem(
    icon: Icons.shield,
    value: 100,
    suffix: '%',
    label: 'Zgodność\nz RODO',
    iconColor: Color(0xFF7C3AED),
  ),
];
