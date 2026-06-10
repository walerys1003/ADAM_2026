import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common/mood_indicator.dart';
import '../../widgets/common/semafor_badge.dart';
import '../../models/conversation.dart';

class AdminConversationsScreen extends StatelessWidget {
  const AdminConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final conversations = provider.recentConversations;

        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              color: Colors.white,
              child: Row(
                children: [
                  const Text('Rozmowy', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  _typeFilter('Wszystkie', true),
                  const SizedBox(width: 8),
                  _typeFilter('Check-in', false),
                  const SizedBox(width: 8),
                  _typeFilter('Kryzysowe', false),
                  const SizedBox(width: 8),
                  _typeFilter('Marketplace', false),
                ],
              ),
            ),

            // Conversations List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: conversations.length,
                itemBuilder: (context, index) => _buildConversationCard(conversations[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _typeFilter(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AppTheme.navy : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : AppTheme.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildConversationCard(Conversation conv) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: conv.escalationFlag
                ? AppTheme.red.withValues(alpha: 0.1)
                : AppTheme.navy.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            conv.escalationFlag ? Icons.warning : Icons.phone,
            color: conv.escalationFlag ? AppTheme.red : AppTheme.navy,
            size: 22,
          ),
        ),
        title: Text(conv.typeLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${conv.startedAt.toString().substring(0, 16)} · ${conv.durationFormatted}',
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MoodIndicator(moodScore: conv.moodScore ?? 3, size: 30),
            const SizedBox(width: 8),
            if (conv.escalationFlag)
              SemaforBadge(semafor: conv.escalationLevel ?? 'YELLOW', size: 12),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transcript preview
                if (conv.transcript != null && conv.transcript!.isNotEmpty) ...[
                  const Text('Transkrypt:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  const SizedBox(height: 8),
                  ...conv.transcript!.take(5).map((msg) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: msg.isAdam ? AppTheme.navy.withValues(alpha: 0.1) : AppTheme.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            msg.isAdam ? 'Adam' : 'Senior',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: msg.isAdam ? AppTheme.navy : AppTheme.gold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(msg.text, style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  )),
                ],

                // Cost breakdown
                const SizedBox(height: 12),
                const Text('Koszt rozmowy:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _costChip('Telekom', conv.costTelecomUsd),
                    _costChip('STT', conv.costSttUsd),
                    _costChip('LLM', conv.costLlmUsd),
                    _costChip('TTS', conv.costTtsUsd),
                    _costChip('Total', conv.costTotalUsd, bold: true),
                  ],
                ),

                // Topics
                if (conv.topics != null && conv.topics!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: conv.topics!.map((t) => Chip(
                      label: Text(t, style: const TextStyle(fontSize: 11)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ],

                // Action buttons
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (conv.audioUrl != null)
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_circle, size: 18),
                        label: const Text('Odsłuchaj'),
                      ),
                    if (conv.escalationFlag && !conv.escalationResolved)
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Rozwiąż'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _costChip(String label, double? value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Text(
        '$label: \$${(value ?? 0).toStringAsFixed(3)}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
