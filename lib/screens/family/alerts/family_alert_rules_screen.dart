import 'package:flutter/material.dart';
import '../../../mixins/accessibility/accessibility_mixin.dart';

/// Family Alert Rules Screen
/// Configure when and how family members receive notifications about the senior
class FamilyAlertRulesScreen extends StatefulWidget {
  const FamilyAlertRulesScreen({super.key});

  @override
  State<FamilyAlertRulesScreen> createState() => _FamilyAlertRulesScreenState();
}

class _FamilyAlertRulesScreenState extends State<FamilyAlertRulesScreen>
    with AccessibilityMixin {
  bool _pushEnabled = true;
  bool _smsEnabled = true;
  bool _emailEnabled = false;
  bool _weeklyReportEnabled = true;

  // Threshold configs
  double _heartRateHigh = 120;
  double _heartRateLow = 45;
  double _systolicHigh = 160;
  double _spo2Low = 92;
  int _missedMedsAlert = 2;
  int _noActivityHours = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Reguły alertów', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ─── Notification channels ─────────────────────────
            _buildSectionHeader('📱 Kanały powiadomień'),
            const SizedBox(height: 8),
            _buildChannelTile('Powiadomienia push', 'Natychmiastowe powiadomienia w aplikacji', _pushEnabled, (v) => setState(() => _pushEnabled = v)),
            _buildChannelTile('SMS', 'Alerty SMS na telefon (dodatkowo płatne wg cennika operatora)', _smsEnabled, (v) => setState(() => _smsEnabled = v)),
            _buildChannelTile('Email', 'Cotygodniowe raporty i alerty email', _emailEnabled, (v) => setState(() => _emailEnabled = v)),

            const SizedBox(height: 24),
            _buildSectionHeader('📊 Raporty'),
            const SizedBox(height: 8),
            _buildChannelTile('Raport tygodniowy', 'Podsumowanie aktywności i zdrowia co poniedziałek', _weeklyReportEnabled, (v) => setState(() => _weeklyReportEnabled = v)),

            const SizedBox(height: 24),
            _buildSectionHeader('❤️ Progi zdrowotne'),
            _buildInfoText('Alerty zostaną wysłane, gdy parametry przekroczą ustalone progi.'),
            const SizedBox(height: 12),

            // Heart rate high
            _buildSliderTile(
              'Tętno — górny próg',
              '${_heartRateHigh.toInt()} bpm',
              _heartRateHigh,
              80,
              180,
              (v) => setState(() => _heartRateHigh = v),
              const Color(0xFFF44336),
            ),
            // Heart rate low
            _buildSliderTile(
              'Tętno — dolny próg',
              '${_heartRateLow.toInt()} bpm',
              _heartRateLow,
              30,
              80,
              (v) => setState(() => _heartRateLow = v),
              const Color(0xFF2196F3),
            ),
            // Systolic high
            _buildSliderTile(
              'Ciśnienie skurczowe — górny próg',
              '${_systolicHigh.toInt()} mmHg',
              _systolicHigh,
              120,
              220,
              (v) => setState(() => _systolicHigh = v),
              const Color(0xFFFF9800),
            ),
            // SpO2 low
            _buildSliderTile(
              'Saturacja (SpO₂) — dolny próg',
              '${_spo2Low.toInt()}%',
              _spo2Low,
              80,
                  100,
              (v) => setState(() => _spo2Low = v),
              const Color(0xFF9C27B0),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('⏰ Progi aktywności'),
            _buildInfoText('Alerty gdy senior nie wykazuje oczekiwanej aktywności.'),
            const SizedBox(height: 12),

            // Missed meds
            _buildStepperTile(
              'Pominięte leki',
              'Alert po $_missedMedsAlert pominiętych dawkach',
              _missedMedsAlert,
              1,
              5,
              (v) => setState(() => _missedMedsAlert = v),
            ),
            // No activity
            _buildStepperTile(
              'Brak aktywności',
              'Alert po $_noActivityHours godzinach bez ruchu',
              _noActivityHours,
              4,
              48,
              (v) => setState(() => _noActivityHours = v),
            ),

            const SizedBox(height: 32),
            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Reguły alertów zapisane!'), backgroundColor: Color(0xFF4CAF50)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Zapisz reguły', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white));
  }

  Widget _buildInfoText(String text) {
    return Text(text, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.5)));
  }

  Widget _buildChannelTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Card(
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildSliderTile(String title, String value, double current, double min, double max, ValueChanged<double> onChanged, Color color) {
    return Card(
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ],
            ),
            Slider(
              value: current,
              min: min,
              max: max,
              activeColor: color,
              onChanged: onChanged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${min.toInt()}', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3))),
                Text('${max.toInt()}', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperTile(String title, String description, int current, int min, int max, ValueChanged<int> onChanged) {
    return Card(
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(description, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: current > min ? () => onChanged(current - 1) : null,
                  icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF4CAF50)),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text('$current', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  onPressed: current < max ? () => onChanged(current + 1) : null,
                  icon: const Icon(Icons.add_circle_outline, color: Color(0xFF4CAF50)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
