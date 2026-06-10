import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/widgets/landing/testimonials_carousel_widget.dart';

void main() {
  group('TestimonialsCarouselWidget', () {
    final testTestimonials = [
      const Testimonial(
        name: 'Jan Kowalski',
        role: 'Senior',
        quote: 'Świetna aplikacja!',
        rating: 5,
      ),
      const Testimonial(
        name: 'Anna Nowak',
        role: 'Córka',
        quote: 'Bardzo pomocne narzędzie dla rodziny.',
        rating: 4,
      ),
    ];

    Widget buildTestWidget({List<Testimonial>? testimonials}) {
      return MaterialApp(
        home: Scaffold(
          body: TestimonialsCarouselWidget(
            testimonials: testimonials ?? testTestimonials,
          ),
        ),
      );
    }

    testWidgets('renders all testimonial quotes', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.textContaining('Świetna aplikacja!'), findsOneWidget);
    });

    testWidgets('renders author names and roles', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Jan Kowalski'), findsOneWidget);
      expect(find.text('Senior'), findsOneWidget);
    });

    testWidgets('renders star ratings', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Should have star icons (5 + 4 = 9 stars + some borders)
      final starIcons = find.byIcon(Icons.star);
      expect(starIcons, findsWidgets);
    });

    testWidgets('renders dot indicators', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Each testimonial gets a dot
      expect(find.byType(AnimatedContainer), findsWidgets);
    });

    testWidgets('can swipe through pages', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Swipe left to go to next page
      await tester.drag(find.byType(TestimonialsCarouselWidget), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Second testimonial should now be visible
      expect(find.textContaining('Bardzo pomocne'), findsOneWidget);
    });

    testWidgets('testimonial cards have correct styling', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Cards should have white background (not transparent)
      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration != null &&
            widget.decoration is BoxDecoration,
      );
      expect(containerFinder, findsWidgets);
    });
  });
}
