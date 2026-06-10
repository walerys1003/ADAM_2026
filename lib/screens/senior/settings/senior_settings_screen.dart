/// Senior Settings — Profile, voice, notifications, privacy, accessibility
/// June 2026 — GDPR-compliant consent management

import 'package:flutter/material.dart';
import '../../../config/app_config.dart';

class SeniorSettingsScreen extends StatefulWidget {
  const SeniorSettingsScreen({super.key});
  @override
  State<SeniorSettingsScreen> createState() => _SeniorSettingsScreenState();
}

class _SeniorSettingsScreenState extends State<SeniorSettingsScreen> {
  double _voiceSpeed = 1.0;
  double _voiceVolume = 1.0;
  bool _largeText = true;
  bool _highContrast = true;
  bool _vibrationFeedback = true;
  bool _autoAnswer = false;
  bool _consentVoice = true;
  bool _consentHealth = true;
  bool _consentFamily = true;
  String _language = 'pl';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Ustawienia', style: TextStyle(fontWeight: FontWeight.w700)), centerTitle: true),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _sectionHeader('Głos i rozmowy'),
        const SizedBox(height: 8),
        _buildVoiceSettings(),
        const SizedBox(height: 20),
        _sectionHeader('Dostępność'),
        const SizedBox(height: 8),
        _buildAccessibilitySettings(),
        const SizedBox(height: 20),
        _sectionHeader('Prywatność i zgody (RODO)'),
        const SizedBox(height: 8),
        _buildPrivacySettings(),
        const SizedBox(height: 20),
        _sectionHeader('Opaska i zdrowie'),
        const SizedBox(height: 8),
        _buildWearableSettings(),
        const SizedBox(height: 20),
        _sectionHeader('Konto i pakiet'),
        const SizedBox(height: 8),
        _buildAccountSettings(),
        const SizedBox(height: 40),
        _buildDangerZone(),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppConfig.brandNavy, letterSpacing: 0.5)));

  Widget _buildVoiceSettings() {
    return _settingsCard(children: [
      _sliderTile('Szybkość mowy Adama', _voiceSpeed, 0.5, 2.0, (v) => setState(() => _voiceSpeed = v),
          formatLabel: (v) => '${v.toStringAsFixed(1)}x'),
      const Divider(height: 1),
      _sliderTile('Głośność rozmów', _voiceVolume, 0.3, 1.0, (v) => setState(() => _voiceVolume = v)),
      const Divider(height: 1),
      SwitchListTile(
        title: const Text('Automatyczne odbieranie', style: TextStyle(fontSize: 17)),
        subtitle: const Text('Adam odbierze po 3 sygnałach'),
        value: _autoAnswer, onChanged: (v) => setState(() => _autoAnswer = v),
        activeColor: AppConfig.brandNavy),
      const Divider(height: 1),
      ListTile(
        leading: const Icon(Icons.language, color: Colors.grey),
        title: const Text('Język', style: TextStyle(fontSize: 17)),
        trailing: DropdownButton<String>(
          value: _language,
          items: const [
            DropdownMenuItem(value: 'pl', child: Text('🇵🇱 Polski')),
            DropdownMenuItem(value: 'en', child: Text('🇬🇧 English')),
          ],
          onChanged: (v) => setState(() => _language = v!),
          underline: const SizedBox()),
      ),
    ]);
  }

  Widget _buildAccessibilitySettings() {
    return _settingsCard(children: [
      SwitchListTile(
        title: const Text('Duży tekst', style: TextStyle(fontSize: 17)),
        subtitle: const Text('Większe czcionki i przyciski'),
        value: _largeText, onChanged: (v) => setState(() => _largeText = v),
        activeColor: AppConfig.brandNavy),
      const Divider(height: 1),
      SwitchListTile(
        title: const Text('Wysoki kontrast', style: TextStyle(fontSize: 17)),
        subtitle: const Text('Granat + złoto na białym tle'),
        value: _highContrast, onChanged: (v) => setState(() => _highContrast = v),
        activeColor: AppConfig.brandNavy),
      const Divider(height: 1),
      SwitchListTile(
        title: const Text('Wibracje', style: TextStyle(fontSize: 17)),
        subtitle: const Text('Wibracja przy alertach i powiadomieniach'),
        value: _vibrationFeedback, onChanged: (v) => setState(() => _vibrationFeedback = v),
        activeColor: AppConfig.brandNavy),
    ]);
  }

  Widget _buildPrivacySettings() {
    return _settingsCard(children: [
      SwitchListTile(
        title: const Text('Nagrywanie rozmów', style: TextStyle(fontSize: 17)),
        subtitle: const Text('Przechowujemy 30 dni w celu poprawy AI'),
        value: _consentVoice, onChanged: (v) => setState(() => _consentVoice = v),
        activeColor: AppConfig.brandNavy),
      const Divider(height: 1),
      SwitchListTile(
        title: const Text('Dane zdrowotne', style: TextStyle(fontSize: 17)),
        subtitle: const Text('Tętno, SpO2, sen z opaski'),
        value: _consentHealth, onChanged: (v) => setState(() => _consentHealth = v),
        activeColor: AppConfig.brandNavy),
      const Divider(height: 1),
      SwitchListTile(
        title: const Text('Udostępnianie rodzinie', style: TextStyle(fontSize: 17)),
        subtitle: const Text('Bliscy widzą podsumowanie zdrowia'),
        value: _consentFamily, onChanged: (v) => setState(() => _consentFamily = v),
        activeColor: AppConfig.brandNavy),
      const Divider(height: 1),
      ListTile(
        leading: const Icon(Icons.description, color: Colors.grey),
        title: const Text('Polityka prywatności', style: TextStyle(fontSize: 17)),
        trailing: const Icon(Icons.chevron_right), onTap: () {}),
      const Divider(height: 1),
      ListTile(
        leading: const Icon(Icons.download, color: Colors.grey),
        title: const Text('Pobierz moje dane', style: TextStyle(fontSize: 17)),
        subtitle: const Text('Eksport RODO (JSON + PDF)'),
        trailing: const Icon(Icons.chevron_right), onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Przygotowujemy eksport danych...'), backgroundColor: Colors.green));
        }),
    ]);
  }

  Widget _buildWearableSettings() {
    return _settingsCard(children: [
      ListTile(
        leading: Container(width: 40, height: 40, decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.watch, color: Colors.green, size: 24)),
        title: const Text('Xiaomi Smart Band 9 Pro', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        subtitle: const Text('Połączono · Ostatnia sync: 2 min temu'),
        trailing: Switch(value: true, onChanged: (_) {}, activeColor: Colors.green)),
      const Divider(height: 1),
      ListTile(
        leading: const Icon(Icons.sync, color: Colors.grey),
        title: const Text('Synchronizuj teraz', style: TextStyle(fontSize: 17)),
        trailing: const Icon(Icons.chevron_right), onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Synchronizacja zakończona!'), backgroundColor: Colors.green));
        }),
    ]);
  }

  Widget _buildAccountSettings() {
    return _settingsCard(children: [
      ListTile(
        leading: Container(width: 40, height: 40, decoration: BoxDecoration(
            color: AppConfig.brandGold.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.star, color: Color(0xFFD4A574), size: 24)),
        title: const Text('Pakiet AKTYWNY', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        subtitle: const Text('Ważny do 31.07.2026 · 299 zł/mies.'),
        trailing: OutlinedButton(onPressed: () {}, child: const Text('Zmień'))),
      const Divider(height: 1),
      ListTile(
        leading: const Icon(Icons.credit_card, color: Colors.grey),
        title: const Text('Metoda płatności', style: TextStyle(fontSize: 17)),
        subtitle: const Text('Karta **** 4242'),
        trailing: const Icon(Icons.chevron_right), onTap: () {}),
    ]);
  }

  Widget _buildDangerZone() {
    return _settingsCard(children: [
      ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text('Wyloguj się', style: TextStyle(fontSize: 17, color: Colors.red)),
        onTap: () {}),
      const Divider(height: 1),
      ListTile(
        leading: const Icon(Icons.delete_forever, color: Colors.red),
        title: const Text('Usuń konto', style: TextStyle(fontSize: 17, color: Colors.red)),
        subtitle: const Text('Nieodwracalne. Dane zostaną usunięte wg RODO.'),
        onTap: () => _showDeleteDialog()),
    ]);
  }

  void _showDeleteDialog() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Usunąć konto?'),
      content: const Text('Twoje dane zostaną trwale usunięte zgodnie z RODO. Ta operacja jest nieodwracalna.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Anuluj')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Usuń konto')),
      ],
    ));
  }

  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(children: children),
    );
  }

  Widget _sliderTile(String title, double value, double min, double max, Function(double) onChanged,
      {String Function(double)? formatLabel}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(fontSize: 17)),
          Text(formatLabel?.call(value) ?? '${value.toInt()}%',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.brandNavy)),
        ]),
        Slider(value: value, min: min, max: max, onChanged: onChanged,
            activeColor: AppConfig.brandNavy, inactiveColor: Colors.grey.shade200),
      ]),
    );
  }
}
