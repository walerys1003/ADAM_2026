import 'package:flutter/material.dart';

/// Admin screen for cost optimization monitoring.
/// Displays June 2026 optimization targets, current spend,
/// and actionable recommendations.
class AdminCostOptimizationScreen extends StatefulWidget {
  const AdminCostOptimizationScreen({super.key});

  @override
  State<AdminCostOptimizationScreen> createState() =>
      _AdminCostOptimizationScreenState();
}

class _AdminCostOptimizationScreenState
    extends State<AdminCostOptimizationScreen> {
  final _costData = CostOptimizationData.sample();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Optymalizacja kosztów'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Eksportuj raport',
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target date banner
            _TargetBanner(theme: theme),
            const SizedBox(height: 24),

            // Budget vs actual gauges
            _BudgetGauges(data: _costData, theme: theme),
            const SizedBox(height: 24),

            // Monthly trend chart placeholder
            _MonthlyTrendCard(theme: theme, data: _costData),
            const SizedBox(height: 24),

            // Cost breakdown by category
            _CostBreakdownCard(theme: theme, data: _costData),
            const SizedBox(height: 24),

            // Optimization recommendations
            Text(
              'Rekomendacje optymalizacji',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._costData.recommendations.map(
              (rec) => _RecommendationCard(recommendation: rec),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetBanner extends StatelessWidget {
  final ThemeData theme;

  const _TargetBanner({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.flag, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Cel optymalizacyjny',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Czerwiec 2026',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Budżet: 1 200 PLN / miesiąc',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetGauges extends StatelessWidget {
  final CostOptimizationData data;
  final ThemeData theme;

  const _BudgetGauges({required this.data, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GaugeCard(
            title: 'Voice AI',
            current: data.voiceCost,
            budget: data.voiceBudget,
            theme: theme,
            icon: Icons.mic,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GaugeCard(
            title: 'Infrastruktura',
            current: data.infraCost,
            budget: data.infraBudget,
            theme: theme,
            icon: Icons.dns,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GaugeCard(
            title: 'Razem',
            current: data.totalCost,
            budget: data.totalBudget,
            theme: theme,
            icon: Icons.account_balance_wallet,
            isTotal: true,
          ),
        ),
      ],
    );
  }
}

class _GaugeCard extends StatelessWidget {
  final String title;
  final double current;
  final double budget;
  final ThemeData theme;
  final IconData icon;
  final bool isTotal;

  const _GaugeCard({
    required this.title,
    required this.current,
    required this.budget,
    required this.theme,
    required this.icon,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = current / budget;
    final color = ratio > 1.0
        ? Colors.red
        : ratio > 0.85
            ? Colors.orange
            : Colors.green;
    final percentage = (ratio * 100).round();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    strokeWidth: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${current.round()} PLN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isTotal ? 18 : 14,
              ),
            ),
            Text(
              '/ ${budget.round()} PLN',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyTrendCard extends StatelessWidget {
  final ThemeData theme;
  final CostOptimizationData data;

  const _MonthlyTrendCard({required this.theme, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trend miesięczny (ostatnie 6 miesięcy)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            // Simple bar chart
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: data.monthlyCosts.asMap().entries.map((entry) {
                  final maxCost = data.monthlyCosts
                      .map((m) => m.cost)
                      .reduce((a, b) => a > b ? a : b);
                  final height = (entry.value.cost / maxCost * 140).clamp(20.0, 140.0);
                  final isOverBudget = entry.value.cost > data.totalBudget;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.value.cost.round()}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isOverBudget ? Colors.red : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: height,
                            decoration: BoxDecoration(
                              color: isOverBudget
                                  ? Colors.red.withValues(alpha: 0.7)
                                  : theme.colorScheme.primary.withValues(alpha: 0.7),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            entry.value.month,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budżet miesięczny',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  '${data.totalBudget.round()} PLN',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CostBreakdownCard extends StatelessWidget {
  final ThemeData theme;
  final CostOptimizationData data;

  const _CostBreakdownCard({required this.theme, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Podział kosztów Voice AI',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _CostRow(
              label: 'Deepgram (STT)',
              cost: data.deepgramCost,
              percentage: 15,
              color: Colors.blue,
            ),
            _CostRow(
              label: 'Gemini Flash (LLM)',
              cost: data.geminiCost,
              percentage: 35,
              color: Colors.purple,
            ),
            _CostRow(
              label: 'OpenAI TTS-1',
              cost: data.ttsCost,
              percentage: 30,
              color: Colors.green,
            ),
            _CostRow(
              label: 'Twilio (Voice)',
              cost: data.twilioCost,
              percentage: 12,
              color: Colors.orange,
            ),
            _CostRow(
              label: 'Pozostałe',
              cost: data.otherCost,
              percentage: 8,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final double cost;
  final int percentage;
  final Color color;

  const _CostRow({
    required this.label,
    required this.cost,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            '${cost.round()} PLN',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '$percentage%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final CostRecommendation recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = recommendation.priority == 'HIGH'
        ? Colors.red
        : recommendation.priority == 'MEDIUM'
            ? Colors.orange
            : Colors.blue;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    recommendation.priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  recommendation.estimatedSavings,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recommendation.title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              recommendation.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data models for the cost optimization screen
class CostOptimizationData {
  final double voiceCost;
  final double voiceBudget;
  final double infraCost;
  final double infraBudget;
  final double totalCost;
  final double totalBudget;
  final double deepgramCost;
  final double geminiCost;
  final double ttsCost;
  final double twilioCost;
  final double otherCost;
  final List<MonthlyCost> monthlyCosts;
  final List<CostRecommendation> recommendations;

  const CostOptimizationData({
    required this.voiceCost,
    required this.voiceBudget,
    required this.infraCost,
    required this.infraBudget,
    required this.totalCost,
    required this.totalBudget,
    required this.deepgramCost,
    required this.geminiCost,
    required this.ttsCost,
    required this.twilioCost,
    required this.otherCost,
    required this.monthlyCosts,
    required this.recommendations,
  });

  factory CostOptimizationData.sample() {
    return CostOptimizationData(
      voiceCost: 890,
      voiceBudget: 900,
      infraCost: 245,
      infraBudget: 300,
      totalCost: 1135,
      totalBudget: 1200,
      deepgramCost: 134,
      geminiCost: 312,
      ttsCost: 267,
      twilioCost: 107,
      otherCost: 70,
      monthlyCosts: [
        const MonthlyCost(month: 'Sty', cost: 1450),
        const MonthlyCost(month: 'Lut', cost: 1380),
        const MonthlyCost(month: 'Mar', cost: 1290),
        const MonthlyCost(month: 'Kwi', cost: 1210),
        const MonthlyCost(month: 'Maj', cost: 1160),
        const MonthlyCost(month: 'Cze', cost: 1135),
      ],
      recommendations: [
        const CostRecommendation(
          title: 'Buforowanie odpowiedzi TTS',
          description: 'Cache często używanych fraz (powitania, przypomnienia) '
              'zmniejszy liczbę wywołań API TTS o ~15%.',
          estimatedSavings: '45 PLN/mies.',
          priority: 'HIGH',
        ),
        const CostRecommendation(
          title: 'Selektywny model LLM',
          description: 'Proste zapytania → Gemini Flash, złożone → Gemini Pro. '
              'Oszczędność ~25% na kosztach LLM.',
          estimatedSavings: '80 PLN/mies.',
          priority: 'HIGH',
        ),
        const CostRecommendation(
          title: 'Kompresja audio Deepgram',
          description: 'Użyj kodeka Opus zamiast PCM dla mniejszych '
              'plików audio wysyłanych do STT.',
          estimatedSavings: '20 PLN/mies.',
          priority: 'MEDIUM',
        ),
        const CostRecommendation(
          title: 'Przetwarzanie batchowe',
          description: 'Przenieś analitykę na godziny nocne '
              '(2:00-4:00) dla niższego zużycia CPU.',
          estimatedSavings: '50 PLN/mies.',
          priority: 'MEDIUM',
        ),
        const CostRecommendation(
          title: 'Optymalizacja zapytań RAG',
          description: 'Zmniejsz rozmiar kontekstu RAG z top-10 do top-5 '
              'dokumentów. Redukcja tokenów LLM ~20%.',
          estimatedSavings: '35 PLN/mies.',
          priority: 'LOW',
        ),
      ],
    );
  }
}

class MonthlyCost {
  final String month;
  final double cost;

  const MonthlyCost({required this.month, required this.cost});
}

class CostRecommendation {
  final String title;
  final String description;
  final String estimatedSavings;
  final String priority; // HIGH, MEDIUM, LOW

  const CostRecommendation({
    required this.title,
    required this.description,
    required this.estimatedSavings,
    required this.priority,
  });
}
