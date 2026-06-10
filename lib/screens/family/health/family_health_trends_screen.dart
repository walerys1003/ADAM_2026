import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';

/// Health trends screen for family members.
/// Shows charts and data visualizations for:
/// - Heart rate over time
/// - Blood pressure trends
/// - Sleep quality
/// - Step count
/// - Weight tracking
class FamilyHealthTrendsScreen extends StatefulWidget {
  const FamilyHealthTrendsScreen({super.key});

  @override
  State<FamilyHealthTrendsScreen> createState() =>
      _FamilyHealthTrendsScreenState();
}

class _FamilyHealthTrendsScreenState extends State<FamilyHealthTrendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _timeRange = '7d'; // 7d, 30d, 90d

  final List<String> _timeRanges = ['7d', '30d', '90d'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final senior = provider.selectedSenior;

    return Scaffold(
      appBar: AppBar(
        title: Text(senior != null
            ? 'Trendy zdrowia — ${senior.firstName}'
            : 'Trendy zdrowia'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Eksportuj dane',
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'Serce'),
            Tab(icon: Icon(Icons.monitor_heart), text: 'Ciśnienie'),
            Tab(icon: Icon(Icons.bedtime), text: 'Sen'),
            Tab(icon: Icon(Icons.directions_walk), text: 'Aktywność'),
            Tab(icon: Icon(Icons.monitor_weight), text: 'Waga'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Time range selector
          _TimeRangeSelector(
            selectedRange: _timeRange,
            ranges: _timeRanges,
            onChanged: (range) => setState(() => _timeRange = range),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _HeartRateTab(period: _timeRange),
                _BloodPressureTab(period: _timeRange),
                _SleepTab(period: _timeRange),
                _ActivityTab(period: _timeRange),
                _WeightTab(period: _timeRange),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRangeSelector extends StatelessWidget {
  final String selectedRange;
  final List<String> ranges;
  final ValueChanged<String> onChanged;

  const _TimeRangeSelector({
    required this.selectedRange,
    required this.ranges,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ranges.map((range) {
          final isSelected = range == selectedRange;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(range.toUpperCase()),
              selected: isSelected,
              onSelected: (_) => onChanged(range),
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---- Tab Content Widgets ----

class _HeartRateTab extends StatelessWidget {
  final String period;

  const _HeartRateTab({required this.period});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _generateHeartRateData(period);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricSummaryCard(
            title: 'Średnie tętno',
            value: '${data.average}',
            unit: 'BPM',
            icon: Icons.favorite,
            color: Colors.red,
            min: '${data.min}',
            max: '${data.max}',
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wykres tętna', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 20),
                  _SimpleLineChart(data: data.points, color: Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _AnalysisCard(
            title: 'Analiza',
            analysis: data.analysis,
            recommendation: data.recommendation,
          ),
        ],
      ),
    );
  }
}

class _BloodPressureTab extends StatelessWidget {
  final String period;

  const _BloodPressureTab({required this.period});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricSummaryCard(
                  title: 'Skurczowe',
                  value: '128',
                  unit: 'mmHg',
                  icon: Icons.trending_up,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricSummaryCard(
                  title: 'Rozkurczowe',
                  value: '82',
                  unit: 'mmHg',
                  icon: Icons.trending_down,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trend ciśnienia', style: theme.textTheme.titleSmall),
                  const SizedBox(height: 20),
                  _SimpleLineChart(
                    data: List.generate(14, (i) => ChartPoint(
                      label: '${i + 1}',
                      value: 120 + (i % 5) * 3.0,
                    )),
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepTab extends StatelessWidget {
  final String period;

  const _SleepTab({required this.period});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricSummaryCard(
                  title: 'Średnio snu',
                  value: '7.2',
                  unit: 'h',
                  icon: Icons.bedtime,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricSummaryCard(
                  title: 'Jakość',
                  value: 'DOBRA',
                  unit: '',
                  icon: Icons.star,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SleepQualityChart(),
        ],
      ),
    );
  }
}

class _ActivityTab extends StatelessWidget {
  final String period;

  const _ActivityTab({required this.period});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricSummaryCard(
                  title: 'Średnio kroków',
                  value: '4520',
                  unit: '/dzień',
                  icon: Icons.directions_walk,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricSummaryCard(
                  title: 'Dystans',
                  value: '3.1',
                  unit: 'km/dzień',
                  icon: Icons.map,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StepGoalProgress(current: 4520, goal: 5000),
        ],
      ),
    );
  }
}

class _WeightTab extends StatelessWidget {
  final String period;

  const _WeightTab({required this.period});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricSummaryCard(
            title: 'Aktualna waga',
            value: '76.5',
            unit: 'kg',
            icon: Icons.monitor_weight,
            color: Colors.orange,
            min: '75.2',
            max: '78.1',
          ),
        ],
      ),
    );
  }
}

// ---- Reusable Widgets ----

class _MetricSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final String? min;
  final String? max;

  const _MetricSummaryCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    this.min,
    this.max,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    )),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(unit,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 14,
                      )),
                ),
              ],
            ),
            if (min != null && max != null) ...[
              const SizedBox(height: 8),
              Text('Zakres: $min – $max',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _SimpleLineChart extends StatelessWidget {
  final List<ChartPoint> data;
  final Color color;

  const _SimpleLineChart({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    final values = data.map((p) => p.value).toList();
    final double maxVal = values.reduce((a, b) => a > b ? a : b).toDouble();
    final double minVal = values.reduce((a, b) => a < b ? a : b).toDouble();
    final double range = maxVal - minVal > 0 ? maxVal - minVal : 1.0;

    return SizedBox(
      height: 160,
      child: CustomPaint(
        painter: _LineChartPainter(
          data: data,
          color: color,
          maxVal: maxVal,
          minVal: minVal,
          range: range,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ChartPoint> data;
  final Color color;
  final double maxVal;
  final double minVal;
  final double range;

  _LineChartPainter({
    required this.data,
    required this.color,
    required this.maxVal,
    required this.minVal,
    required this.range,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height - ((data[i].value - minVal) / range * size.height * 0.8) - 20;

      final point = Offset(x, y);
      points.add(point);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw dot
      canvas.drawCircle(point, 4, dotPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => oldDelegate.data != data;
}

class ChartPoint {
  final String label;
  final double value;

  const ChartPoint({required this.label, required this.value});
}

class _AnalysisCard extends StatelessWidget {
  final String title;
  final String analysis;
  final String recommendation;

  const _AnalysisCard({
    required this.title,
    required this.analysis,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.blue.shade700,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Text(analysis, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(recommendation,
                        style: const TextStyle(fontSize: 13, height: 1.4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepQualityChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final qualities = ['B. DOBRA', 'DOBRA', 'DOBRA', 'ŚREDNIA', 'DOBRA', 'DOBRA', 'B. DOBRA'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jakość snu (7 dni)',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: qualities.asMap().entries.map((entry) {
                final quality = entry.value;
                final color = quality == 'B. DOBRA'
                    ? Colors.green
                    : quality == 'DOBRA'
                        ? Colors.lightGreen
                        : Colors.orange;

                return Column(
                  children: [
                    Container(
                      width: 32,
                      height: (entry.key + 1) * 14.0,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'][entry.key],
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepGoalProgress extends StatelessWidget {
  final int current;
  final int goal;

  const _StepGoalProgress({required this.current, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = (current / goal).clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cel dzienny', style: theme.textTheme.titleSmall),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(Colors.green),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${(progress * 100).round()}%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        )),
                    Text('$current / $goal',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 13,
                        )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Sample Data ----

_HeartRateResult _generateHeartRateData(String period) {
  return _HeartRateResult(
    average: 73,
    min: 58,
    max: 95,
    points: List.generate(14, (i) => ChartPoint(
      label: '${i + 1}',
      value: 68 + (i % 5) * 3.0,
    )),
    analysis: 'Tętno w normie. Średnia 73 BPM mieści się w zakresie '
        '60-100 BPM dla osób starszych.',
    recommendation: 'Kontynuuj regularne spacery. Rozważ dodanie '
        'lekkich ćwiczeń rozciągających.',
  );
}

class _HeartRateResult {
  final int average;
  final int min;
  final int max;
  final List<ChartPoint> points;
  final String analysis;
  final String recommendation;

  _HeartRateResult({
    required this.average,
    required this.min,
    required this.max,
    required this.points,
    required this.analysis,
    required this.recommendation,
  });
}
