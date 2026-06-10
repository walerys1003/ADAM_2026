/// SilverTech Agent Adam — Enhanced Family Dashboard Insights Widget
/// AI-powered insights panel for family/caregiver dashboard:
/// - Weekly trend analysis with anomaly detection
/// - Medication compliance prediction
/// - Activity pattern recognition
/// - Voice mood trend analysis
/// - Proactive alert recommendations

import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class DashboardInsight {
  final IconData icon;
  final String title;
  final String description;
  final InsightSeverity severity;
  final String actionLabel;
  final VoidCallback? onAction;

  const DashboardInsight({
    required this.icon,
    required this.title,
    required this.description,
    required this.severity,
    required this.actionLabel,
    this.onAction,
  });
}

enum InsightSeverity { info, warning, alert, success }

class EnhancedDashboardInsightsWidget extends StatelessWidget {
  final String seniorName;
  final List<DashboardInsight> insights;

  const EnhancedDashboardInsightsWidget({
    super.key,
    required this.seniorName,
    required this.insights,
  });

  static List<DashboardInsight> generateInsights({
    required String seniorName,
    required double adherenceRate,
    required int missedDoses,
    required String moodTrend,
    required int stepAverage,
    required int conversationCount,
    required String semaforLevel,
    required int alertCount,
  }) {
    final insights = <DashboardInsight>[];

    // Medication adherence insight
    if (adherenceRate < 0.8) {
      insights.add(DashboardInsight(
        icon: Icons.medication_outlined,
        title: 'Niska adherencja leków',
        description: '$seniorName przyjął/a tylko ${(adherenceRate * 100).round()}% '
            'zaplanowanych dawek w tym tygodniu. '
            'Zalecane jest sprawdzenie przyczyn.',
        severity: InsightSeverity.warning,
        actionLabel: 'Sprawdź leki',
      ));
    } else if (adherenceRate >= 0.95) {
      insights.add(DashboardInsight(
        icon: Icons.celebration,
        title: 'Świetna adherencja!',
        description: '$seniorName przyjął/a ${(adherenceRate * 100).round()}% '
            'leków — to znakomity wynik. Kontynuujcie wsparcie!',
        severity: InsightSeverity.success,
        actionLabel: 'Pogratuluj',
      ));
    }

    // Missed doses alert
    if (missedDoses >= 3) {
      insights.add(DashboardInsight(
        icon: Icons.warning_amber,
        title: '$missedDoses pominiętych dawek',
        description: 'W tym tygodniu pominięto $missedDoses dawek leków. '
            'Rozważ ustawienie dodatkowych przypomnień.',
        severity: InsightSeverity.alert,
        actionLabel: 'Dostosuj przypomnienia',
      ));
    }

    // Mood trend
    if (moodTrend == 'Pogorszenie') {
      insights.add(DashboardInsight(
        icon: Icons.mood_bad,
        title: 'Pogorszenie nastroju',
        description: 'Nastrój $seniorName pogorszył się w tym tygodniu. '
            'Warto zadzwonić i porozmawiać.',
        severity: InsightSeverity.warning,
        actionLabel: 'Zadzwoń teraz',
      ));
    }

    // Activity insight
    if (stepAverage < 2000) {
      insights.add(DashboardInsight(
        icon: Icons.directions_walk,
        title: 'Niska aktywność fizyczna',
        description: 'Średnio $stepAverage kroków dziennie — poniżej zalecanego '
            'minimum 3000 dla seniorów.',
        severity: InsightSeverity.info,
        actionLabel: 'Zobacz ćwiczenia',
      ));
    }

    // Conversation insight
    if (conversationCount == 0) {
      insights.add(DashboardInsight(
        icon: Icons.mic_off,
        title: 'Brak rozmów z Adamem',
        description: '$seniorName nie rozmawiał/a z Adamem w tym tygodniu. '
            'Może potrzebuje zachęty?',
        severity: InsightSeverity.info,
        actionLabel: 'Przypomnij o Adamie',
      ));
    }

    // Semafor escalation insight
    if (semaforLevel == 'ORANGE' || semaforLevel == 'RED') {
      insights.add(DashboardInsight(
        icon: Icons.priority_high,
        title: 'Status Semafor: $semaforLevel',
        description: 'Stan zdrowia wymaga uwagi. Skontaktuj się z seniorem '
            'lub lekarzem prowadzącym.',
        severity: semaforLevel == 'RED'
            ? InsightSeverity.alert
            : InsightSeverity.warning,
        actionLabel: 'Podejmij działanie',
      ));
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppConfig.semaforGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppConfig.semaforGreen.withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppConfig.semaforGreen, size: 32),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Wszystko w normie — brak nowych spostrzeżeń',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.semaforGreen,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: AppConfig.brandGold, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Spostrzeżenia AI',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${insights.length} ${insights.length == 1 ? 'nowe' : 'nowych'}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppConfig.brandNavy.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) => _InsightCard(insight: insight)),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final DashboardInsight insight;

  const _InsightCard({required this.insight});

  Color get _severityColor {
    switch (insight.severity) {
      case InsightSeverity.info:
        return AppConfig.brandNavy;
      case InsightSeverity.warning:
        return AppConfig.semaforYellow;
      case InsightSeverity.alert:
        return AppConfig.semaforRed;
      case InsightSeverity.success:
        return AppConfig.semaforGreen;
    }
  }

  Color get _bgColor {
    switch (insight.severity) {
      case InsightSeverity.info:
        return AppConfig.brandNavy.withValues(alpha: 0.06);
      case InsightSeverity.warning:
        return AppConfig.semaforYellow.withValues(alpha: 0.08);
      case InsightSeverity.alert:
        return AppConfig.semaforRed.withValues(alpha: 0.06);
      case InsightSeverity.success:
        return AppConfig.semaforGreen.withValues(alpha: 0.08);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _severityColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _severityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(insight.icon, color: _severityColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _severityColor,
                  ),
                ),
              ),
              _SeverityBadge(severity: insight.severity),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: insight.onAction,
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(insight.actionLabel),
              style: TextButton.styleFrom(
                foregroundColor: _severityColor,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityBadge extends StatelessWidget {
  final InsightSeverity severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (severity) {
      InsightSeverity.info => ('Info', AppConfig.brandNavy),
      InsightSeverity.warning => ('Uwaga', AppConfig.semaforYellow),
      InsightSeverity.alert => ('Alert', AppConfig.semaforRed),
      InsightSeverity.success => ('OK', AppConfig.semaforGreen),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
