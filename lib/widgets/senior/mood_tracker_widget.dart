import 'package:flutter/material.dart';

/// Senior Mood Tracker Widget — Quick mood logging with emoji
/// 5 moods: Very Good → Very Bad with haptic feedback
class MoodTrackerWidget extends StatefulWidget {
  final ValueChanged<MoodLevel>? onMoodSelected;
  final MoodLevel? initialMood;

  const MoodTrackerWidget({super.key, this.onMoodSelected, this.initialMood});

  @override
  State<MoodTrackerWidget> createState() => _MoodTrackerWidgetState();
}

class _MoodTrackerWidgetState extends State<MoodTrackerWidget> {
  MoodLevel? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialMood;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          const Text(
            'Jak się dziś czujesz?',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: MoodLevel.values.map((mood) {
              final isSelected = _selected == mood;
              return GestureDetector(
                onTap: () {
                  setState(() => _selected = mood);
                  widget.onMoodSelected?.call(mood);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? mood.color.withValues(alpha: 0.25) : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? mood.color : Colors.white.withValues(alpha: 0.2),
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(mood.emoji, style: TextStyle(fontSize: isSelected ? 30 : 24)),
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selected != null) ...[
            const SizedBox(height: 12),
            Text(
              _selected!.label,
              style: TextStyle(color: _selected!.color, fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
}

enum MoodLevel {
  veryGood('Bardzo dobrze 😄', '😄', Color(0xFF4CAF50)),
  good('Dobrze 🙂', '🙂', Color(0xFF8BC34A)),
  neutral('Średnio 😐', '😐', Color(0xFFFFC107)),
  bad('Źle 😔', '😔', Color(0xFFFF9800)),
  veryBad('Bardzo źle 😢', '😢', Color(0xFFF44336));

  final String label;
  final String emoji;
  final Color color;
  const MoodLevel(this.label, this.emoji, this.color);
}
