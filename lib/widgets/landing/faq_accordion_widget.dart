import 'package:flutter/material.dart';

/// FAQ Accordion Widget for Landing Page
/// Animated expand/collapse with Material Design transitions
class FaqAccordionWidget extends StatefulWidget {
  final List<FaqItem> items;

  const FaqAccordionWidget({super.key, required this.items});

  @override
  State<FaqAccordionWidget> createState() => _FaqAccordionWidgetState();
}

class _FaqAccordionWidgetState extends State<FaqAccordionWidget> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.items.length, (index) {
        final isExpanded = _expandedIndex == index;
        final item = widget.items[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isExpanded ? const Color(0xFF1B5E20).withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExpanded
                  ? const Color(0xFF1B5E20).withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.3),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _expandedIndex = isExpanded ? null : index;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedCrossFade(
                firstChild: _buildCollapsed(item),
                secondChild: _buildExpanded(item, index),
                crossFadeState:
                    isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCollapsed(FaqItem item) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.question,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[600],
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildExpanded(FaqItem item, int index) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.question,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B5E20),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _expandedIndex = null),
                icon: Icon(Icons.keyboard_arrow_up, color: Colors.grey[600]),
                iconSize: 28,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.answer,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});
}

/// Pre-built FAQ data for landing page
class FaqData {
  static List<FaqItem> get agentAdamFaq => [
        const FaqItem(
          question: 'Czym jest Agent Adam?',
          answer:
              'Agent Adam to zaawansowany asystent głosowy AI stworzony przez SilverTech, '
              'zaprojektowany specjalnie dla seniorów. Działa jak przyjazny towarzysz rozmowy — '
              'przypomina o lekach, umawia wizyty lekarskie, monitoruje samopoczucie i służy '
              'pomocą 24 godziny na dobę, 7 dni w tygodniu.',
        ),
        const FaqItem(
          question: 'Jak działa system powiadamiania rodziny?',
          answer:
              'System wykorzystuje 4-poziomowy semafor (ZIELONY, ŻÓŁTY, POMARAŃCZOWY, CZERWONY, '
              'FIOLETOWY). Przy POMARAŃCZOWYM rodzina otrzymuje powiadomienie push i SMS. '
              'Przy CZERWONYM system automatycznie dzwoni do wskazanych kontaktów alarmowych. '
              'Przy FIOLETOWYM (zagrożenie życia) automatycznie wzywane jest pogotowie.',
        ),
        const FaqItem(
          question: 'Czy dane zdrowotne są bezpieczne?',
          answer:
              'Tak, Agent Adam jest w pełni zgodny z RODO (GDPR). Wszystkie dane są szyfrowane '
              '(AES-256 w spoczynku, TLS 1.3 w transmisji), przechowywane na serwerach w UE '
              '(Hetzner, Niemcy/FInlandia), a dostęp do nich ma wyłącznie upoważniony personel. '
              'Senior ma pełną kontrolę nad zgodami na przetwarzanie danych.',
        ),
        const FaqItem(
          question: 'Jaki jest koszt korzystania z Agenta Adama?',
          answer:
              'Oferujemy trzy pakiety: KONTAKT (99 zł/mies) — podstawowy asystent głosowy, '
              'ZDROWIE (199 zł/mies) — rozszerzony o monitoring zdrowia i integrację z wearable, '
              'AKTYWNY (299 zł/mies) — pełny pakiet z marketplacem, telemedycyną i priorytetowym wsparciem.',
        ),
        const FaqItem(
          question: 'Czy senior musi umieć obsługiwać smartfon?',
          answer:
              'Nie! Agent Adam działa głównie głosowo — senior po prostu mówi, tak jak rozmawia '
              'się z drugim człowiekiem. Interfejs aplikacji został zaprojektowany z myślą o '
              'osobach starszych: duże przyciski (minimum 56px), wysoki kontrast, uproszczona '
              'nawigacja i opcjonalny tryb ultra-uproszczony.',
        ),
        const FaqItem(
          question: 'Czy mogę wypróbować przed zakupem?',
          answer:
              'Tak, oferujemy 14-dniowy bezpłatny okres próbny pakietu KONTAKT. '
              'Nie wymagamy karty kredytowej — wystarczy numer telefonu. Po okresie próbnym '
              'możesz wybrać dowolny pakiet lub zrezygnować bez żadnych opłat.',
        ),
        const FaqItem(
          question: 'Jakie urządzenia wearable są kompatybilne?',
          answer:
              'Agent Adam integruje się z Xiaomi Smart Band 9 Pro poprzez Google Health Connect API v2. '
              'Monitorujemy: tętno, ciśnienie krwi (modele z czujnikiem), saturację (SpO2), '
              'jakość snu, liczbę kroków i temperaturę ciała. Planujemy wsparcie dla kolejnych urządzeń.',
        ),
      ];
}
