import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common/semafor_badge.dart';
import '../../widgets/common/mood_indicator.dart';
import '../../widgets/common/stat_card.dart';

/// Family/Caregiver Dashboard - overview of loved one's status
class FamilyDashboardScreen extends StatelessWidget {
  const FamilyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmWhite,
      appBar: AppBar(
        title: const Text('Panel Rodziny'),
        backgroundColor: AppTheme.navy,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Powiadomienia',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showRoleSwitch(context),
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          if (provider.selectedSenior == null) {
            return _buildSeniorSelector(context, provider);
          }
          return _buildDashboard(context, provider);
        },
      ),
    );
  }

  Widget _buildSeniorSelector(BuildContext context, AppProvider provider) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.navy, Color(0xFF2A5078)],
            ),
          ),
          child: const Column(
            children: [
              Icon(Icons.family_restroom, size: 56, color: AppTheme.gold),
              SizedBox(height: 12),
              Text(
                'Wybierz bliską osobę',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.seniors.length,
            itemBuilder: (context, index) {
              final senior = provider.seniors[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.navy,
                    child: Text(
                      senior.firstName[0],
                      style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    senior.fullName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('${senior.age} lat · ${senior.package}'),
                      const SizedBox(height: 4),
                      SemaforBadge(semafor: senior.semafor),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 32),
                  onTap: () => provider.selectSenior(senior.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard(BuildContext context, AppProvider provider) {
    final senior = provider.selectedSenior!;
    final lastCall = provider.recentConversations.isNotEmpty
        ? provider.recentConversations.first
        : null;

    return RefreshIndicator(
      onRefresh: () => provider.selectSenior(senior.id),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Senior Info Header ──
            _buildSeniorHeader(senior, lastCall),
            const SizedBox(height: 16),

            // ── Stats Row ──
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Ostatni nastrój',
                    value: lastCall?.moodEmoji ?? '--',
                    icon: Icons.mood,
                    color: AppTheme.gold,
                    subtitle: lastCall != null ? '${lastCall.moodScore}/5' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Rozmowy dziś',
                    value: provider.recentConversations.where((c) => c.startedAt.day == DateTime.now().day).length.toString(),
                    icon: Icons.phone_in_talk,
                    color: AppTheme.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Health Summary ──
            _buildHealthSummary(provider),
            const SizedBox(height: 16),

            // ── Medication Adherence ──
            _buildMedicationAdherence(provider),
            const SizedBox(height: 16),

            // ── Recent Conversations ──
            _buildRecentConversations(provider),
            const SizedBox(height: 16),

            // ── Alert History ──
            _buildAlertHistory(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildSeniorHeader(senior, lastCall) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.navy, Color(0xFF2A5078)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.gold,
            child: Text(
              senior.firstName[0],
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.navy),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  senior.fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${senior.age} lat · ${senior.package}',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          Column(
            children: [
              SemaforBadge(semafor: senior.semafor),
              const SizedBox(height: 8),
              Text(
                lastCall != null ? 'Rozmowa: ${lastCall.durationFormatted}' : 'Brak rozmów',
                style: const TextStyle(fontSize: 11, color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSummary(AppProvider provider) {
    final health = provider.latestHealth;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.favorite, color: AppTheme.red, size: 22),
              SizedBox(width: 8),
              Text('Zdrowie', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Spacer(),
              Text('Xiaomi Band 9 Pro', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _healthMetric('Tętno', '${health?.heartRateBpm ?? 72}', 'BPM', AppTheme.red, Icons.favorite),
              _healthMetric('SpO2', '${health?.spo2Percent?.toStringAsFixed(0) ?? '97'}', '%', AppTheme.navy, Icons.air),
              _healthMetric('Kroki', '${health?.steps ?? 4523}', '', AppTheme.green, Icons.directions_walk),
              _healthMetric('Sen', '7h 40m', '', AppTheme.purple, Icons.bedtime),
            ],
          ),
        ],
      ),
    );
  }

  Widget _healthMetric(String label, String value, String unit, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildMedicationAdherence(AppProvider provider) {
    final meds = provider.medications;
    if (meds.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.medical_services, color: Color(0xFF1976D2), size: 22),
              SizedBox(width: 8),
              Text('Leki', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Spacer(),
              Text('Dzisiaj', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          ...meds.map((med) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: const Color(0xFF4CAF50),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    med.dosageFormatted,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  med.timeFormatted,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRecentConversations(AppProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.chat_bubble_outline, color: AppTheme.navy, size: 22),
              SizedBox(width: 8),
              Text('Ostatnie rozmowy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ...provider.recentConversations.take(3).map((conv) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: conv.escalationFlag
                        ? AppTheme.red.withValues(alpha: 0.1)
                        : AppTheme.navy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    conv.escalationFlag ? Icons.warning : Icons.phone,
                    color: conv.escalationFlag ? AppTheme.red : AppTheme.navy,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(conv.typeLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(conv.durationFormatted, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                MoodIndicator(moodScore: conv.moodScore ?? 3, size: 36),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAlertHistory(AppProvider provider) {
    final crisisConvs = provider.crisisConversations;
    if (crisisConvs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.green, size: 28),
            SizedBox(width: 12),
            Text('Brak alertów — wszystko w porządku!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.red.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber, color: AppTheme.red, size: 22),
              SizedBox(width: 8),
              Text('Alerty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.red)),
            ],
          ),
          const SizedBox(height: 12),
          ...crisisConvs.map((conv) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.error, color: AppTheme.red),
            title: Text(conv.typeLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(conv.startedAt.toString().substring(0, 16)),
            trailing: conv.escalationResolved
                ? const Icon(Icons.check_circle, color: AppTheme.green)
                : const Icon(Icons.pending, color: AppTheme.orange),
          )),
        ],
      ),
    );
  }

  void _showRoleSwitch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                leading: const Icon(Icons.person, color: AppTheme.navy),
                title: const Text('Senior', style: TextStyle(fontSize: 18)),
                onTap: () { provider.switchRole('senior'); Navigator.pop(ctx); },
              ),
              ListTile(
                leading: const Icon(Icons.family_restroom, color: AppTheme.gold),
                title: const Text('Rodzina', style: TextStyle(fontSize: 18)),
                selected: true,
                onTap: () { Navigator.pop(ctx); },
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: AppTheme.navy),
                title: const Text('Admin / Opiekun', style: TextStyle(fontSize: 18)),
                onTap: () { provider.switchRole('admin'); Navigator.pop(ctx); },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
