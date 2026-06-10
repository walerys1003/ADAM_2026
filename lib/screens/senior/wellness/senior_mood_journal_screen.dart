import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../widgets/senior/mood_tracker_widget.dart';

/// Mood journal screen for seniors.
/// Allows tracking daily mood with emoji selection,
/// optional notes, and viewing mood history.
class SeniorMoodJournalScreen extends StatefulWidget {
  const SeniorMoodJournalScreen({super.key});

  @override
  State<SeniorMoodJournalScreen> createState() =>
      _SeniorMoodJournalScreenState();
}

/// Internal model for mood journal entries
class _MoodJournalEntry {
  final MoodLevel mood;
  final DateTime date;
  final String? note;

  const _MoodJournalEntry({required this.mood, required this.date, this.note});

  String get moodEmoji => mood.emoji;
  String get moodLabel => mood.label;
  Color get moodColor => mood.color;

  String get formattedDate {
    final months = ['sty', 'lut', 'mar', 'kwi', 'maj', 'cze',
        'lip', 'sie', 'wrz', 'paź', 'lis', 'gru'];
    return '${date.day} ${months[date.month - 1]}';
  }
}

class _SeniorMoodJournalScreenState extends State<SeniorMoodJournalScreen> {
  MoodLevel _selectedMood = MoodLevel.good;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<_MoodJournalEntry> _moodHistory = [
    _MoodJournalEntry(mood: MoodLevel.veryGood, date: DateTime.now().subtract(const Duration(days: 6)), note: 'Wspaniały dzień!'),
    _MoodJournalEntry(mood: MoodLevel.good, date: DateTime.now().subtract(const Duration(days: 5))),
    _MoodJournalEntry(mood: MoodLevel.good, date: DateTime.now().subtract(const Duration(days: 4)), note: 'Spacer w parku'),
    _MoodJournalEntry(mood: MoodLevel.neutral, date: DateTime.now().subtract(const Duration(days: 3))),
    _MoodJournalEntry(mood: MoodLevel.good, date: DateTime.now().subtract(const Duration(days: 2)), note: 'Wizyta wnuków'),
    _MoodJournalEntry(mood: MoodLevel.veryGood, date: DateTime.now().subtract(const Duration(days: 1)), note: 'Imieniny!'),
    _MoodJournalEntry(mood: MoodLevel.good, date: DateTime.now()),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<AppProvider>();
    final senior = provider.selectedSenior;
    final isSenior = provider.isSenior;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dziennik nastroju'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Historia',
            onPressed: () => _showHistoryBottomSheet(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Text(
                senior != null
                    ? 'Jak się dziś czujesz,\n${senior.firstName}?'
                    : 'Jak się dziś czujesz?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isSenior ? 28 : 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _getDateString(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 32),

              // Mood selector
              MoodTrackerWidget(
                initialMood: _selectedMood,
                onMoodSelected: (mood) {
                  setState(() => _selectedMood = mood);
                },
              ),
              const SizedBox(height: 32),

              // Notes field
              TextField(
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(fontSize: isSenior ? 18 : 16),
                decoration: InputDecoration(
                  hintText: 'Dodaj notatkę (opcjonalnie)...',
                  hintStyle: TextStyle(
                    fontSize: isSenior ? 18 : 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: isSenior ? 60 : 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveMood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Zapisz nastrój',
                          style: TextStyle(
                            fontSize: isSenior ? 20 : 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),
              _buildRecentHistory(theme, isSenior),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentHistory(ThemeData theme, bool isSenior) {
    final recentEntries = _moodHistory.reversed.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ostatnie wpisy',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isSenior ? 20 : 16,
              ),
            ),
            TextButton(
              onPressed: () => _showHistoryBottomSheet(context),
              child: Text(
                'Zobacz wszystkie',
                style: TextStyle(fontSize: isSenior ? 16 : 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentEntries.map((entry) => _MoodHistoryTile(
              entry: entry,
              isSenior: isSenior,
            )),
      ],
    );
  }

  void _showHistoryBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isSenior = context.read<AppProvider>().isSenior;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Historia nastroju',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _moodHistory.length,
                    itemBuilder: (context, index) {
                      return _MoodHistoryTile(
                        entry: _moodHistory[_moodHistory.length - 1 - index],
                        isSenior: isSenior,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveMood() async {
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 800));

    final newEntry = _MoodJournalEntry(
      mood: _selectedMood,
      date: DateTime.now(),
      note: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    setState(() {
      _moodHistory.add(newEntry);
      _isSubmitting = false;
      _notesController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nastrój zapisany!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _getDateString() {
    final now = DateTime.now();
    final months = [
      'stycznia', 'lutego', 'marca', 'kwietnia',
      'maja', 'czerwca', 'lipca', 'sierpnia',
      'września', 'października', 'listopada', 'grudnia',
    ];
    final weekdays = [
      'poniedziałek', 'wtorek', 'środa', 'czwartek',
      'piątek', 'sobota', 'niedziela',
    ];
    return '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }
}

class _MoodHistoryTile extends StatelessWidget {
  final _MoodJournalEntry entry;
  final bool isSenior;

  const _MoodHistoryTile({
    required this.entry,
    required this.isSenior,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Text(
                entry.moodEmoji,
                style: TextStyle(fontSize: isSenior ? 32 : 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.moodLabel,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: entry.moodColor,
                        fontSize: isSenior ? 18 : 15,
                      ),
                    ),
                    if (entry.note != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.note!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: isSenior ? 15 : 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                entry.formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: isSenior ? 14 : 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
