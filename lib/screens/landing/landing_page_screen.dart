import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Marketing Landing Page for families interested in joining the program
class LandingPageScreen extends StatelessWidget {
  const LandingPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildNavbar(context),
            _buildHero(),
            _buildProblem(),
            _buildHowItWorks(),
            _buildFeatures(),
            _buildPricing(),
            _buildTestimonials(),
            _buildFAQ(),
            _buildCTA(),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ── NAVBAR ──
  Widget _buildNavbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const Row(
            children: [
              Icon(Icons.phone_in_talk, color: AppTheme.gold, size: 32),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SilverTech', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.navy)),
                  Text('Adam - Przyjaciel Seniora', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text('Jak działa', style: TextStyle(color: AppTheme.textPrimary))),
          const SizedBox(width: 16),
          TextButton(onPressed: () {}, child: const Text('Pakiety', style: TextStyle(color: AppTheme.textPrimary))),
          const SizedBox(width: 16),
          TextButton(onPressed: () {}, child: const Text('FAQ', style: TextStyle(color: AppTheme.textPrimary))),
          const SizedBox(width: 16),
          TextButton(onPressed: () {}, child: const Text('Kontakt', style: TextStyle(color: AppTheme.textPrimary))),
          const SizedBox(width: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.navy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Sprawdź pakiety', style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  // ── HERO ──
  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.navy, Color(0xFF2A5078)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.phone_in_talk, color: AppTheme.gold, size: 48),
          ),
          const SizedBox(height: 32),
          const Text(
            'Twój bliski nigdy nie jest sam.',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            'Adam to asystent głosowy AI, który codziennie dzwoni do Twojej Mamy lub Taty,\npyta o samopoczucie, przypomina o lekach i alarmuje w razie potrzeby.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold,
                  foregroundColor: AppTheme.navy,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Sprawdź pakiety'),
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Umów demo'),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: AppTheme.gold, size: 22),
              const SizedBox(width: 4),
              const Text('4.9/5', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(width: 12),
              Text('·', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 20)),
              const SizedBox(width: 12),
              const Text('Zaufali nam seniorzy w Poznaniu', style: TextStyle(fontSize: 16, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }

  // ── PROBLEM SECTION ──
  Widget _buildProblem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      color: AppTheme.warmWhite,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('PROBLEM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.red, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Czy martwisz się o samotnego rodzica mieszkającego daleko?',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.textPrimary, height: 1.3),
                ),
                const SizedBox(height: 24),
                const _ProblemItem(icon: Icons.access_time, text: 'Nie masz czasu dzwonić codziennie — praca, dzieci, życie'),
                const SizedBox(height: 12),
                const _ProblemItem(icon: Icons.heart_broken, text: 'Boisz się, że rodzic przewróci się i nikt nie będzie wiedział'),
                const SizedBox(height: 12),
                const _ProblemItem(icon: Icons.medical_services, text: 'Martwisz się o leki — czy na pewno wziął je o właściwej porze?'),
                const SizedBox(height: 12),
                const _ProblemItem(icon: Icons.nightlight, text: 'Nie śpisz spokojnie, myśląc "czy wszystko w porządku?"'),
              ],
            ),
          ),
          const SizedBox(width: 60),
          Expanded(
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20)],
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_disabled, color: AppTheme.textLight, size: 64),
                    SizedBox(height: 16),
                    Text('Brak kontaktu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                    SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        '83% rodzin z dorosłymi dziećmi mieszkającymi >50km od rodziców martwi się o ich bezpieczeństwo codziennie.',
                        style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HOW IT WORKS ──
  Widget _buildHowItWorks() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('JAK TO DZIAŁA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.navy, letterSpacing: 1.5)),
          ),
          const SizedBox(height: 20),
          const Text('Proste jak rozmowa telefoniczna', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          Row(
            children: [
              _stepCard('1', 'Wybierz pakiet', 'Od 99 zł miesięcznie. Bez umowy, bez zobowiązań.', Icons.touch_app, const Color(0xFF1976D2)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, color: AppTheme.textLight, size: 32),
              ),
              _stepCard('2', 'Odbierz opaskę', 'Xiaomi Smart Band 9 Pro (149 zł). Monitoruje tętno, SpO2, sen.', Icons.watch, const Color(0xFFE91E63)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, color: AppTheme.textLight, size: 32),
              ),
              _stepCard('3', 'Rozmawia codziennie', 'Adam dzwoni rano i wieczorem. Naturalna rozmowa po polsku.', Icons.phone_in_talk, AppTheme.gold),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, color: AppTheme.textLight, size: 32),
              ),
              _stepCard('4', 'Śpij spokojnie', 'Dostajesz podsumowania i alerty. My czuwamy 24/7.', Icons.nightlight, AppTheme.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepCard(String number, String title, String desc, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 12)],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                ),
                Icon(icon, color: color, size: 36),
              ],
            ),
            const SizedBox(height: 16),
            Text(number, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── FEATURES ──
  Widget _buildFeatures() {
    final features = [
      _Feature('Codzienne rozmowy', '15-minutowa rozmowa z empatycznym AI — bez obciążania rodziny', Icons.phone_in_talk, AppTheme.navy),
      _Feature('Przypomnienia o lekach', 'Adam przypomni o każdej dawce i potwierdzi, że lek został wzięty', Icons.medical_services, const Color(0xFF1976D2)),
      _Feature('Monitoring zdrowia', 'Tętno, SpO2, kroki, sen — wszystko z opaski Xiaomi na nadgarstku', Icons.favorite, AppTheme.red),
      _Feature('Alerty SOS', 'Wykrywanie upadku, ciszy, słów kryzysowych — natychmiastowe powiadomienie', Icons.warning_amber, AppTheme.orange),
      _Feature('Raporty dla rodziny', 'Cotygodniowe podsumowanie: nastrój, aktywność, zdrowie', Icons.email, const Color(0xFF4CAF50)),
      _Feature('Marketplace usług', 'Zamawianie sprzątania, transportu, zakupów — głosowo przez Adama', Icons.shopping_basket, const Color(0xFFFF6F00)),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      color: AppTheme.warmWhite,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('FUNKCJE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.navy, letterSpacing: 1.5)),
          ),
          const SizedBox(height: 20),
          const Text('Wszystko, czego potrzebuje Twój bliski', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: features.map((f) => SizedBox(
              width: 350,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: f.color.withValues(alpha: 0.06), blurRadius: 12)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: f.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(f.icon, color: f.color, size: 30),
                    ),
                    const SizedBox(height: 18),
                    Text(f.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(f.description, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5)),
                  ],
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  // ── PRICING ──
  Widget _buildPricing() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.navy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('PAKIETY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.navy, letterSpacing: 1.5)),
          ),
          const SizedBox(height: 20),
          const Text('Proste ceny, bez ukrytych kosztów', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          Row(
            children: [
              _pricingCard('KONTAKT', 99, 'Podstawowa opieka', [
                '2 rozmowy dziennie (poranna + wieczorna)',
                'Przypomnienia o lekach',
                'SMS do rodziny po każdej rozmowie',
                'Historia rozmów',
                'Check-in poranny',
              ], false),
              const SizedBox(width: 24),
              _pricingCard('ZDROWIE', 199, 'Najpopularniejszy', [
                'Wszystko z pakietu KONTAKT',
                'Opaska Xiaomi Smart Band 9 Pro',
                'Monitoring tętna 24/7',
                'Monitoring SpO2 (saturacja)',
                'Monitoring snu',
                'Powiadomienia zdrowotne',
                'Raport zdrowotny tygodniowy',
              ], true),
              const SizedBox(width: 24),
              _pricingCard('AKTYWNY', 299, 'Pełna opieka', [
                'Wszystko z pakietu ZDROWIE',
                'Apple Watch SE (fall detection)',
                'Wizyty opiekuna (2x/miesiąc)',
                'Marketplace usług (5 usług)',
                'Priorytetowa eskalacja',
                'Dedykowany koordynator',
              ], false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pricingCard(String name, int price, String subtitle, List<String> features, bool popular) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: popular ? AppTheme.gold : Colors.grey.shade200,
            width: popular ? 3 : 1,
          ),
          boxShadow: [BoxShadow(
            color: (popular ? AppTheme.gold : Colors.black).withValues(alpha: popular ? 0.15 : 0.06),
            blurRadius: 20,
          )],
        ),
        child: Column(
          children: [
            if (popular)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.gold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('NAJPOPULARNIEJSZY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.navy)),
              ),
            const SizedBox(height: 20),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.navy, letterSpacing: 1)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('zł', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                Text('$price', style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: AppTheme.navy, height: 1)),
                const Text('/mc', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
              ],
            ),
            const SizedBox(height: 32),
            ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(f, style: const TextStyle(fontSize: 14))),
                ],
              ),
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: popular ? AppTheme.gold : AppTheme.navy,
                  foregroundColor: popular ? AppTheme.navy : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Wybierz'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TESTIMONIALS ──
  Widget _buildTestimonials() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      color: AppTheme.navy,
      child: Column(
        children: [
          const Text('Co mówią rodziny', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 50),
          Row(
            children: [
              _testimonialCard(
                'Od kiedy moja mama ma Adama, w końcu mogę spać spokojnie. Adam wykrył już jeden niepokojący spadek tętna i natychmiast nas powiadomił.',
                'Anna W.', 'córka pani Marii (78 lat)', 5,
              ),
              const SizedBox(width: 24),
              _testimonialCard(
                'Mój tata początkowo był sceptyczny. Po tygodniu sam czeka na telefon od Adama. Rozmawiają o ogrodzie, wnukach, historii. To nie jest robot — to przyjaciel.',
                'Piotr K.', 'syn pana Jana (82 lata)', 5,
              ),
              const SizedBox(width: 24),
              _testimonialCard(
                'Jestem lekarzem. Doceniam, że Adam nie diagnozuje — tylko monitoruje i alarmuje. To odpowiedzialne podejście. Moja babcia czuje się bezpieczniej.',
                'dr Katarzyna M.', 'wnuczka pani Heleny (76 lat)', 5,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _testimonialCard(String quote, String name, String relation, int stars) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(stars, (_) => const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.star, color: AppTheme.gold, size: 20),
              )),
            ),
            const SizedBox(height: 18),
            Text(quote, style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.6, fontStyle: FontStyle.italic)),
            const SizedBox(height: 18),
            Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.gold)),
            Text(relation, style: const TextStyle(fontSize: 13, color: Colors.white60)),
          ],
        ),
      ),
    );
  }

  // ── FAQ ──
  Widget _buildFAQ() {
    final faqs = [
      _FAQ('Czy senior musi mieć smartfon?', 'Nie! Adam dzwoni na zwykły telefon stacjonarny lub komórkowy z dużymi przyciskami. Senior nie potrzebuje żadnej aplikacji.'),
      _FAQ('Czy rozmowa brzmi naturalnie?', 'Tak. Używamy zaawansowanego AI (Gemini Flash + OpenAI TTS), które prowadzi naturalne rozmowy po polsku. Adam ma ciepły, męski głos.'),
      _FAQ('Co się dzieje w razie awarii?', 'System ma wbudowany fallback: jeśli główny model AI jest niedostępny, automatycznie przełączamy się na zapasowy. Senior nie odczuje różnicy.'),
      _FAQ('Czy dane są bezpieczne?', 'Tak. Jesteśmy w pełni zgodni z RODO. Nagrania są przechowywane tylko 14 dni, dane szyfrowane, a Ty masz pełną kontrolę.'),
      _FAQ('Czy Adam zastępuje kontakt z rodziną?', 'Nigdy! Adam uzupełnia, nie zastępuje. Dostajesz podsumowania i alerty, żebyś wiedział(a), kiedy naprawdę trzeba zadzwonić.'),
      _FAQ('Jak działa opaska?', 'Xiaomi Smart Band 9 Pro (149 zł) mierzy tętno, SpO2, kroki i sen. Ładuje się raz na 21 dni. W razie potrzeby pomagamy w konfiguracji.'),
      _FAQ('Czy mogę zrezygnować?', 'Tak, umowa jest miesięczna — bez zobowiązań. Wypowiedzenie z 30-dniowym okresem.'),
      _FAQ('Gdzie działa usługa?', 'Obecnie w Poznaniu i okolicach (woj. wielkopolskie). Planujemy ekspansję na całą Polskę.'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      color: AppTheme.warmWhite,
      child: Column(
        children: [
          const Text('Często zadawane pytania', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: faqs.map((faq) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                ),
                child: ExpansionTile(
                  title: Text(faq.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: Text(faq.answer, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── CTA ──
  Widget _buildCTA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.gold, Color(0xFFFFC04D)]),
      ),
      child: Column(
        children: [
          const Text(
            'Dołącz do 180 rodzin w Poznaniu,\nktóre już śpią spokojnie.',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.navy, height: 1.3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          const Text(
            ' Zacznij od darmowej konsultacji. Pokażemy Ci, jak działa Adam.',
            style: TextStyle(fontSize: 18, color: AppTheme.navy, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Umów bezpłatną konsultację'),
              ),
              const SizedBox(width: 20),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.navy,
                  side: const BorderSide(color: AppTheme.navy, width: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Zadzwoń: +48 61 XXX XXX'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── FOOTER ──
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(40),
      color: const Color(0xFF142B45),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.phone_in_talk, color: AppTheme.gold, size: 28),
                        SizedBox(width: 8),
                        Text('SilverTech', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text('Spółdzielnia Socjalna SilverTech\nPoznań, Polska\nkontakt@silvertech.pl', style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.8)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Produkt', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 16),
                    ...['Jak działa', 'Pakiety', 'Funkcje', 'FAQ', 'Blog'].map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(t, style: const TextStyle(fontSize: 13, color: Colors.white60)),
                    )),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Firma', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 16),
                    ...['O nas', 'Zespół', 'Kariera', 'Kontakt', 'Dla inwestorów'].map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(t, style: const TextStyle(fontSize: 13, color: Colors.white60)),
                    )),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Prawne', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                    const SizedBox(height: 16),
                    ...['Polityka prywatności', 'RODO', 'Regulamin', 'AI Act'].map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(t, style: const TextStyle(fontSize: 13, color: Colors.white60)),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('© 2026 SilverTech Spółdzielnia Socjalna. Wszelkie prawa zastrzeżone.', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
              const Spacer(),
              ...['Facebook', 'LinkedIn', 'Instagram'].map((s) => Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(s, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProblemItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ProblemItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.red, size: 22),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
      ],
    );
  }
}

class _Feature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _Feature(this.title, this.description, this.icon, this.color);
}

class _FAQ {
  final String question;
  final String answer;

  const _FAQ(this.question, this.answer);
}
