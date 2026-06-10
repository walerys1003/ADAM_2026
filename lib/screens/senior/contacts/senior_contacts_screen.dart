import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../mixins/accessibility/accessibility_mixin.dart';

/// Senior Contacts Screen
/// Large, accessible contact list with quick-call and emergency priority
class SeniorContactsScreen extends StatefulWidget {
  const SeniorContactsScreen({super.key});

  @override
  State<SeniorContactsScreen> createState() => _SeniorContactsScreenState();
}

class _SeniorContactsScreenState extends State<SeniorContactsScreen>
    with AccessibilityMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<ContactModel> _contacts = [
    ContactModel(
      id: 'c1',
      name: 'Jan Kowalski (syn)',
      phone: '+48 601 234 567',
      relation: 'Rodzina',
      isEmergency: true,
      avatarColor: 0xFF4CAF50,
    ),
    ContactModel(
      id: 'c2',
      name: 'Anna Nowak (córka)',
      phone: '+48 602 345 678',
      relation: 'Rodzina',
      isEmergency: true,
      avatarColor: 0xFF2196F3,
    ),
    ContactModel(
      id: 'c3',
      name: 'Dr Maria Wiśniewska',
      phone: '+48 603 456 789',
      relation: 'Lekarz POZ',
      isEmergency: false,
      avatarColor: 0xFFE91E63,
    ),
    ContactModel(
      id: 'c4',
      name: 'Apteka "Pod Lwem"',
      phone: '+48 604 567 890',
      relation: 'Apteka',
      isEmergency: false,
      avatarColor: 0xFFFF9800,
    ),
    ContactModel(
      id: 'c5',
      name: 'Pogotowie Ratunkowe',
      phone: '999',
      relation: 'Służby',
      isEmergency: true,
      avatarColor: 0xFFF44336,
    ),
    ContactModel(
      id: 'c6',
      name: 'Straż Pożarna',
      phone: '998',
      relation: 'Służby',
      isEmergency: true,
      avatarColor: 0xFFFF5722,
    ),
    ContactModel(
      id: 'c7',
      name: 'Policja',
      phone: '997',
      relation: 'Służby',
      isEmergency: true,
      avatarColor: 0xFF1565C0,
    ),
    ContactModel(
      id: 'c8',
      name: 'Numer alarmowy 112',
      phone: '112',
      relation: 'Służby',
      isEmergency: true,
      avatarColor: 0xFFD32F2F,
    ),
    ContactModel(
      id: 'c9',
      name: 'Zofia Kowalska (sąsiadka)',
      phone: '+48 605 678 901',
      relation: 'Sąsiad',
      isEmergency: false,
      avatarColor: 0xFF9C27B0,
    ),
    ContactModel(
      id: 'c10',
      name: 'Centrum Seniora "Złota Jesień"',
      phone: '+48 606 789 012',
      relation: 'Instytucja',
      isEmergency: false,
      avatarColor: 0xFF00BCD4,
    ),
  ];

  List<ContactModel> get _filteredContacts {
    if (_searchQuery.isEmpty) return _contacts;
    return _contacts
        .where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.relation.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<ContactModel> get _emergencyContacts =>
      _filteredContacts.where((c) => c.isEmergency).toList();

  List<ContactModel> get _normalContacts =>
      _filteredContacts.where((c) => !c.isEmergency).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text(
          'Kontakty',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Szukaj kontaktu...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
            ),
            // Contact list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Emergency section
                  if (_emergencyContacts.isNotEmpty) ...[
                    _buildSectionHeader('🚨 Kontakty alarmowe', Colors.redAccent),
                    ..._emergencyContacts.map(_buildContactTile),
                  ],
                  // Normal contacts
                  if (_normalContacts.isNotEmpty) ...[
                    _buildSectionHeader('📞 Pozostałe kontakty', Colors.white70),
                    ..._normalContacts.map(_buildContactTile),
                  ],
                  if (_filteredContacts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            Icon(Icons.person_search, size: 64, color: Colors.white.withValues(alpha: 0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'Brak kontaktów',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: getScaledFontSize(16),
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildContactTile(ContactModel contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: contact.isEmergency
          ? Colors.red.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: contact.isEmergency
            ? BorderSide(color: Colors.red.withValues(alpha: 0.3))
            : BorderSide.none,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Color(contact.avatarColor).withValues(alpha: 0.3),
          child: Text(
            contact.name[0].toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        title: Text(
          contact.name,
          style: TextStyle(
            fontSize: getScaledFontSize(18),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          '${contact.relation} | ${contact.phone}',
          style: TextStyle(
            fontSize: getScaledFontSize(14),
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        trailing: SizedBox(
          width: getScaledTouchTarget(56),
          height: getScaledTouchTarget(56),
          child: IconButton(
            onPressed: () {
              // Trigger call via Android Intent
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dzwonię: ${contact.name}'),
                  backgroundColor: const Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.call, color: Color(0xFF4CAF50), size: 32),
          ),
        ),
      ),
    );
  }
}

class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String relation;
  final bool isEmergency;
  final int avatarColor;

  const ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
    required this.isEmergency,
    required this.avatarColor,
  });
}
