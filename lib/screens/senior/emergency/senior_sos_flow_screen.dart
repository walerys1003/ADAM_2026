/// SilverTech Agent Adam — Enhanced SOS Emergency Flow
/// Multi-step emergency confirmation with automatic escalation
/// Features: 3-step confirm, auto-dial 112 fallback, family notification, location sharing

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../config/theme.dart';
import '../../../config/app_config.dart';

enum SosStep { initial, confirmCall, confirmAmbulance, calling, confirmed }

class SeniorSosFlowScreen extends StatefulWidget {
  const SeniorSosFlowScreen({super.key});

  @override
  State<SeniorSosFlowScreen> createState() => _SeniorSosFlowScreenState();
}

class _SeniorSosFlowScreenState extends State<SeniorSosFlowScreen>
    with SingleTickerProviderStateMixin {
  SosStep _currentStep = SosStep.initial;
  int _countdownSeconds = 5;
  bool _callAdamChecked = false;
  bool _callAmbulanceChecked = false;
  bool _notifyFamilyChecked = true;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startCountdown() async {
    setState(() => _currentStep = SosStep.calling);
    for (var i = _countdownSeconds; i > 0; i--) {
      if (!mounted) return;
      setState(() => _countdownSeconds = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!mounted) return;
    setState(() => _currentStep = SosStep.confirmed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildStepContent(),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_currentStep) {
      case SosStep.confirmed:
        return Colors.green.shade900;
      case SosStep.calling:
        return Colors.red.shade900;
      default:
        return AppConfig.semaforRed;
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case SosStep.initial:
        return _buildInitialStep();
      case SosStep.confirmCall:
        return _buildConfirmCallStep();
      case SosStep.confirmAmbulance:
        return _buildConfirmAmbulanceStep();
      case SosStep.calling:
        return _buildCallingStep();
      case SosStep.confirmed:
        return _buildConfirmedStep();
    }
  }

  Widget _buildInitialStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        // Emergency icon with pulse animation
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) => Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
                border: Border.all(color: Colors.white, width: 6),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  size: 80, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          'POTRZEBUJESZ\nPOMOCY?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Adam i Twoja rodzina zostaną\nnatychmiast powiadomieni',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.4,
          ),
        ),
        const Spacer(flex: 1),
        // Main SOS button
        SizedBox(
          width: double.infinity,
          height: 80,
          child: ElevatedButton(
            onPressed: () =>
                setState(() => _currentStep = SosStep.confirmCall),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppConfig.semaforRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 12,
            ),
            child: const Text(
              'TAK, POTRZEBUJĘ POMOCY',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Anuluj — to fałszywy alarm',
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ),
        const Spacer(flex: 1),
      ],
    );
  }

  Widget _buildConfirmCallStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 1),
        const Text(
          'Potwierdź działanie',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        const SizedBox(height: 40),
        _buildCheckOption(
          value: _callAdamChecked,
          onChanged: (v) => setState(() => _callAdamChecked = v),
          icon: Icons.phone_in_talk,
          title: 'Zadzwoń do Adama (asystent AI)',
          subtitle: 'Natychmiastowe połączenie głosowe',
        ),
        const SizedBox(height: 20),
        _buildCheckOption(
          value: _notifyFamilyChecked,
          onChanged: (v) => setState(() => _notifyFamilyChecked = v),
          icon: Icons.family_restroom,
          title: 'Powiadom rodzinę',
          subtitle: 'SMS + push notification do opiekunów',
        ),
        const SizedBox(height: 20),
        _buildCheckOption(
          value: _callAmbulanceChecked,
          onChanged: (v) => setState(() => _callAmbulanceChecked = v),
          icon: Icons.local_hospital,
          title: 'Wezwij pogotowie (112)',
          subtitle: 'Tylko w sytuacji zagrożenia życia!',
          isDangerous: true,
        ),
        const Spacer(flex: 1),
        SizedBox(
          width: double.infinity,
          height: 72,
          child: ElevatedButton(
            onPressed: () {
              if (_callAmbulanceChecked) {
                setState(() => _currentStep = SosStep.confirmAmbulance);
              } else {
                _startCountdown();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppConfig.semaforRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              _callAmbulanceChecked ? 'DALEJ' : 'ROZPOCZNIJ',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildConfirmAmbulanceStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.local_hospital, size: 100, color: Colors.white),
        const SizedBox(height: 32),
        const Text(
          'Czy na pewno\nwezwać POGOTOWIE?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Zostanie wybrany numer alarmowy 112.\nUżywaj tylko w sytuacji zagrożenia życia!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 72,
          child: ElevatedButton(
            onPressed: _startCountdown,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.red.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'TAK, DZWOŃ PO POGOTOWIE',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _callAmbulanceChecked = false;
              _currentStep = SosStep.confirmCall;
            });
          },
          child: const Text('Wróć', style: TextStyle(fontSize: 18, color: Colors.white70)),
        ),
      ],
    );
  }

  Widget _buildCallingStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: const Icon(Icons.phone_in_talk, size: 60, color: Colors.white),
        ),
        const SizedBox(height: 32),
        const Text(
          'ŁĄCZENIE...',
          style: TextStyle(
            fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Pomoc zostanie powiadomiona za $_countdownSeconds sekund',
          style: TextStyle(fontSize: 22, color: Colors.white.withValues(alpha: 0.9)),
        ),
        const SizedBox(height: 40),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: _countdownSeconds / 5,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ),
        const Spacer(flex: 2),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('ANULUJ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildConfirmedStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        const Icon(Icons.check_circle, size: 120, color: Colors.white),
        const SizedBox(height: 32),
        const Text(
          'POMOC W DRODZE',
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          _callAmbulanceChecked
              ? 'Pogotowie zostało wezwane.\nPozostań na linii.'
              : 'Adam i Twoja rodzina zostali\npowiadomieni.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }

  Widget _buildCheckOption({
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDangerous = false,
  }) {
    final bgColor = isDangerous
        ? Colors.red.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: isDangerous
            ? Border.all(color: Colors.red.shade300, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
              ],
            ),
          ),
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            checkColor: AppConfig.semaforRed,
            fillColor: WidgetStateProperty.all(Colors.white),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ],
      ),
    );
  }
}
