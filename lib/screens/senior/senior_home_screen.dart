import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common/semafor_badge.dart';
import 'senior_sos_screen.dart';
import 'senior_medications_screen.dart';
import 'senior_health_screen.dart';
import 'senior_marketplace_screen.dart';

/// Senior Home Screen - large buttons, high contrast, minimal complexity
class SeniorHomeScreen extends StatelessWidget {
  const SeniorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmWhite,
      appBar: AppBar(
        title: const Text('Adam - Przyjaciel'),
        backgroundColor: AppTheme.navy,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showRoleSwitch(context),
            tooltip: 'Zmień widok',
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            final senior = provider.selectedSenior;
            if (senior == null) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_in_talk, size: 64, color: AppTheme.navy),
                    SizedBox(height: 16),
                    Text('Wybierz seniora z listy', style: TextStyle(fontSize: 20)),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ── Welcome Header ──
                  _buildWelcomeHeader(senior.fullName),
                  const SizedBox(height: 12),
                  SemaforBadge(semafor: senior.semafor, size: 20),
                  const SizedBox(height: 28),

                  // ── MAIN: Call Adam Button ──
                  _buildCallAdamButton(context, provider, senior.id, senior.phone),
                  const SizedBox(height: 16),

                  // ── SOS Emergency Button ──
                  _buildSOSButton(context, provider, senior.id, senior.phone),
                  const SizedBox(height: 28),

                  // ── Quick Info Cards ──
                  _buildInfoCards(context),
                  const SizedBox(height: 28),

                  // ── Next Actions ──
                  _buildActionGrid(context, provider, senior),
                  const SizedBox(height: 24),

                  // ── Last Conversation ──
                  _buildLastConversation(provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(String name) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.goldLight.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.gold, width: 3),
          ),
          child: const Icon(
            Icons.person,
            size: 44,
            color: AppTheme.navy,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Witaj, $name!',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.navy,
          ),
        ),
      ],
    );
  }

  Widget _buildCallAdamButton(
    BuildContext context,
    AppProvider provider,
    String seniorId,
    String phone,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 90,
      child: ElevatedButton.icon(
        onPressed: () {
          provider.callSenior(seniorId, phone);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📞 Adam dzwoni... Proszę czekać'),
              backgroundColor: AppTheme.navy,
              duration: Duration(seconds: 3),
            ),
          );
        },
        icon: const Icon(Icons.phone, size: 38),
        label: const Text(
          'ZADZWOŃ DO ADAMA',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.navy,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildSOSButton(
    BuildContext context,
    AppProvider provider,
    String seniorId,
    String phone,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 32),
                  SizedBox(width: 12),
                  Text('POMOCY!', style: TextStyle(fontSize: 24)),
                ],
              ),
              content: const Text(
                'Czy na pewno potrzebujesz pomocy?\nAdam natychmiast powiadomi rodzinę i służby.',
                style: TextStyle(fontSize: 18),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('ANULUJ', style: TextStyle(fontSize: 18)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    provider.triggerSOS(seniorId, phone);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SeniorSOSScreen(seniorId: seniorId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(140, 56),
                  ),
                  child: const Text(
                    'TAK, POMOCY!',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.warning_amber_rounded, size: 34),
        label: const Text(
          'POMOCY!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 6,
        ),
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        return Row(
          children: [
            Expanded(
              child: _miniCard(
                icon: Icons.favorite,
                label: 'Tętno',
                value: provider.latestHealth?.heartRateBpm?.toString() ?? '--',
                unit: 'BPM',
                color: AppTheme.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _miniCard(
                icon: Icons.air,
                label: 'SpO2',
                value: provider.latestHealth?.spo2Percent?.toStringAsFixed(0) ?? '--',
                unit: '%',
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _miniCard(
                icon: Icons.directions_walk,
                label: 'Kroki',
                value: provider.latestHealth?.steps?.toString() ?? '--',
                unit: '',
                color: AppTheme.green,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _miniCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(
    BuildContext context,
    AppProvider provider,
    senior,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 1.3,
      children: [
        _actionTile(
          context: context,
          icon: Icons.medical_services_outlined,
          label: 'Moje Leki',
          color: const Color(0xFF1976D2),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SeniorMedicationsScreen(seniorId: senior.id),
            ),
          ),
          badge: '3 dzisiaj',
        ),
        _actionTile(
          context: context,
          icon: Icons.monitor_heart_outlined,
          label: 'Moje Zdrowie',
          color: const Color(0xFFE91E63),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SeniorHealthScreen(seniorId: senior.id),
            ),
          ),
          badge: senior.hasWearable ? 'OK' : null,
        ),
        _actionTile(
          context: context,
          icon: Icons.shopping_basket_outlined,
          label: 'Zamów Usługę',
          color: const Color(0xFFFF6F00),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SeniorMarketplaceScreen(seniorId: senior.id),
            ),
          ),
          badge: '5 usług',
        ),
        _actionTile(
          context: context,
          icon: Icons.family_restroom,
          label: 'Rodzina',
          color: const Color(0xFF4CAF50),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('📱 Dzwonię do rodziny...'),
                backgroundColor: AppTheme.navy,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _actionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 34),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (badge != null)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastConversation(AppProvider provider) {
    if (provider.recentConversations.isEmpty) return const SizedBox.shrink();

    final lastCall = provider.recentConversations.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.navy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.phone_callback, color: AppTheme.navy, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ostatnia rozmowa',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastCall.typeLabel,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  lastCall.durationFormatted,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                lastCall.moodEmoji,
                style: const TextStyle(fontSize: 28),
              ),
              if (lastCall.moodScore != null)
                Text(
                  '${lastCall.moodScore}/5',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
            ],
          ),
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
                selected: provider.userRole == 'senior',
                onTap: () {
                  provider.switchRole('senior');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.family_restroom, color: AppTheme.gold),
                title: const Text('Rodzina', style: TextStyle(fontSize: 18)),
                selected: provider.userRole == 'family',
                onTap: () {
                  provider.switchRole('family');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: AppTheme.navy),
                title: const Text('Admin / Opiekun', style: TextStyle(fontSize: 18)),
                selected: provider.userRole == 'admin',
                onTap: () {
                  provider.switchRole('admin');
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
