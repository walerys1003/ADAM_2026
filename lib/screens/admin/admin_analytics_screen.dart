import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../widgets/common/stat_card.dart';

class AdminAnalyticsScreen extends StatelessWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Analityka', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Kluczowe metryki i SROI', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 24),

          // ── Key Metrics ──
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              StatCard(title: 'Rozmowy/miesiąc', value: '10,800', icon: Icons.phone_in_talk, color: AppTheme.navy),
              StatCard(title: 'Śr. długość', value: '5.4 min', icon: Icons.timer, color: const Color(0xFF1976D2)),
              StatCard(title: 'Śr. nastrój', value: '4.2/5', icon: Icons.mood, color: AppTheme.green),
              StatCard(title: 'Adherencja leków', value: '92%', icon: Icons.medical_services, color: AppTheme.gold),
            ],
          ),
          const SizedBox(height: 24),

          // ── Cost Analysis ──
          _buildCostAnalysis(),
          const SizedBox(height: 24),

          // ── Mood Trend ──
          _buildMoodTrend(),
          const SizedBox(height: 24),

          // ── SROI Calculator ──
          _buildSROICalculator(),
          const SizedBox(height: 24),

          // ── Package Distribution ──
          _buildPackageDistribution(),
        ],
      ),
    );
  }

  Widget _buildCostAnalysis() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Analiza kosztów', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Koszt jednostkowy rozmowy: \$0.114 (ok. 0.45 zł)', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(value: 11.4, color: const Color(0xFF1565C0), title: 'Telekom\n\$0.013', radius: 60, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                        PieChartSectionData(value: 22.7, color: const Color(0xFF1976D2), title: 'STT\n\$0.026', radius: 55, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                        PieChartSectionData(value: 4.4, color: const Color(0xFF42A5F5), title: 'LLM\n\$0.005', radius: 50, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                        PieChartSectionData(value: 56.8, color: AppTheme.gold, title: 'TTS\n\$0.065', radius: 65, titleStyle: const TextStyle(fontSize: 10, color: AppTheme.navy)),
                        PieChartSectionData(value: 4.7, color: const Color(0xFF90CAF9), title: 'Infra\n\$0.005', radius: 48, titleStyle: const TextStyle(fontSize: 10, color: Colors.white)),
                      ],
                      centerSpaceRadius: 35,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CostLegend(color: Color(0xFF1565C0), label: 'Telekomunikacja (Twilio)', cost: '\$0.013', pct: '11.4%'),
                    _CostLegend(color: Color(0xFF1976D2), label: 'Speech-to-Text (Deepgram)', cost: '\$0.026', pct: '22.7%'),
                    _CostLegend(color: Color(0xFF42A5F5), label: 'LLM (Gemini Flash)', cost: '\$0.005', pct: '4.4%'),
                    _CostLegend(color: AppTheme.gold, label: 'Text-to-Speech (OpenAI)', cost: '\$0.065', pct: '56.8%'),
                    _CostLegend(color: Color(0xFF90CAF9), label: 'Infrastruktura', cost: '\$0.005', pct: '4.7%'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              const _TotalCost(label: 'Miesięcznie (180 seniorów)', value: '\$1,231'),
              const SizedBox(width: 32),
              const _TotalCost(label: 'Na seniora/miesiąc', value: '\$7.18 (29 zł)'),
              const SizedBox(width: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('28% taniej niż dokument źródłowy', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.green)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTrend() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Trend nastroju (30 dni)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 4.0), const FlSpot(5, 4.1), const FlSpot(10, 3.8),
                      const FlSpot(15, 4.3), const FlSpot(20, 4.5), const FlSpot(25, 4.2),
                      const FlSpot(30, 4.4),
                    ],
                    isCurved: true,
                    color: AppTheme.gold,
                    barWidth: 3,
                    belowBarData: BarAreaData(show: true, color: AppTheme.gold.withValues(alpha: 0.15)),
                    dotData: const FlDotData(show: true),
                  ),
                ],
                minY: 3.0, maxY: 5.0,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _moodLegend('😊', 'B. dobry', const Color(0xFF4CAF50), '32%'),
              const SizedBox(width: 16),
              _moodLegend('🙂', 'Dobry', const Color(0xFF8BC34A), '38%'),
              const SizedBox(width: 16),
              _moodLegend('😐', 'Neutralny', const Color(0xFFFFC107), '18%'),
              const SizedBox(width: 16),
              _moodLegend('😕', 'Zły', const Color(0xFFFF9800), '8%'),
              const SizedBox(width: 16),
              _moodLegend('😢', 'B. zły', const Color(0xFFF44336), '4%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _moodLegend(String emoji, String label, Color color, String pct) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        Text(pct, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildSROICalculator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppTheme.navy, Color(0xFF2A5078)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.gold, size: 24),
              SizedBox(width: 10),
              Text('SROI - Społeczny Zwrot z Inwestycji', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _sroiMetric('SROI Ratio', '4.7x', 'Każda 1 zł inwestycji generuje 4.70 zł wartości społecznej'),
              const SizedBox(width: 24),
              _sroiMetric('Wartość społeczna', '2,350,000 zł', 'Roczna wartość społeczna'),
              const SizedBox(width: 24),
              _sroiMetric('Inwestycja', '500,000 zł', 'Roczny koszt programu'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kluczowe komponenty wartości społecznej:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                SizedBox(height: 8),
                _SROIItem('Redukcja hospitalizacji (wczesne wykrycie)', '850,000 zł'),
                _SROIItem('Poprawa jakości życia seniorów', '650,000 zł'),
                _SROIItem('Spokój rodzin (redukcja stresu)', '450,000 zł'),
                _SROIItem('Wydłużenie samodzielnego życia', '400,000 zł'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sroiMetric(String label, String value, String description) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.gold)),
          const SizedBox(height: 4),
          Text(description, style: const TextStyle(fontSize: 12, color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _buildPackageDistribution() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dystrybucja pakietów', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(value: 50, color: const Color(0xFF4CAF50), title: 'KONTAKT\n50%', radius: 65, titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
                        PieChartSectionData(value: 35, color: AppTheme.navy, title: 'ZDROWIE\n35%', radius: 60, titleStyle: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w700)),
                        PieChartSectionData(value: 15, color: AppTheme.gold, title: 'AKTYWNY\n15%', radius: 55, titleStyle: const TextStyle(fontSize: 12, color: AppTheme.navy, fontWeight: FontWeight.w700)),
                      ],
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              const Expanded(
                child: Column(
                  children: [
                    _PackageLegend(color: Color(0xFF4CAF50), name: 'KONTAKT', price: '99 zł/mc', count: '90 seniorów', revenue: '8,910 zł/mc'),
                    SizedBox(height: 16),
                    _PackageLegend(color: AppTheme.navy, name: 'ZDROWIE', price: '199 zł/mc', count: '63 seniorów', revenue: '12,537 zł/mc'),
                    SizedBox(height: 16),
                    _PackageLegend(color: AppTheme.gold, name: 'AKTYWNY', price: '299 zł/mc', count: '27 seniorów', revenue: '8,073 zł/mc'),
                    SizedBox(height: 16),
                    Divider(),
                    SizedBox(height: 8),
                    _PackageLegend(color: Colors.transparent, name: 'RAZEM', price: '', count: '180 seniorów', revenue: '29,520 zł/mc', bold: true),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CostLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String cost;
  final String pct;

  const _CostLegend({required this.color, required this.label, required this.cost, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text(cost, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(pct, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

class _TotalCost extends StatelessWidget {
  final String label;
  final String value;

  const _TotalCost({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.navy)),
      ],
    );
  }
}

class _SROIItem extends StatelessWidget {
  final String label;
  final String value;

  const _SROIItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check, color: AppTheme.gold, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.white))),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.gold)),
        ],
      ),
    );
  }
}

class _PackageLegend extends StatelessWidget {
  final Color color;
  final String name;
  final String price;
  final String count;
  final String revenue;
  final bool bold;

  const _PackageLegend({
    required this.color,
    required this.name,
    required this.price,
    required this.count,
    required this.revenue,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (color != Colors.transparent) ...[
          Container(width: 14, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(name, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        ),
        if (price.isNotEmpty) ...[
          Text(price, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          const SizedBox(width: 12),
        ],
        Text(count, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
        const SizedBox(width: 12),
        Text(revenue, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.navy)),
      ],
    );
  }
}
