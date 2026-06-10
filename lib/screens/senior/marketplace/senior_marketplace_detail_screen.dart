import 'package:flutter/material.dart';
import '../../../config/app_config.dart';
import '../../../widgets/common/loading_shimmer_widget.dart';

/// Marketplace service detail — booking flow for senior services
/// Handles: service info, date/time picker, price breakdown, RODO consent
class SeniorMarketplaceDetailScreen extends StatefulWidget {
  final String serviceId;
  final String serviceName;
  final String serviceDescription;
  final double pricePLN;

  const SeniorMarketplaceDetailScreen({
    super.key,
    required this.serviceId,
    required this.serviceName,
    required this.serviceDescription,
    this.pricePLN = 49.0,
  });

  @override
  State<SeniorMarketplaceDetailScreen> createState() =>
      _SeniorMarketplaceDetailScreenState();
}

class _SeniorMarketplaceDetailScreenState
    extends State<SeniorMarketplaceDetailScreen> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _rodoConsent = false;
  bool _isSubmitting = false;

  final List<String> _timeSlots = [
    '08:00-09:00', '09:00-10:00', '10:00-11:00',
    '11:00-12:00', '14:00-15:00', '15:00-16:00',
    '16:00-17:00', '17:00-18:00',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppConfig.seniorBackgroundColor,
      appBar: AppBar(
        title: Text(widget.serviceName, style: const TextStyle(fontSize: 20)),
        backgroundColor: AppConfig.brandNavy,
        foregroundColor: Colors.white,
      ),
      body: _isSubmitting
          ? const LoadingShimmerWidget(layout: ShimmerLayout.detail)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServiceInfoCard(theme),
                  const SizedBox(height: 24),
                  _buildDateSelector(theme),
                  const SizedBox(height: 24),
                  _buildTimeSlotGrid(theme),
                  const SizedBox(height: 24),
                  _buildPriceBreakdown(theme),
                  const SizedBox(height: 24),
                  _buildRodoConsent(theme),
                  const SizedBox(height: 32),
                  _buildBookButton(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildServiceInfoCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConfig.brandNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.handyman, color: AppConfig.brandNavy, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.serviceName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.serviceDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wybierz datę', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            itemBuilder: (ctx, i) {
              final date = DateTime.now().add(Duration(days: i));
              final isWeekend = date.weekday > 5;
              final isSelected = _selectedDate != null &&
                  date.year == _selectedDate!.year &&
                  date.month == _selectedDate!.month &&
                  date.day == _selectedDate!.day;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: isWeekend ? null : () => setState(() => _selectedDate = date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 68,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppConfig.brandNavy
                          : isWeekend
                              ? Colors.grey.shade200
                              : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppConfig.brandNavy : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _weekdayShort(date.weekday),
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white70 : Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : isWeekend
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          _monthShort(date.month),
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white70 : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotGrid(ThemeData theme) {
    if (_selectedDate == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Wybierz godzinę', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _timeSlots.map((slot) {
            final isSelected = slot == _selectedTimeSlot;
            return GestureDetector(
              onTap: () => setState(() => _selectedTimeSlot = slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? AppConfig.brandNavy : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppConfig.brandNavy : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown(ThemeData theme) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Podsumowanie', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _priceRow('Usługa', '${widget.pricePLN.toStringAsFixed(0)} zł'),
            _priceRow('Dojazd', 'wliczony'),
            const Divider(height: 24),
            _priceRow('Razem', '${widget.pricePLN.toStringAsFixed(0)} zł', isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 20 : 16,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: isBold ? AppConfig.brandNavy : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRodoConsent(ThemeData theme) {
    return Card(
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Checkbox(
              value: _rodoConsent,
              onChanged: (v) => setState(() => _rodoConsent = v ?? false),
              activeColor: AppConfig.brandNavy,
            ),
            Expanded(
              child: Text(
                'Wyrażam zgodę na przetwarzanie danych osobowych '
                'zgodnie z polityką RODO SilverTech.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton(ThemeData theme) {
    final canBook = _selectedDate != null && _selectedTimeSlot != null && _rodoConsent;

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: canBook ? _handleBooking : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.brandNavy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        child: const Text('Zarezerwuj usługę'),
      ),
    );
  }

  Future<void> _handleBooking() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Usługa "${widget.serviceName}" zarezerwowana na '
            '${_selectedDate!.day}.${_selectedDate!.month} o ${_selectedTimeSlot!}!'),
        backgroundColor: AppConfig.semaforGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.of(context).pop(true);
  }

  String _weekdayShort(int wd) {
    const d = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'So', 'Nd'];
    return d[wd - 1];
  }

  String _monthShort(int m) {
    const d = ['sty', 'lut', 'mar', 'kwi', 'maj', 'cze', 'lip', 'sie', 'wrz', 'paź', 'lis', 'gru'];
    return d[m - 1];
  }
}
