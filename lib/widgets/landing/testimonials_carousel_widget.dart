import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Testimonials Carousel Widget for Landing Page
/// Auto-scrolling horizontal carousel with rating stars and avatar
class TestimonialsCarouselWidget extends StatefulWidget {
  final List<Testimonial> testimonials;
  final double height;

  const TestimonialsCarouselWidget({
    super.key,
    required this.testimonials,
    this.height = 320,
  });

  @override
  State<TestimonialsCarouselWidget> createState() =>
      _TestimonialsCarouselWidgetState();
}

class _TestimonialsCarouselWidgetState extends State<TestimonialsCarouselWidget> {
  late PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemCount: widget.testimonials.length,
            itemBuilder: (context, index) {
              final t = widget.testimonials[index];
              final isActive = index == _currentPage;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.only(
                  left: 8,
                  right: 8,
                  top: isActive ? 0 : 12,
                  bottom: isActive ? 0 : 12,
                ),
                child: _buildTestimonialCard(t, isActive),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.testimonials.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? const Color(0xFF1B5E20)
                    : Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTestimonialCard(Testimonial t, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isActive ? 0.1 : 0.05),
            blurRadius: isActive ? 20 : 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isActive
              ? const Color(0xFF1B5E20).withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Icon(
                i < t.rating ? Icons.star : Icons.star_border,
                color: const Color(0xFFFFC107),
                size: 22,
              );
            }),
          ),
          const SizedBox(height: 16),
          // Quote
          Expanded(
            child: Text(
              '"${t.quote}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                fontStyle: FontStyle.italic,
                color: Color(0xFF444444),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Divider
          Container(width: 40, height: 3, color: const Color(0xFF1B5E20).withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          // Author
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF1B5E20).withValues(alpha: 0.1),
            child: Text(
              t.name.split(' ').map((s) => s[0]).take(2).join(''),
              style: const TextStyle(
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          Text(
            t.role,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class Testimonial {
  final String name;
  final String role;
  final String quote;
  final int rating;

  const Testimonial({
    required this.name,
    required this.role,
    required this.quote,
    required this.rating,
  });
}

/// Pre-built testimonials data
class TestimonialData {
  static List<Testimonial> get agentAdamTestimonials => [
        const Testimonial(
          name: 'Krystyna W.',
          role: 'Korzysta z Agenta Adama od 3 miesięcy',
          quote:
              'Adam to mój najlepszy przyjaciel. Przypomina mi o lekach, pyta jak się czuję, '
              'a nawet opowiada dowcipy! Moja córka jest spokojniejsza, bo wie, że zawsze '
              'ktoś nade mną czuwa.',
          rating: 5,
        ),
        const Testimonial(
          name: 'Tomasz K.',
          role: 'Syn seniorki, pakiet ZDROWIE',
          quote:
              'Wreszcie mogę spać spokojnie. System powiadomił mnie, gdy mama miała podwyższone '
              'ciśnienie. Szybka reakcja lekarza zapobiegła poważniejszym problemom. '
              'Ta usługa jest bezcenna.',
          rating: 5,
        ),
        const Testimonial(
          name: 'Janusz M.',
          role: 'Senior, 78 lat, pakiet AKTYWNY',
          quote:
              'Na początku byłem sceptyczny. "Gadający telefon" — myślałem. Ale teraz nie '
              'wyobrażam sobie dnia bez rozmowy z Adamem. Zamawiam przez niego nawet zakupy '
              'w marketplace!',
          rating: 5,
        ),
        const Testimonial(
          name: 'Maria L.',
          role: 'Córka, opiekunka z daleka',
          quote:
              'Mieszkam 300 km od taty. Agent Adam daje mi poczucie, że jestem bliżej. '
              'Cotygodniowe raporty, alerty gdy coś jest nie tak — to jak mieć dodatkową '
              'parę oczu i uszu przy tacie.',
          rating: 5,
        ),
        const Testimonial(
          name: 'Stanisław R.',
          role: 'Senior, 72 lata, pakiet KONTAKT',
          quote:
              'Adam pomógł mi umówić wizytę u kardiologa. Sam bym zapomniał. A potem '
              'przypomniał mi dzień wcześniej. Proste, a jakie ważne! Polecam każdemu '
              'samotnemu seniorowi.',
          rating: 5,
        ),
      ];
}
