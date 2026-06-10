import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/mood_indicator.dart';
import 'admin_seniors_screen.dart';
import 'admin_conversations_screen.dart';
import 'admin_analytics_screen.dart';

/// Admin/Coordinator Dashboard - full management view
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('SilverTech Admin'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textPrimary,
        elevation: 1,
        actions: [
          IconButton(
            icon: Badge(
              label: const Text('3', style: TextStyle(fontSize: 10)),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showRoleSwitch(context),
          ),
        ],
      ),
      body: Row(
        children: [
          // ── Sidebar ──
          _buildSidebar(),
          // ── Main Content ──
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildMainDashboard(),
                const AdminSeniorsScreen(),
                const AdminConversationsScreen(),
                const AdminAnalyticsScreen(),
                _buildSettingsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppTheme.navy,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(2, 0)),
        ],
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: const Row(
              children: [
                Icon(Icons.phone_in_talk, color: AppTheme.gold, size: 28),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SilverTech', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Agent Adam', style: TextStyle(fontSize: 12, color: Colors.white60)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Menu Items
          _sidebarItem(Icons.dashboard, 'Dashboard', 0),
          _sidebarItem(Icons.people, 'Seniorzy', 1),
          _sidebarItem(Icons.chat, 'Rozmowy', 2),
          _sidebarItem(Icons.analytics, 'Analityka', 3),
          _sidebarItem(Icons.settings, 'Ustawienia', 4),

          const Spacer(),
          // User info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: AppTheme.gold, child: Icon(Icons.person, color: AppTheme.navy, size: 18)),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tomasz Kotliński', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                      Text('Admin', style: TextStyle(fontSize: 11, color: Colors.white60)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? AppTheme.gold : Colors.white60, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // MAIN DASHBOARD
  // ═══════════════════════════════════════════
  Widget _buildMainDashboard() {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final stats = provider.dashboardStats;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              const Text('Dashboard', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              Text('Przegląd systemu · ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                  style: const TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 24),

              // ── Stats Cards ──
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  StatCard(
                    title: 'Seniorzy',
                    value: '${stats['totalSeniors'] ?? 180}',
                    icon: Icons.people,
                    color: AppTheme.navy,
                    subtitle: '${stats['activeSeniors'] ?? 175} aktywnych',
                  ),
                  StatCard(
                    title: 'Rozmowy dziś',
                    value: '${stats['todayConversations'] ?? 347}',
                    icon: Icons.phone_in_talk,
                    color: const Color(0xFF1976D2),
                    subtitle: 'Śr. 5.4 min',
                  ),
                  StatCard(
                    title: 'Alerty',
                    value: '${stats['crisisAlerts'] ?? 3}',
                    icon: Icons.warning_amber,
                    color: AppTheme.red,
                    subtitle: '${stats['redAlerts'] ?? 1} krytyczne',
                  ),
                  StatCard(
                    title: 'NPS',
                    value: '${stats['nps'] ?? '4.7'}/5',
                    icon: Icons.star,
                    color: AppTheme.gold,
                    subtitle: '92% zadowolonych',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Charts Row ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildActivityChart(),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildSemaforDistribution(provider),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Recent Alerts + Recent Calls ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildRecentAlerts(provider)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildRecentCalls(provider)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityChart() {
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
          const Text('Aktywność w ciągu ostatnich 24h', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 40,
                barGroups: List.generate(24, (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: [5, 8, 12, 15, 10, 3, 0, 0, 2, 15, 25, 32, 28, 30, 25, 20, 18, 22, 35, 38, 30, 20, 12, 8][i].toDouble(),
                      color: AppTheme.navy,
                      width: 12,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                )),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 4 == 0) {
                          return Text('${value.toInt()}:00', style: const TextStyle(fontSize: 11));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 10),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemaforDistribution(AppProvider provider) {
    final green = provider.seniors.where((s) => s.semafor == 'GREEN').length;
    final yellow = provider.seniors.where((s) => s.semafor == 'YELLOW').length;
    final orange = provider.seniors.where((s) => s.semafor == 'ORANGE').length;
    final red = provider.seniors.where((s) => s.semafor == 'RED').length;
    final total = provider.seniors.length;

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
          const Text('Semafor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          _semaforBar('Zielony', green, total, const Color(0xFF4CAF50)),
          const SizedBox(height: 14),
          _semaforBar('Żółty', yellow, total, const Color(0xFFFFC107)),
          const SizedBox(height: 14),
          _semaforBar('Pomarańczowy', orange, total, const Color(0xFFFF9800)),
          const SizedBox(height: 14),
          _semaforBar('Czerwony', red, total, const Color(0xFFF44336)),
        ],
      ),
    );
  }

  Widget _semaforBar(String label, int count, int total, Color color) {
    final percent = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13)),
            Text('$count', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAlerts(AppProvider provider) {
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
          Row(
            children: [
              const Icon(Icons.warning_amber, color: AppTheme.red, size: 20),
              const SizedBox(width: 8),
              const Text('Ostatnie alerty', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Zobacz wszystkie')),
            ],
          ),
          const SizedBox(height: 12),
          const _AlertRow(senior: 'Maria Kowalska', level: 'RED', reason: 'Upadek', time: '14:32'),
          const Divider(),
          const _AlertRow(senior: 'Jan Nowak', level: 'YELLOW', reason: 'Brak ruchu 6h', time: '12:15'),
          const Divider(),
          const _AlertRow(senior: 'Anna Wiśniewska', level: 'ORANGE', reason: 'Niski nastrój', time: '09:45'),
        ],
      ),
    );
  }

  Widget _buildRecentCalls(AppProvider provider) {
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
          Row(
            children: [
              const Icon(Icons.phone_in_talk, color: AppTheme.navy, size: 20),
              const SizedBox(width: 8),
              const Text('Ostatnie rozmowy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(onPressed: () => setState(() => _selectedIndex = 2), child: const Text('Zobacz wszystkie')),
            ],
          ),
          const SizedBox(height: 12),
          ...provider.recentConversations.take(5).map((conv) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                MoodIndicator(moodScore: conv.moodScore ?? 3, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(conv.typeLabel, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(conv.startedAt.toString().substring(11, 16), style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Text(conv.durationFormatted, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSettingsView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: AppTheme.textLight),
          SizedBox(height: 16),
          Text('Ustawienia systemu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text('Konfiguracja backendu, integracji i parametrów', style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  void _showRoleSwitch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final provider = context.read<AppProvider>();
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Wybierz widok', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Senior', style: TextStyle(fontSize: 18)),
                onTap: () { provider.switchRole('senior'); Navigator.pop(ctx); },
              ),
              ListTile(
                leading: const Icon(Icons.family_restroom),
                title: const Text('Rodzina', style: TextStyle(fontSize: 18)),
                onTap: () { provider.switchRole('family'); Navigator.pop(ctx); },
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin / Opiekun', style: TextStyle(fontSize: 18)),
                selected: true,
                onTap: () { Navigator.pop(ctx); },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

class _AlertRow extends StatelessWidget {
  final String senior;
  final String level;
  final String reason;
  final String time;

  const _AlertRow({required this.senior, required this.level, required this.reason, required this.time});

  @override
  Widget build(BuildContext context) {
    final levelColor = level == 'RED' ? AppTheme.red : level == 'ORANGE' ? AppTheme.orange : AppTheme.yellow;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: levelColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(senior, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(reason, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          TextButton(onPressed: () {}, child: const Text('Zobacz', style: TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
