/// Senior Voice Chat — Full-screen calling interface
/// Animated waveforms, large buttons, real-time transcript, mood detection
/// June 2026 — integrated with VoiceCallService

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../services/voice/voice_call_service.dart';

class SeniorVoiceChatScreen extends StatefulWidget {
  const SeniorVoiceChatScreen({super.key});
  @override
  State<SeniorVoiceChatScreen> createState() => _SeniorVoiceChatScreenState();
}

class _SeniorVoiceChatScreenState extends State<SeniorVoiceChatScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  bool _showKeypad = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800));
    _waveController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().startCall('current');
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callService = context.watch<VoiceCallService>();
    final callState = callService.callState;
    final isActive = callState == CallState.connected ||
        callState == CallState.speaking ||
        callState == CallState.listening ||
        callState == CallState.processing;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          children: [
            // ── Status Bar ─────────────────────────
            _buildStatusBar(callService),
            const SizedBox(height: 16),

            // ── Waveform Visualization ─────────────
            _buildWaveform(isActive),
            const SizedBox(height: 16),

            // ── Live Transcript ────────────────────
            Expanded(child: _buildTranscript(callService)),

            // ── Call Controls ──────────────────────
            if (!_showKeypad) _buildCallControls(callService, isActive),

            // ── Keypad ─────────────────────────────
            if (_showKeypad) _buildKeypad(callService),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(VoiceCallService cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(cs.formattedDuration,
              style: const TextStyle(fontSize: 16, color: Colors.white70)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withValues(alpha: 0.5))),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.fiber_manual_record, size: 10, color: Colors.green),
              SizedBox(width: 6),
              Text('ADAM', style: TextStyle(color: Colors.green, fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform(bool isActive) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) => SizedBox(
        height: 80,
        child: CustomPaint(
          painter: _WaveformPainter(
            progress: _waveController.value,
            isActive: isActive,
            color: const Color(0xFF4ECDC4),
          ),
        ),
      ),
    );
  }

  Widget _buildTranscript(VoiceCallService cs) {
    final lines = cs.liveTranscript;
    if (lines.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) => Transform.scale(
              scale: 1.0 + _pulseController.value * 0.1,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.15)),
                child: const Icon(Icons.mic, size: 40, color: Color(0xFF4ECDC4)))),
          ),
          const SizedBox(height: 20),
          const Text('Słucham...',
              style: TextStyle(fontSize: 22, color: Colors.white54)),
        ]),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: lines.length,
      itemBuilder: (_, i) {
        final line = lines[i];
        final isAdam = line.isAdam;
        return Align(
          alignment: isAdam ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280),
            margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isAdam
                  ? const Color(0xFF4ECDC4).withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isAdam ? const Radius.circular(4) : const Radius.circular(18),
                bottomRight: isAdam ? const Radius.circular(18) : const Radius.circular(4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isAdam ? 'Adam' : 'Ty',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: isAdam ? const Color(0xFF4ECDC4) : Colors.white54)),
                const SizedBox(height: 4),
                Text(line.text,
                    style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.4)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCallControls(VoiceCallService cs, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _controlButton(Icons.dialpad, 'Klawiatura', () => setState(() => _showKeypad = true)),
          _controlButton(
            cs.isMuted ? Icons.mic_off : Icons.mic, cs.isMuted ? 'Wycisz.' : 'Mikrofon',
            () => cs.toggleMute(),
            active: !cs.isMuted,
          ),
          _endCallButton(cs),
          _controlButton(
            cs.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            'Głośnik', () => cs.toggleSpeaker(),
            active: cs.isSpeakerOn,
          ),
          _controlButton(Icons.more_horiz, 'Więcej', () {}),
        ],
      ),
    );
  }

  Widget _controlButton(IconData icon, String label, VoidCallback onTap, {bool active = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            color: active ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
            shape: BoxShape.circle),
          child: Icon(icon, color: active ? Colors.white : Colors.white38, size: 26)),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, color: active ? Colors.white60 : Colors.white30)),
      ]),
    );
  }

  Widget _endCallButton(VoiceCallService cs) {
    return GestureDetector(
      onTap: () => cs.endCall(reason: 'senior_hangup').then((_) => Navigator.pop(context)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 68, height: 68,
          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          child: Transform.rotate(
            angle: 2.356, child: const Icon(Icons.call, color: Colors.white, size: 32))),
        const SizedBox(height: 6),
        const Text('Rozłącz', style: TextStyle(fontSize: 11, color: Colors.red)),
      ]),
    );
  }

  Widget _buildKeypad(VoiceCallService cs) {
    final keys = [['1', ''], ['2', 'ABC'], ['3', 'DEF'], ['4', 'GHI'], ['5', 'JKL'],
      ['6', 'MNO'], ['7', 'PQRS'], ['8', 'TUV'], ['9', 'WXYZ'], ['*', ''], ['0', '+'], ['#', '']];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          TextButton(onPressed: () => setState(() => _showKeypad = false),
              child: const Text('Ukryj', style: TextStyle(color: Colors.white54)))]),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 1.3,
                mainAxisSpacing: 8, crossAxisSpacing: 8),
            itemCount: 12,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => cs.sendDTMF(keys[i][0]),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(keys[i][0], style: const TextStyle(fontSize: 28, color: Colors.white)),
                  if (keys[i][1].isNotEmpty)
                    Text(keys[i][1], style: const TextStyle(fontSize: 10, color: Colors.white38)),
                ])),
            ),
          ),
        ),
      ]),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final bool isActive;
  final Color color;
  _WaveformPainter({required this.progress, required this.isActive, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final bars = 40;
    final barWidth = size.width / bars;
    path.moveTo(0, size.height / 2);
    for (var i = 0; i < bars; i++) {
      final x = i * barWidth + barWidth / 2;
      final normalizedProgress = (progress + i * 0.07) % 1.0;
      final amplitude = isActive ? 25.0 + 18.0 * (normalizedProgress > 0.5 ? 1 - normalizedProgress : normalizedProgress) * 2 : 5.0;
      path.lineTo(x, size.height / 2 - amplitude);
      path.lineTo(x, size.height / 2 + amplitude);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) => true;
}
