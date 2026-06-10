import 'package:flutter/material.dart';

/// Pricing Comparator Widget for Landing Page
/// Side-by-side comparison of 3 packages: KONTAKT, ZDROWIE, AKTYWNY
class PricingComparatorWidget extends StatefulWidget {
  const PricingComparatorWidget({super.key});

  @override
  State<PricingComparatorWidget> createState() =>
      _PricingComparatorWidgetState();
}

class _PricingComparatorWidgetState extends State<PricingComparatorWidget> {
  bool _showAnnual = true;

  final List<PackageTier> _packages = [
    PackageTier(
      name: 'KONTAKT',
      priceMonthly: 99,
      color: const Color(0xFF4CAF50),
      icon: Icons.phone_in_talk,
      description: 'Podstawowy asystent głosowy',
      features: [
        FeatureItem('Asystent głosowy 24/7', true),
        FeatureItem('Przypomnienia o lekach', true),
        FeatureItem('Powiadomienia push', true),
        FeatureItem('Historia rozmów (30 dni)', true),
        FeatureItem('Kontakty alarmowe', true),
        FeatureItem('Monitoring zdrowia', false),
        FeatureItem('Integracja z wearable', false),
        FeatureItem('Cotygodniowe raporty', false),
        FeatureItem('Marketplace', false),
        FeatureItem('Telemedycyna', false),
        FeatureItem('Priorytetowe wsparcie', false),
        FeatureItem('Eksport danych (EMIAL)', false),
      ],
      cta: 'Wypróbuj za darmo',
    ),
    PackageTier(
      name: 'ZDROWIE',
      priceMonthly: 199,
      color: const Color(0xFF2196F3),
      icon: Icons.favorite_border,
      description: 'Monitoring zdrowia + AI',
      recommended: true,
      features: [
        FeatureItem('Asystent głosowy 24/7', true),
        FeatureItem('Przypomnienia o lekach', true),
        FeatureItem('Powiadomienia push', true),
        FeatureItem('Historia rozmów (90 dni)', true),
        FeatureItem('Kontakty alarmowe', true),
        FeatureItem('Monitoring zdrowia', true),
        FeatureItem('Integracja z wearable', true),
        FeatureItem('Cotygodniowe raporty', true),
        FeatureItem('Marketplace', false),
        FeatureItem('Telemedycyna', false),
        FeatureItem('Priorytetowe wsparcie', false),
        FeatureItem('Eksport danych (EMIAL)', true),
      ],
      cta: 'Wybierz ZDROWIE',
    ),
    PackageTier(
      name: 'AKTYWNY',
      priceMonthly: 299,
      color: const Color(0xFF9C27B0),
      icon: Icons.diamond,
      description: 'Pełny pakiet premium',
      features: [
        FeatureItem('Asystent głosowy 24/7', true),
        FeatureItem('Przypomnienia o lekach', true),
        FeatureItem('Powiadomienia push', true),
        FeatureItem('Historia rozmów (bez limitu)', true),
        FeatureItem('Kontakty alarmowe', true),
        FeatureItem('Monitoring zdrowia', true),
        FeatureItem('Integracja z wearable', true),
        FeatureItem('Cotygodniowe raporty', true),
        FeatureItem('Marketplace', true),
        FeatureItem('Telemedycyna', true),
        FeatureItem('Priorytetowe wsparcie', true),
        FeatureItem('Eksport danych (EMIAL)', true),
      ],
      cta: 'Wybierz AKTYWNY',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Column(
      children: [
        // Toggle: Monthly / Annual
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToggleOption('Miesięcznie', !_showAnnual),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => setState(() => _showAnnual = !_showAnnual),
              child: Container(
                width: 56,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: _showAnnual
                      ? const Color(0xFF1B5E20)
                      : Colors.grey.withValues(alpha: 0.4),
                ),
                child: Align(
                  alignment: _showAnnual ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 26,
                    height: 26,
                    margin: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            _buildToggleOption('Rocznie (-15%)', _showAnnual),
          ],
        ),
        const SizedBox(height: 32),
        // Package cards
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _packages
                    .map((p) => Expanded(child: _buildPackageCard(p)))
                    .toList(),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _packages
                      .map((p) => SizedBox(
                            width: 280,
                            child: _buildPackageCard(p),
                          ))
                      .toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildToggleOption(String label, bool active) {
    return GestureDetector(
      onTap: () {
        setState(() => _showAnnual = label.contains('Rocznie'));
      },
      child: Text(
        label,
        style: TextStyle(
          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          color: active ? const Color(0xFF1B5E20) : Colors.grey,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildPackageCard(PackageTier pkg) {
    final monthlyPrice = pkg.priceMonthly.toDouble();
    final displayPrice =
        _showAnnual ? (monthlyPrice * 0.85 * 12).round() : pkg.priceMonthly;
    final periodLabel = _showAnnual ? '/rok' : '/mies';

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: pkg.recommended
              ? pkg.color
              : Colors.grey.withValues(alpha: 0.2),
          width: pkg.recommended ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: pkg.recommended
                ? pkg.color.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (pkg.recommended)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: pkg.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'POLECANE',
                style: TextStyle(
                  color: pkg.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Icon(pkg.icon, color: pkg.color, size: 40),
          const SizedBox(height: 12),
          Text(
            pkg.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            pkg.description,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'zł',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
              ),
              Text(
                '$displayPrice',
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Color(0xFF1B5E20)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  periodLabel,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
            ],
          ),
          if (_showAnnual)
            Text(
              '${pkg.priceMonthly} zł/mies przy rozliczeniu rocznym',
              style: TextStyle(color: const Color(0xFF4CAF50), fontSize: 13),
            ),
          const SizedBox(height: 24),
          ...pkg.features.map((f) => _buildFeatureRow(f)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: pkg.recommended ? pkg.color : Colors.white,
                foregroundColor: pkg.recommended ? Colors.white : pkg.color,
                side: BorderSide(color: pkg.color, width: pkg.recommended ? 0 : 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                pkg.cta,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(FeatureItem feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            feature.included ? Icons.check_circle : Icons.remove_circle_outline,
            color: feature.included ? const Color(0xFF4CAF50) : Colors.grey.withValues(alpha: 0.3),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature.name,
              style: TextStyle(
                fontSize: 14,
                color: feature.included ? const Color(0xFF333333) : Colors.grey,
                decoration: feature.included ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PackageTier {
  final String name;
  final int priceMonthly;
  final Color color;
  final IconData icon;
  final String description;
  final bool recommended;
  final List<FeatureItem> features;
  final String cta;

  PackageTier({
    required this.name,
    required this.priceMonthly,
    required this.color,
    required this.icon,
    required this.description,
    this.recommended = false,
    required this.features,
    required this.cta,
  });
}

class FeatureItem {
  final String name;
  final bool included;

  FeatureItem(this.name, this.included);
}
