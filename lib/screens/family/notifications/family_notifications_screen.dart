/// SilverTech Agent Adam — Family Notifications Center
/// Real-time alert feed, notification preferences, push/SMS/email config

import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../config/app_config.dart';
import '../../../widgets/common/semafor_badge.dart';

class FamilyNotificationsScreen extends StatefulWidget {
  const FamilyNotificationsScreen({super.key});

  @override
  State<FamilyNotificationsScreen> createState() => _FamilyNotificationsScreenState();
}

class _FamilyNotificationsScreenState extends State<FamilyNotificationsScreen> {
  bool _pushEnabled = true;
  bool _smsEnabled = true;
  bool _emailEnabled = false;
  bool _nightQuietHours = true;
  String _selectedFilter = 'ALL';

  final List<_NotificationItem> _items = [
    _NotificationItem('ALERT', 'ORANGE', 'Niskie tętno — 48 BPM', 'Jan Kowalski', '5 min temu', false),
    _NotificationItem('MEDS', 'YELLOW', 'Pominięta dawka Metforminy (20:00)', 'Jan Kowalski', '2 godz. temu', false),
    _NotificationItem('HEALTH', 'GREEN', 'Tygodniowy raport zdrowia dostępny', 'Jan Kowalski', 'Wczoraj', true),
    _NotificationItem('SYSTEM', 'GREEN', 'Opaska ponownie połączona', 'Jan Kowalski', 'Wczoraj', true),
    _NotificationItem('ALERT', 'RED', 'SOS — wezwano pogotowie!', 'Jan Kowalski', '3 dni temu', true),
    _NotificationItem('MEDS', 'GREEN', 'Wszystkie leki wzięte — dobry tydzień!', 'Jan Kowalski', '4 dni temu', true),
    _NotificationItem('HEALTH', 'YELLOW', 'Spadek nastroju — wynik 2/5', 'Jan Kowalski', '5 dni temu', true),
    _NotificationItem('SYSTEM', 'GREEN', 'Nowa aktualizacja aplikacji', 'System', '1 tydz. temu', true),
  ];

  List<_NotificationItem> get filteredItems {
    if (_selectedFilter == 'ALL') return _items;
    return _items.where((i) => i.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Powiadomienia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
          ),
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllRead,
            tooltip: 'Oznacz wszystkie jako przeczytane',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterBar(),
          // Notification list
          Expanded(child: _buildNotificationList()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    const filters = [
      ('ALL', 'Wszystkie'),
      ('ALERT', 'Alerty'),
      ('MEDS', 'Leki'),
      ('HEALTH', 'Zdrowie'),
      ('SYSTEM', 'System'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final selected = _selectedFilter == f.$1;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(f.$2),
                selected: selected,
                onSelected: (_) => setState(() => _selectedFilter = f.$1),
                selectedColor: AppConfig.brandNavy.withValues(alpha: 0.15),
                checkmarkColor: AppConfig.brandNavy,
                labelStyle: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppConfig.brandNavy : Colors.grey.shade700,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    final unread = _items.where((i) => !i.isRead).length;

    return Column(
      children: [
        if (unread > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text('$unread nieprzeczytanych',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConfig.brandNavy)),
                const Spacer(),
                TextButton(onPressed: _markAllRead, child: const Text('Oznacz wszystkie')),
              ],
            ),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredItems.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) => _buildNotificationTile(filteredItems[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTile(_NotificationItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      leading: _buildNotificationIcon(item),
      title: Text(item.title, style: TextStyle(fontWeight: item.isRead ? FontWeight.w400 : FontWeight.w700, fontSize: 16)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            SemaforBadge(level: item.semafor, size: 12),
            const SizedBox(width: 8),
            Text(item.seniorName, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(width: 8),
            Text('·', style: TextStyle(color: Colors.grey.shade400)),
            const SizedBox(width: 8),
            Text(item.time, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ],
        ),
      ),
      trailing: item.isRead ? null : Container(
        width: 10, height: 10,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppConfig.semaforRed),
      ),
      onTap: () => setState(() => item.isRead = true),
    );
  }

  Widget _buildNotificationIcon(_NotificationItem item) {
    IconData icon;
    Color color;
    switch (item.type) {
      case 'ALERT':
        icon = Icons.warning_amber_rounded;
        color = item.semafor == 'RED' ? AppConfig.semaforRed : AppConfig.semaforOrange;
        break;
      case 'MEDS':
        icon = Icons.medication;
        color = AppConfig.semaforYellow;
        break;
      case 'HEALTH':
        icon = Icons.favorite;
        color = AppConfig.semaforGreen;
        break;
      default:
        icon = Icons.info_outline;
        color = AppConfig.brandNavy;
    }
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  void _markAllRead() {
    setState(() {
      for (final item in _items) {
        item.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wszystkie powiadomienia oznaczone jako przeczytane')),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ustawienia powiadomień',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Push notifications'),
                subtitle: const Text('Natychmiastowe powiadomienia w aplikacji'),
                value: _pushEnabled,
                onChanged: (v) => setModalState(() => _pushEnabled = v),
              ),
              SwitchListTile(
                title: const Text('Powiadomienia SMS'),
                subtitle: const Text('Alerty krytyczne wysyłane SMS-em'),
                value: _smsEnabled,
                onChanged: (v) => setModalState(() => _smsEnabled = v),
              ),
              SwitchListTile(
                title: const Text('Raporty email'),
                subtitle: const Text('Tygodniowe raporty na email'),
                value: _emailEnabled,
                onChanged: (v) => setModalState(() => _emailEnabled = v),
              ),
              SwitchListTile(
                title: const Text('Cisza nocna (22:00-7:00)'),
                subtitle: const Text('Wycisz powiadomienia w nocy'),
                value: _nightQuietHours,
                onChanged: (v) => setModalState(() => _nightQuietHours = v),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationItem {
  final String type;
  final String semafor;
  final String title;
  final String seniorName;
  final String time;
  bool isRead;

  _NotificationItem(this.type, this.semafor, this.title, this.seniorName, this.time, this.isRead);
}
