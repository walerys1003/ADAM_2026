import 'package:flutter/material.dart';

/// Landing page features showcase section.
/// Displays key features in a responsive grid with icons,
/// titles, descriptions, and optional animations.
class FeaturesSectionWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<FeatureItem> features;
  final int crossAxisCount;

  const FeaturesSectionWidget({
    super.key,
    this.title = 'Dlaczego Agent Adam?',
    this.subtitle = 'Kompleksowe wsparcie dla Seniorów i ich rodzin',
    this.features = defaultFeatures,
    this.crossAxisCount = 3,
  });

  @override
  State<FeaturesSectionWidget> createState() => _FeaturesSectionWidgetState();
}

class _FeaturesSectionWidgetState extends State<FeaturesSectionWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Staggered entrance animation would be added here with animation controllers
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final columns = isMobile ? 1 : (MediaQuery.of(context).size.width < 1024 ? 2 : widget.crossAxisCount);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 48 : 80,
      ),
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Section header
          Text(
            widget.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            widget.subtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Features grid
          LayoutBuilder(
            builder: (context, constraints) {
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: widget.features.map((feature) {
                  return SizedBox(
                    width: constraints.maxWidth / columns - 24 * (columns - 1) / columns,
                    child: _FeatureCard(feature: feature),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final FeatureItem feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    feature.iconColor,
                    feature.iconColor.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                feature.icon,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              feature.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feature.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            if (feature.bulletPoints.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...feature.bulletPoints.map((point) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: feature.iconColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        point,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}

/// Feature item model
class FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final List<String> bulletPoints;

  const FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    this.bulletPoints = const [],
  });
}

/// Default features for Agent Adam landing page
const List<FeatureItem> defaultFeatures = [
  FeatureItem(
    icon: Icons.mic,
    title: 'Asystent głosowy 24/7',
    description: 'Naturalna rozmowa głosowa w języku polskim. '
        'Adam rozumie kontekst, pamięta historię rozmów i dostosowuje '
        'się do potrzeb Seniora.',
    iconColor: Color(0xFF6366F1),
    bulletPoints: [
      'Rozpoznawanie mowy Deepgram Nova-3',
      'Synteza mowy OpenAI TTS-1',
      'Pamięć kontekstowa RAG z pgvector',
    ],
  ),
  FeatureItem(
    icon: Icons.favorite,
    title: 'Monitorowanie zdrowia',
    description: 'Automatyczne śledzenie parametrów zdrowotnych '
        'z opaski Xiaomi Smart Band 9 Pro. System Semafor '
        'natychmiast wykrywa niepokojące zmiany.',
    iconColor: Color(0xFFDC2626),
    bulletPoints: [
      'Tętno, ciśnienie, SpO2, sen',
      '4-poziomowy system Semafor',
      'Automatyczne alerty do rodziny',
    ],
  ),
  FeatureItem(
    icon: Icons.medication,
    title: 'Przypomnienia o lekach',
    description: 'Inteligentny system przypomnień z potwierdzeniem '
        'przyjęcia leków. Rodzina otrzymuje powiadomienia '
        'o pominiętych dawkach.',
    iconColor: Color(0xFF059669),
    bulletPoints: [
      'Powiadomienia push i głosowe',
      'Śledzenie adherencji tygodniowej',
      'Alerty o pominiętych dawkach',
    ],
  ),
  FeatureItem(
    icon: Icons.people,
    title: 'Panel rodzinny',
    description: 'Bliscy mają pełny wgląd w stan zdrowia, '
        'aktywność i samopoczucie Seniora. Otrzymują alerty '
        'i cotygodniowe raporty.',
    iconColor: Color(0xFFD97706),
    bulletPoints: [
      'Dashboard zdrowia w czasie rzeczywistym',
      'Kalendarz wizyt i leków',
      'Konfigurowalne reguły alertów',
    ],
  ),
  FeatureItem(
    icon: Icons.security,
    title: 'Bezpieczeństwo danych',
    description: 'Pełna zgodność z RODO i EU AI Act. '
        'Dane szyfrowane end-to-end, serwery w UE '
        '(Hetzner, Niemcy).',
    iconColor: Color(0xFF7C3AED),
    bulletPoints: [
      'Szyfrowanie AES-256',
      'Serwery w Unii Europejskiej',
      'Zgodność z EU AI Act (Limited Risk)',
    ],
  ),
  FeatureItem(
    icon: Icons.touch_app,
    title: 'Dostępność dla Seniora',
    description: 'Duże przyciski, wysoki kontrast, '
        'sterowanie głosowe. Aplikacja zaprojektowana '
        'z myślą o osobach starszych.',
    iconColor: Color(0xFF0891B2),
    bulletPoints: [
      'Przyciski min. 56dp',
      'Skalowanie czcionek do 1.5x',
      'Obsługa TalkBack',
    ],
  ),
];
