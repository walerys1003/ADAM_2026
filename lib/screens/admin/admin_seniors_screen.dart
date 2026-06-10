import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../models/senior.dart';
import '../../widgets/common/semafor_badge.dart';

class AdminSeniorsScreen extends StatelessWidget {
  const AdminSeniorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final seniors = provider.seniors;

        return Column(
          children: [
            // Header with search and filters
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Seniorzy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Dodaj seniora'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.navy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Szukaj seniora...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _filterChip('Wszyscy', true),
                      const SizedBox(width: 8),
                      _filterChip('Zielony', false),
                      const SizedBox(width: 8),
                      _filterChip('Żółty', false),
                      const SizedBox(width: 8),
                      _filterChip('Czerwony', false),
                    ],
                  ),
                ],
              ),
            ),

            // Table
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: seniors.length,
                itemBuilder: (context, index) {
                  final senior = seniors[index];
                  return _buildSeniorRow(context, senior);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _filterChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.navy : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSeniorRow(BuildContext context, Senior senior) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Navigate to senior detail
          context.read<AppProvider>().selectSenior(senior.id);
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.navy,
                child: Text(
                  senior.firstName[0],
                  style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(senior.fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text('${senior.age} lat · ${senior.address ?? "Poznań"}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Expanded(
                child: Text(senior.phone, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(senior.package, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.navy)),
              ),
              const SizedBox(width: 12),
              SemaforBadge(semafor: senior.semafor),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right, color: AppTheme.textLight),
            ],
          ),
        ),
      ),
    );
  }
}
