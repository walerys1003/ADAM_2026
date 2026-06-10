import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SeniorMarketplaceScreen extends StatefulWidget {
  final String seniorId;

  const SeniorMarketplaceScreen({super.key, required this.seniorId});

  @override
  State<SeniorMarketplaceScreen> createState() => _SeniorMarketplaceScreenState();
}

class _SeniorMarketplaceScreenState extends State<SeniorMarketplaceScreen> {
  final _services = [
    _Service('Sprzątanie mieszkania', 'cleaning', Icons.cleaning_services, 35, 'za godzinę', 4.8),
    _Service('Transport do lekarza', 'transport', Icons.local_taxi, 25, 'za przejazd', 4.9),
    _Service('Dostawa zakupów', 'delivery', Icons.shopping_cart, 15, 'za dostawę', 4.7),
    _Service('Towarzystwo na spacer', 'companion', Icons.directions_walk, 25, 'za godzinę', 4.6),
    _Service('Drobne naprawy', 'repairs', Icons.build, 50, 'za godzinę', 4.5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmWhite,
      appBar: AppBar(
        title: const Text('Zamów Usługę'),
        backgroundColor: AppTheme.navy,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6F00), Color(0xFFE65100)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Icon(Icons.shopping_basket, color: Colors.white, size: 36),
                  SizedBox(height: 8),
                  Text(
                    'Marketplace Usług',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Zamów usługę głosowo przez Adama lub wybierz poniżej',
                    style: TextStyle(fontSize: 15, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // ── Service List ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: InkWell(
                      onTap: () => _showOrderDialog(service),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6F00).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(service.icon, color: const Color(0xFFFF6F00), size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      ...List.generate(
                                        5,
                                        (i) => Icon(
                                          i < service.rating.floor() ? Icons.star : Icons.star_border,
                                          size: 16,
                                          color: AppTheme.gold,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        service.rating.toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${service.price} zł',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.navy,
                                  ),
                                ),
                                Text(
                                  service.unit,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }

  void _showOrderDialog(_Service service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(service.name, style: const TextStyle(fontSize: 22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(service.icon, size: 48, color: const Color(0xFFFF6F00)),
            const SizedBox(height: 16),
            Text(
              'Cena: ${service.price} zł ${service.unit}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Adam zamówi tę usługę dla Ciebie. Potwierdź lub powiedz "Zamawiam" podczas następnej rozmowy.',
              style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anuluj', style: TextStyle(fontSize: 18)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Zamówienie przekazane Adamowi. Potwierdzi podczas rozmowy.'),
                  backgroundColor: AppTheme.navy,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6F00),
              minimumSize: const Size(140, 56),
            ),
            child: const Text('Zamawiam!', style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _Service {
  final String name;
  final String category;
  final IconData icon;
  final int price;
  final String unit;
  final double rating;

  const _Service(this.name, this.category, this.icon, this.price, this.unit, this.rating);
}
