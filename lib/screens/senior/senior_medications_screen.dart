import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/medication.dart';

/// Senior medication list with large checkboxes and clear labels
class SeniorMedicationsScreen extends StatefulWidget {
  final String seniorId;

  const SeniorMedicationsScreen({super.key, required this.seniorId});

  @override
  State<SeniorMedicationsScreen> createState() => _SeniorMedicationsScreenState();
}

class _SeniorMedicationsScreenState extends State<SeniorMedicationsScreen> {
  final List<Medication> _meds = Medication.sampleMeds('s1');
  final Map<String, bool> _takenToday = {};
  final Map<String, bool> _takenEvening = {};

  @override
  void initState() {
    super.initState();
    for (final med in _meds) {
      if (med.timeOfDay != null) {
        for (final time in med.timeOfDay!) {
          final hour = int.tryParse(time.split(':')[0]) ?? 0;
          if (hour < 12) {
            _takenToday[med.id] = false;
          } else {
            _takenEvening[med.id] = false;
          }
        }
      }
    }
    // Simulate some taken
    if (_takenToday.isNotEmpty) {
      _takenToday[_meds.first.id] = true;
      if (_meds.length > 1) _takenToday[_meds[1].id] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMorning = DateTime.now().hour < 14;

    return Scaffold(
      backgroundColor: AppTheme.warmWhite,
      appBar: AppBar(
        title: const Text('Moje Leki'),
        backgroundColor: AppTheme.navy,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header Info ──
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.medical_services, color: Colors.white, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    isMorning ? 'Leki poranne' : 'Leki wieczorne',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_takenCount(isMorning)} z ${_totalCount(isMorning)} wzięte',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _totalCount(isMorning) > 0
                        ? _takenCount(isMorning) / _totalCount(isMorning)
                        : 1.0,
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),

            // ── Medication List ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _meds.length,
                itemBuilder: (context, index) {
                  final med = _meds[index];
                  final hasMorning = med.timeOfDay?.any((t) {
                        final h = int.tryParse(t.split(':')[0]) ?? 0;
                        return h < 12;
                      }) ??
                      false;
                  final hasEvening = med.timeOfDay?.any((t) {
                        final h = int.tryParse(t.split(':')[0]) ?? 0;
                        return h >= 12;
                      }) ??
                      false;

                  final relevant = isMorning ? hasMorning : hasEvening;
                  final isTaken = isMorning
                      ? (_takenToday[med.id] ?? false)
                      : (_takenEvening[med.id] ?? false);

                  if (!relevant) return const SizedBox.shrink();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          // Checkbox
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isMorning) {
                                  _takenToday[med.id] = !isTaken;
                                } else {
                                  _takenEvening[med.id] = !isTaken;
                                }
                              });
                            },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isTaken
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isTaken
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: isTaken
                                  ? const Icon(Icons.check, color: Colors.white, size: 32)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  med.dosageFormatted,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: isTaken
                                        ? Colors.grey.shade500
                                        : AppTheme.textPrimary,
                                    decoration: isTaken
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  med.instructions ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '⏰ ${med.timeFormatted}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _takenCount(bool isMorning) {
    int count = 0;
    for (final med in _meds) {
      final taken = isMorning ? (_takenToday[med.id] ?? false) : (_takenEvening[med.id] ?? false);
      if (taken) count++;
    }
    return count;
  }

  int _totalCount(bool isMorning) {
    int count = 0;
    for (final med in _meds) {
      final relevant = isMorning
          ? (med.timeOfDay?.any((t) => (int.tryParse(t.split(':')[0]) ?? 0) < 12) ?? false)
          : (med.timeOfDay?.any((t) => (int.tryParse(t.split(':')[0]) ?? 0) >= 12) ?? false);
      if (relevant) count++;
    }
    return count;
  }
}
