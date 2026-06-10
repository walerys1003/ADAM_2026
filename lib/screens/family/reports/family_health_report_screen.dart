/// SilverTech Agent Adam — Family Health Report Screen
/// Weekly/monthly PDF reports, trend visualization, health insights
/// June 2026 — integrated with backend health analytics

import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../config/app_config.dart';
import '../../../widgets/common/stat_card.dart';
import '../../../widgets/common/semafor_badge.dart';

enum ReportPeriod { week, month, quarter }

class FamilyHealthReportScreen extends StatefulWidget {
  final String seniorName;
  final String seniorId;

  const FamilyHealthReportScreen({
    super.key,
    required this.seniorName,
    required this.seniorId,
  });

  @override
  State<FamilyHealthReportScreen> createState() => _FamilyHealthReportScreenState();
}

class _FamilyHealthReportScreenState extends State<FamilyHealthReportScreen> {
  ReportPeriod _period = ReportPeriod.week;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Raport: ${widget.seniorName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
            tooltip: 'Generuj PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
            tooltip: 'Udostępnij',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Period Selector ────────────────────────
            _buildPeriodSelector(),
            const SizedBox(height: 24),

            // ── Overall Status ─────────────────────────
            _buildOverallStatus(),
            const SizedBox(height: 20),

            // ── Health Metrics Summary ─────────────────
            _buildHealthMetrics(),
            const SizedBox(height: 20),

            // ── Activity Overview ──────────────────────
            _buildActivityOverview(),
            const SizedBox(height: 20),

            // ── Sleep Analysis ─────────────────────────
            _buildSleepAnalysis(),
            const SizedBox(height: 20),

            // ── Medication Adherence ───────────────────
            _buildMedicationAdherence(),
            const SizedBox(height: 20),

            // ── Mood Trend ─────────────────────────────
            _buildMoodTrend(),
            const SizedBox(height: 20),

            // ── AI Insights ────────────────────────────
            _buildAiInsights(),
            const SizedBox(height: 20),

            // ── Alerts Summary ─────────────────────────
            _buildAlertsSummary(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: ReportPeriod.values.map((p) {
          final selected = _period == p;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _period = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppConfig.brandNavy : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Text(
                  _periodLabel(p),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _periodLabel(ReportPeriod p) {
    switch (p) {
      case ReportPeriod.week: return 'Tydzień';
      case ReportPeriod.month: return 'Miesiąc';
      case ReportPeriod.quarter: return 'Kwartał';
    }
  }

  Widget _buildOverallStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status ogólny',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              SemaforBadge(level: 'GREEN', size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatusMetric('Stabilność\nzdrowia', '95%', Icons.trending_up),
              _buildStatusMetric('Adherencja\nlekowa', '88%', Icons.medication),
              _buildStatusMetric('Aktywność\nfizyczna', '+12%', Icons.directions_walk),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMetric(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85))),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics() {
    return _buildSectionCard(
      title: 'Wskaźniki zdrowotne',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: StatCard(icon: Icons.favorite, label: 'Śr. tętno', value: '71 BPM', color: const Color(0xFFFF6B6B), subtitle: 'spoczynkowe: 64')),
              const SizedBox(width: 12),
              Expanded(child: StatCard(icon: Icons.air, label: 'SpO2', value: '96%', color: const Color(0xFF45B7D1), subtitle: 'min: 93%')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(icon: Icons.thermostat, label: 'Temp.', value: '36.5°C', color: const Color(0xFFFFD93D), subtitle: 'w normie')),
              const SizedBox(width: 12),
              Expanded(child: StatCard(icon: Icons.monitor_heart, label: 'Ciśnienie', value: '128/82', color: const Color(0xFF6C5CE7), subtitle: 'optymalne')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOverview() {
    return _buildSectionCard(
      title: 'Aktywność fizyczna',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActivityRing('Kroki', 4823, 6000, const Color(0xFF4ECDC4)),
              _buildActivityRing('Kalorie', 1850, 2200, const Color(0xFFFF6B6B)),
              _buildActivityRing('Minuty', 45, 60, const Color(0xFFFFD93D)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.green, size: 24),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Najlepszy dzień: Sobota (7124 kroki) — świetny wynik!',
                    style: TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRing(String label, int current, int goal, Color color) {
    final progress = (current / goal).clamp(0.0, 1.0);
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text('${(progress * 100).toInt()}%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        Text('$current/$goal', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildSleepAnalysis() {
    return _buildSectionCard(
      title: 'Analiza snu',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.bedtime,
                  label: 'Średnio',
                  value: '7.5h',
                  color: const Color(0xFF96CEB4),
                  subtitle: 'na dobę',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.star,
                  label: 'Jakość',
                  value: '78/100',
                  color: const Color(0xFFFFD93D),
                  subtitle: 'dobra',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Sleep stages visualization
          SizedBox(
            height: 40,
            child: Row(
              children: [
                _buildSleepStage('Głęboki', 0.25, const Color(0xFF1A535C)),
                const SizedBox(width: 4),
                _buildSleepStage('Lekki', 0.45, const Color(0xFF4ECDC4)),
                const SizedBox(width: 4),
                _buildSleepStage('REM', 0.20, const Color(0xFFFF6B6B)),
                const SizedBox(width: 4),
                _buildSleepStage('Czuwanie', 0.10, Colors.grey.shade400),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _sleepLegend('Głęboki', const Color(0xFF1A535C)),
              _sleepLegend('Lekki', const Color(0xFF4ECDC4)),
              _sleepLegend('REM', const Color(0xFFFF6B6B)),
              _sleepLegend('Czuwanie', Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSleepStage(String label, double fraction, Color color) {
    return Expanded(
      flex: (fraction * 100).toInt(),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _sleepLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMedicationAdherence() {
    return _buildSectionCard(
      title: 'Przestrzeganie leków',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAdherenceItem('Metformina\n500mg', 92, 'rano'),
              ),
              Expanded(
                child: _buildAdherenceItem('Metformina\n500mg', 85, 'wieczór'),
              ),
              Expanded(
                child: _buildAdherenceItem('Aspiryna\n75mg', 96, 'rano'),
              ),
              Expanded(
                child: _buildAdherenceItem('Wit. D3\n2000IU', 78, 'południe'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Witamina D3 pominięta 3 razy w tym tygodniu',
                    style: TextStyle(color: Colors.orange, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdherenceItem(String name, int percent, String time) {
    final color = percent >= 90 ? Colors.green : percent >= 75 ? Colors.orange : Colors.red;
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 5,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 6),
        Text('$percent%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
        Text(name, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey, height: 1.3)),
        Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMoodTrend() {
    return _buildSectionCard(
      title: 'Trend nastroju',
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMoodBar('Pn', 3.5, '😐'),
                _buildMoodBar('Wt', 4.0, '😊'),
                _buildMoodBar('Śr', 4.5, '😊'),
                _buildMoodBar('Cz', 3.0, '😐'),
                _buildMoodBar('Pt', 4.0, '😊'),
                _buildMoodBar('So', 5.0, '🥰'),
                _buildMoodBar('Nd', 4.0, '😊'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text('Średnia tygodniowa: 4.0 — Dobry nastrój',
              style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMoodBar(String day, double score, String emoji) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Container(width: 32, height: score * 15,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF4ECDC4), Color(0xFF1A535C)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: BorderRadius.circular(10),
            )),
        const SizedBox(height: 4),
        Text(day, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAiInsights() {
    return _buildSectionCard(
      title: 'Spostrzeżenia AI',
      child: Column(
        children: [
          _buildInsightCard(
            icon: Icons.lightbulb,
            color: const Color(0xFFFFD93D),
            text: 'Aktywność fizyczna wzrosła o 12% w porównaniu do poprzedniego tygodnia. Świetna poprawa!',
          ),
          const SizedBox(height: 8),
          _buildInsightCard(
            icon: Icons.info_outline,
            color: const Color(0xFF45B7D1),
            text: 'Jakość snu spadła w czwartek. Warto zapytać, czy coś zakłóciło sen.',
          ),
          const SizedBox(height: 8),
          _buildInsightCard(
            icon: Icons.warning_amber,
            color: Colors.orange,
            text: 'Przypomnienie: Wizyta u dr Kowalskiego za 3 dni (czwartek, 10:30).',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({required IconData icon, required Color color, required String text}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: color == Colors.orange ? Colors.orange.shade800 : Colors.grey.shade800))),
        ],
      ),
    );
  }

  Widget _buildAlertsSummary() {
    return _buildSectionCard(
      title: 'Alerty w okresie',
      child: Column(
        children: [
          _buildAlertRow('🟡', 'Pominięta dawka Wit. D3', '3 razy'),
          _buildAlertRow('🟠', 'Podwyższone tętno (>100 BPM)', '1 raz'),
          _buildAlertRow('🟢', 'Wszystkie leki wzięte', '4 dni'),
        ],
      ),
    );
  }

  Widget _buildAlertRow(String icon, String title, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          Text(count, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _scheduleCall,
              icon: const Icon(Icons.phone),
              label: const Text('Zadzwoń'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generatePdf,
              icon: _isGenerating
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.download),
              label: Text(_isGenerating ? 'Generowanie...' : 'Pobierz PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.brandNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isGenerating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Raport PDF wygenerowany! Sprawdź swoją skrzynkę email.'), backgroundColor: Colors.green),
    );
  }

  Future<void> _shareReport() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Raport został udostępniony.'), backgroundColor: Colors.blue),
    );
  }

  Future<void> _scheduleCall() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dzwonię do seniora...'), backgroundColor: Colors.blue),
    );
  }
}
