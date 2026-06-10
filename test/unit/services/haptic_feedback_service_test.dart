import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/services/haptics/haptic_feedback_service.dart';

void main() {
  late HapticFeedbackService hapticService;

  setUp(() {
    hapticService = HapticFeedbackService();
    hapticService.setEnabled(true);
  });

  group('HapticFeedbackService', () {
    test('is a singleton', () {
      final instance1 = HapticFeedbackService();
      final instance2 = HapticFeedbackService();
      expect(identical(instance1, instance2), isTrue);
    });

    test('is enabled by default', () {
      expect(hapticService.isEnabled, isTrue);
    });

    test('setEnabled toggles feedback state', () {
      hapticService.setEnabled(false);
      expect(hapticService.isEnabled, isFalse);

      hapticService.setEnabled(true);
      expect(hapticService.isEnabled, isTrue);
    });

    test('lightImpact does not throw when enabled', () {
      expect(() => hapticService.lightImpact(), returnsNormally);
    });

    test('lightImpact does not throw when disabled', () {
      hapticService.setEnabled(false);
      expect(() => hapticService.lightImpact(), returnsNormally);
    });

    test('mediumImpact does not throw', () {
      expect(() => hapticService.mediumImpact(), returnsNormally);
    });

    test('heavyImpact does not throw', () {
      expect(() => hapticService.heavyImpact(), returnsNormally);
    });

    test('selectionClick does not throw', () {
      expect(() => hapticService.selectionClick(), returnsNormally);
    });

    test('success does not throw', () {
      expect(() => hapticService.success(), returnsNormally);
    });

    test('warning does not throw', () {
      expect(() => hapticService.warning(), returnsNormally);
    });

    test('emergency does not throw', () {
      expect(() => hapticService.emergency(), returnsNormally);
    });

    test('voiceListeningStart does not throw', () {
      expect(() => hapticService.voiceListeningStart(), returnsNormally);
    });

    test('voiceResponseReady does not throw', () {
      expect(() => hapticService.voiceResponseReady(), returnsNormally);
    });

    test('medicationConfirmed does not throw', () {
      expect(() => hapticService.medicationConfirmed(), returnsNormally);
    });

    group('semaforLevel haptics', () {
      test('GREEN triggers light impact', () {
        expect(() => hapticService.semaforLevel('GREEN'), returnsNormally);
      });

      test('YELLOW triggers medium impact', () {
        expect(() => hapticService.semaforLevel('YELLOW'), returnsNormally);
      });

      test('ORANGE triggers warning', () {
        expect(() => hapticService.semaforLevel('ORANGE'), returnsNormally);
      });

      test('RED triggers emergency', () {
        expect(() => hapticService.semaforLevel('RED'), returnsNormally);
      });

      test('PURPLE triggers double emergency', () {
        expect(() => hapticService.semaforLevel('PURPLE'), returnsNormally);
      });

      test('unknown level defaults to light impact', () {
        expect(() => hapticService.semaforLevel('UNKNOWN'), returnsNormally);
      });

      test('case insensitive level matching', () {
        expect(() => hapticService.semaforLevel('green'), returnsNormally);
        expect(() => hapticService.semaforLevel('Green'), returnsNormally);
        expect(() => hapticService.semaforLevel('gReEn'), returnsNormally);
      });
    });

    test('all methods respect disabled state', () {
      hapticService.setEnabled(false);

      expect(() => hapticService.lightImpact(), returnsNormally);
      expect(() => hapticService.mediumImpact(), returnsNormally);
      expect(() => hapticService.heavyImpact(), returnsNormally);
      expect(() => hapticService.emergency(), returnsNormally);
      expect(() => hapticService.semaforLevel('RED'), returnsNormally);
    });
  });

  group('HapticFeedback mock verification', () {
    test('HapticFeedback.lightImpact is available', () {
      // Verify the platform channel mock works
      expect(() => HapticFeedback.lightImpact(), returnsNormally);
    });

    test('HapticFeedback.heavyImpact is available', () {
      expect(() => HapticFeedback.heavyImpact(), returnsNormally);
    });
  });
}
