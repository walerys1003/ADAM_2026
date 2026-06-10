import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/widgets/senior/mood_tracker_widget.dart';

void main() {
  group('MoodTrackerWidget', () {
    testWidgets('renders all 5 mood options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MoodTrackerWidget(),
            ),
          ),
        ),
      );

      expect(find.byType(MoodTrackerWidget), findsOneWidget);

      // All 5 mood emojis should be visible
      expect(find.text('😄'), findsOneWidget);
      expect(find.text('🙂'), findsOneWidget);
      expect(find.text('😐'), findsOneWidget);
      expect(find.text('😔'), findsOneWidget);
      expect(find.text('😢'), findsOneWidget);
    });

    testWidgets('calls onMoodSelected when tapping a mood', (tester) async {
      MoodLevel? selectedMood;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MoodTrackerWidget(
                onMoodSelected: (mood) => selectedMood = mood,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('😄'));
      await tester.pump();

      expect(selectedMood, MoodLevel.veryGood);
    });

    testWidgets('tapping "Very Bad" mood sets correct value', (tester) async {
      MoodLevel? selectedMood;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MoodTrackerWidget(
                onMoodSelected: (mood) => selectedMood = mood,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('😢'));
      await tester.pump();

      expect(selectedMood, MoodLevel.veryBad);
    });

    testWidgets('initialMood sets the starting mood', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MoodTrackerWidget(
                initialMood: MoodLevel.neutral,
              ),
            ),
          ),
        ),
      );

      // The neutral mood label should be displayed
      expect(find.text('Średnio 😐'), findsOneWidget);
    });

    testWidgets('selected mood shows its label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MoodTrackerWidget(
                onMoodSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // Tap the neutral emoji
      await tester.tap(find.text('😐'));
      await tester.pump();

      // Label "Średnio 😐" should appear
      expect(find.text('Średnio 😐'), findsOneWidget);
    });

    testWidgets('all moods are tappable', (tester) async {
      final receivedMoods = <MoodLevel>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MoodTrackerWidget(
                onMoodSelected: (mood) => receivedMoods.add(mood),
              ),
            ),
          ),
        ),
      );

      final moodEmojis = ['😄', '🙂', '😐', '😔', '😢'];

      for (final emoji in moodEmojis) {
        await tester.tap(find.text(emoji));
        await tester.pump();
      }

      expect(receivedMoods.length, 5);
      expect(receivedMoods, [
        MoodLevel.veryGood,
        MoodLevel.good,
        MoodLevel.neutral,
        MoodLevel.bad,
        MoodLevel.veryBad,
      ]);
    });

    testWidgets('handles null onMoodSelected gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: MoodTrackerWidget(),
            ),
          ),
        ),
      );

      // Tapping should not crash
      await tester.tap(find.text('😄'));
      await tester.pump();

      expect(find.byType(MoodTrackerWidget), findsOneWidget);
    });

    testWidgets('MoodLevel enum has correct values', (tester) async {
      expect(MoodLevel.values.length, 5);
      expect(MoodLevel.veryGood.emoji, '😄');
      expect(MoodLevel.good.emoji, '🙂');
      expect(MoodLevel.neutral.emoji, '😐');
      expect(MoodLevel.bad.emoji, '😔');
      expect(MoodLevel.veryBad.emoji, '😢');
    });

    testWidgets('MoodLevel colors are distinct', (tester) async {
      final colors = MoodLevel.values.map((m) => m.color).toSet();
      // Each mood should have a unique color
      expect(colors.length, 5);
    });
  });
}
