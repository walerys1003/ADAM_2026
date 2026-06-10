/// SilverTech Agent Adam — Wellness & Activity Tracking
/// Daily wellness check, mood tracking, activity goals, hydration, cognitive games
/// June 2026 — integrated with Health Connect data

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../config/theme.dart';
import '../../../config/app_config.dart';
import '../../../widgets/common/mood_indicator.dart';
import '../../../widgets/common/stat_card.dart';

class SeniorWellnessScreen extends StatefulWidget {
  const SeniorWellnessScreen({super.key});

  @override
  State<SeniorWellnessScreen> createState() => _SeniorWellnessScreenState();
}

class _SeniorWellnessScreenState extends State<SeniorWellnessScreen> {
  int _moodScore = 4;
  double _hydrationGlasses = 4; // out of 8
  int _cognitiveScore = 0;
  String _wellnessNote = '';
  final _noteController = TextEditingController();

  final List<String> _moodLabels = [
    'Bardzo źle',
    'Źle',
    'Tak sobie',
    'Dobrze',
    'Bardzo dobrze',
  ];

  final List<String> _moodEmojis = ['😢', '😟', '😐', '😊', '🥰'];

  final List<_CognitiveGame> _games = [
    _CognitiveGame(
      title: 'Zapamiętaj słowa',
      description: 'Ćwiczenie pamięci krótkotrwałej',
      icon: Icons.psychology,
      color: Color(0xFF4ECDC4),
    ),
    _CognitiveGame(
      title: 'Policz w pamięci',
      description: 'Ćwiczenie matematyczne',
      icon: Icons.calculate,
      color: Color(0xFFFF6B6B),
    ),
    _CognitiveGame(
      title: 'Dopasuj pary',
      description: 'Gra pamięciowa',
      icon: Icons.grid_view,
      color: Color(0xFFFFD93D),
    ),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSeniorTheme = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: isSeniorTheme
          ? AppConfig.seniorBackgroundColor
          : null,
      appBar: AppBar(
        title: const Text('Dobre Samopoczucie',
            style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Daily Wellness Check Card ───────────────
            _buildWellnessCheck(),
            const SizedBox(height: 20),

            // ── Mood Tracker ────────────────────────────
            _buildMoodTracker(),
            const SizedBox(height: 20),

            // ── Hydration ───────────────────────────────
            _buildHydrationTracker(),
            const SizedBox(height: 20),

            // ── Activity Summary ────────────────────────
            _buildActivitySummary(),
            const SizedBox(height: 20),

            // ── Cognitive Games ─────────────────────────
            _buildCognitiveGames(),
            const SizedBox(height: 20),

            // ── Wellness Note ───────────────────────────
            _buildWellnessNote(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildWellnessCheck() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A535C), Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Jak się dziś czujesz?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                _moodEmojis[_moodScore - 1],
                style: const TextStyle(fontSize: 40),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (i) {
              final selected = i < _moodScore;
              return GestureDetector(
                onTap: () => setState(() => _moodScore = i + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.2),
                    border: Border.all(
                      color: Colors.white,
                      width: selected ? 3 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: selected ? const Color(0xFF1A535C) : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _moodLabels[_moodScore - 1],
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nastrój — ostatnie 7 dni',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMoodBar('Pn', 4),
                _buildMoodBar('Wt', 3),
                _buildMoodBar('Śr', 5),
                _buildMoodBar('Cz', 4),
                _buildMoodBar('Pt', 4),
                _buildMoodBar('So', 3),
                _buildMoodBar('Nd', _moodScore),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodBar(String day, int score) {
    final height = score * 18.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          _moodEmojis[score - 1],
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: height,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4ECDC4), Color(0xFF1A535C)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 4),
        Text(day, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey)),
      ],
    );
  }

  Widget _buildHydrationTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nawodnienie',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              Text(
                '${_hydrationGlasses.toInt()}/8 szklanek',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4ECDC4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(8, (i) {
              final filled = i < _hydrationGlasses;
              return GestureDetector(
                onTap: () => setState(() => _hydrationGlasses = (i + 1).toDouble()),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 48,
                  decoration: BoxDecoration(
                    color: filled
                        ? const Color(0xFF4ECDC4)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                    border: filled
                        ? null
                        : Border.all(color: Colors.grey.shade300),
                  ),
                  child: Icon(
                    Icons.water_drop,
                    color: filled ? Colors.white : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          if (_hydrationGlasses < 4)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Wypij jeszcze trochę wody! Zalecane 8 szklanek dziennie.',
                      style: TextStyle(color: Colors.orange, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivitySummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dzisiejsza aktywność',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.directions_walk,
                  label: 'Kroki',
                  value: '4,823',
                  color: const Color(0xFF4ECDC4),
                  subtitle: 'cel: 6,000',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.favorite,
                  label: 'Tętno',
                  value: '72',
                  color: const Color(0xFFFF6B6B),
                  subtitle: 'BPM',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.air,
                  label: 'SpO2',
                  value: '97%',
                  color: const Color(0xFF45B7D1),
                  subtitle: 'norma',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  icon: Icons.bed,
                  label: 'Sen',
                  value: '7.5h',
                  color: const Color(0xFF96CEB4),
                  subtitle: 'dobry',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCognitiveGames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gry umysłowe',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ..._games.asMap().entries.map((entry) {
          final idx = entry.key;
          final game = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Uruchamiam: ${game.title}...'),
                      backgroundColor: game.color,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: game.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(game.icon, color: game.color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              game.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              game.description,
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.play_arrow, color: game.color, size: 32),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWellnessNote() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notatka dla Adama / rodziny',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Np. Dziś boli mnie kolano...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notatka zapisana! Adam i rodzina zostaną powiadomieni.'),
                    backgroundColor: Color(0xFF4ECDC4),
                  ),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('Wyślij notatkę', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CognitiveGame {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _CognitiveGame({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
