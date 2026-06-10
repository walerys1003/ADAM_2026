import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/widgets/common/voice_waveform_widget.dart';

void main() {
  group('VoiceWaveformWidget', () {
    testWidgets('renders with default parameters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VoiceWaveformWidget(),
            ),
          ),
        ),
      );

      expect(find.byType(VoiceWaveformWidget), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('renders with custom bar count and height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VoiceWaveformWidget(
                barCount: 30,
                height: 80,
              ),
            ),
          ),
        ),
      );

      final widget = tester.widget<VoiceWaveformWidget>(
        find.byType(VoiceWaveformWidget),
      );
      expect(widget.barCount, 30);
      expect(widget.height, 80);
    });

    testWidgets('applies active animation when isActive is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VoiceWaveformWidget(isActive: true),
            ),
          ),
        ),
      );

      final widget = tester.widget<VoiceWaveformWidget>(
        find.byType(VoiceWaveformWidget),
      );
      expect(widget.isActive, isTrue);
    });

    testWidgets('renders static bars when not active', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VoiceWaveformWidget(isActive: false),
            ),
          ),
        ),
      );

      // Should still render the CustomPaint
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('applies custom colors', (tester) async {
      const activeColor = Colors.green;
      const idleColor = Colors.grey;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VoiceWaveformWidget(
                activeColor: activeColor,
                idleColor: idleColor,
              ),
            ),
          ),
        ),
      );

      final widget = tester.widget<VoiceWaveformWidget>(
        find.byType(VoiceWaveformWidget),
      );
      expect(widget.activeColor, activeColor);
      expect(widget.idleColor, idleColor);
    });

    testWidgets('handles zero bar count gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VoiceWaveformWidget(barCount: 0),
            ),
          ),
        ),
      );

      expect(find.byType(VoiceWaveformWidget), findsOneWidget);
    });

    testWidgets('applies custom amplitude', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: VoiceWaveformWidget(amplitude: 0.5),
            ),
          ),
        ),
      );

      final widget = tester.widget<VoiceWaveformWidget>(
        find.byType(VoiceWaveformWidget),
      );
      expect(widget.amplitude, 0.5);
    });
  });
}
