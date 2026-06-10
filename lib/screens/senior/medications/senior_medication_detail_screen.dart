import 'package:flutter/material.dart';
import '../../../models/medication.dart';
import '../../../mixins/accessibility/accessibility_mixin.dart';

/// Senior Medication Detail Screen
/// Full medication info with adherence history, dosage schedule, and refill reminder
class SeniorMedicationDetailScreen extends StatefulWidget {
  final Medication medication;

  const SeniorMedicationDetailScreen({super.key, required this.medication});

  @override
  State<SeniorMedicationDetailScreen> createState() =>
      _SeniorMedicationDetailScreenState();
}

class _SeniorMedicationDetailScreenState
    extends State<SeniorMedicationDetailScreen> with AccessibilityMixin {
  final List<bool> _weekAdherence = [true, true, false, true, true, true, false];

  @override
  Widget build(BuildContext context) {
    final med = widget.medication;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text(
          'Szczegóły leku',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medication header card
              _buildHeaderCard(med),
              const SizedBox(height: 20),
              // Dosage schedule
              _buildDosageSchedule(med),
              const SizedBox(height: 20),
              // Weekly adherence
              _buildAdherenceChart(),
              const SizedBox(height: 20),
              // Important info
              _buildInfoCard(med),
              const SizedBox(height: 20),
              // Action buttons
              _buildActionButtons(med),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Medication med) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.medication, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      med.dosage ?? '',
                      style: TextStyle(
                        fontSize: getScaledFontSize(16),
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              med.frequency ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDosageSchedule(Medication med) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.amber.shade300),
              const SizedBox(width: 12),
              Text(
                'Harmonogram dawkowania',
                style: TextStyle(
                  fontSize: getScaledFontSize(18),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTimeSlot('🌅 Rano (8:00)', med.dosage ?? '', true),
          const Divider(color: Colors.white12, height: 24),
          _buildTimeSlot('🌤️ Południe (14:00)', med.dosage ?? '', true),
          const Divider(color: Colors.white12, height: 24),
          _buildTimeSlot('🌙 Wieczór (20:00)', med.dosage ?? '', false),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(String label, String dose, bool taken) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: taken
                ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                : Colors.red.withValues(alpha: 0.2),
          ),
          child: Icon(
            taken ? Icons.check_circle : Icons.access_time,
            color: taken ? const Color(0xFF4CAF50) : Colors.redAccent,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: getScaledFontSize(16),
              color: Colors.white,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: taken
                ? const Color(0xFF4CAF50).withValues(alpha: 0.15)
                : Colors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dose,
            style: TextStyle(
              color: taken ? const Color(0xFF4CAF50) : Colors.orange,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdherenceChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Przestrzeganie w tym tygodniu',
                style: TextStyle(
                  fontSize: getScaledFontSize(16),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '71%',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final days = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];
              final isTaken = _weekAdherence[i];
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isTaken
                          ? const Color(0xFF4CAF50).withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.15),
                      border: Border.all(
                        color: isTaken ? const Color(0xFF4CAF50) : Colors.redAccent,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isTaken ? Icons.check : Icons.close,
                      color: isTaken ? const Color(0xFF4CAF50) : Colors.redAccent,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[i],
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Medication med) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade300),
              const SizedBox(width: 12),
              Text(
                'Ważne informacje',
                style: TextStyle(
                  fontSize: getScaledFontSize(18),
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Lekarz', 'Dr Maria Wiśniewska'),
          _buildInfoRow('Data rozpoczęcia', '01.06.2026'),
          _buildInfoRow('Data zakończenia', '30.09.2026'),
          _buildInfoRow('Refundacja', 'Tak (30%)'),
          _buildInfoRow('Pozostało tabletek', '23 szt.'),
          _buildInfoRow('Następna recepta', '28.09.2026'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: getScaledFontSize(15),
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: getScaledFontSize(15),
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Medication med) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: getScaledTouchTarget(60),
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Przypomnienie ustawione!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            icon: const Icon(Icons.notifications_active, size: 28),
            label: const Text('Ustaw przypomnienie', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: getScaledTouchTarget(60),
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Zgłoszono potrzebę odnowienia recepty'),
                  backgroundColor: Color(0xFF2196F3),
                ),
              );
            },
            icon: const Icon(Icons.refresh, size: 28),
            label: const Text('Odnów receptę', style: TextStyle(fontSize: 18)),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2196F3),
              side: const BorderSide(color: Color(0xFF2196F3), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ),
      ],
    );
  }
}
