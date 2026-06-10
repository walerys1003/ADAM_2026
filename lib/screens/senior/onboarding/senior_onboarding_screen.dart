/// SilverTech Agent Adam — Senior Onboarding Flow
/// Step-by-step onboarding: welcome → consent → profile → voice test → wearable → complete
/// June 2026 — GDPR-compliant, accessible, senior-friendly

import 'package:flutter/material.dart';
import '../../../config/app_config.dart';

class SeniorOnboardingScreen extends StatefulWidget {
  const SeniorOnboardingScreen({super.key});

  @override
  State<SeniorOnboardingScreen> createState() => _SeniorOnboardingScreenState();
}

class _SeniorOnboardingScreenState extends State<SeniorOnboardingScreen> {
  int _currentStep = 0;
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _consentVoice = false;
  bool _consentHealth = false;
  bool _consentFamily = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  static const _totalSteps = 6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgress(),
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomeStep(),
                  _buildConsentStep(),
                  _buildProfileStep(),
                  _buildVoiceTestStep(),
                  _buildWearableStep(),
                  _buildCompleteStep(),
                ],
              ),
            ),
            // Navigation buttons
            _buildNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => _previousStep(),
            ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / _totalSteps,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(AppConfig.brandNavy),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text('${_currentStep + 1}/$_totalSteps',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppConfig.brandNavy)),
        ],
      ),
    );
  }

  // Step 1: Welcome
  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.waving_hand, size: 80, color: AppConfig.brandGold),
          const SizedBox(height: 32),
          const Text('Witaj w Agent Adam!',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          const Text(
            'Twój osobisty asystent AI, który pomoże Ci czuć się bezpiecznie i niezależnie.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 48),
          _buildFeatureIntro(Icons.phone_in_talk, 'Rozmawiaj głosowo', 'Po prostu zadzwoń — bez klikania w ekran'),
          const SizedBox(height: 16),
          _buildFeatureIntro(Icons.favorite, 'Monitoruj zdrowie', 'Opaska mierzy tętno, kroki i sen'),
          const SizedBox(height: 16),
          _buildFeatureIntro(Icons.family_restroom, 'Bądź w kontakcie z rodziną', 'Twoi bliscy wiedzą, że jesteś bezpieczny'),
        ],
      ),
    );
  }

  Widget _buildFeatureIntro(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: AppConfig.brandNavy.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppConfig.brandNavy, size: 28),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ]),
      ],
    );
  }

  // Step 2: Consent (RODO/GDPR)
  Widget _buildConsentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Icon(Icons.privacy_tip, size: 60, color: Color(0xFF4ECDC4))),
          const SizedBox(height: 24),
          const Text('Zgody i bezpieczeństwo danych',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Twoje dane są bezpieczne. Zgodnie z RODO, potrzebujemy Twojej zgody.',
              style: TextStyle(fontSize: 15, color: Colors.grey)),
          const SizedBox(height: 32),
          _buildConsentCheckbox(
            value: _consentVoice,
            onChanged: (v) => setState(() => _consentVoice = v),
            title: 'Nagrywanie rozmów',
            subtitle: 'Rozmowy z Adamem są nagrywane w celu poprawy jakości usługi. Przechowujemy je 30 dni.',
            required: true,
          ),
          const SizedBox(height: 16),
          _buildConsentCheckbox(
            value: _consentHealth,
            onChanged: (v) => setState(() => _consentHealth = v),
            title: 'Dane zdrowotne',
            subtitle: 'Twoje tętno, kroki i sen są zbierane z opaski. Dane służą wyłącznie do monitorowania Twojego zdrowia.',
            required: true,
          ),
          const SizedBox(height: 16),
          _buildConsentCheckbox(
            value: _consentFamily,
            onChanged: (v) => setState(() => _consentFamily = v),
            title: 'Udostępnianie rodzinie',
            subtitle: 'Twoi bliscy zobaczą podsumowanie Twojego zdrowia i samopoczucia. Zawsze możesz to zmienić.',
            required: false,
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () {},
            child: Text('Przeczytaj pełną politykę prywatności →',
                style: TextStyle(color: AppConfig.brandNavy, fontWeight: FontWeight.w600, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox({
    required bool value,
    required Function(bool) onChanged,
    required String title,
    required String subtitle,
    required bool required,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            activeColor: AppConfig.brandNavy,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  if (required) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Text('Wymagane', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Step 3: Basic Profile
  Widget _buildProfileStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: Icon(Icons.person, size: 60, color: Color(0xFF4ECDC4))),
          const SizedBox(height: 24),
          const Text('Twój profil', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Adam będzie używał Twojego imienia w rozmowach.',
              style: TextStyle(fontSize: 15, color: Colors.grey)),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Imię (jak ma do Ciebie mówić Adam)',
              hintText: 'Np. Panie Janie, Babciu Zosiu',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true, fillColor: Colors.grey.shade50,
            ),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Numer telefonu',
              hintText: '+48 123 456 789',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              filled: true, fillColor: Colors.grey.shade50,
            ),
            keyboardType: TextInputType.phone,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  // Step 4: Voice Test
  Widget _buildVoiceTestStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mic, size: 80, color: Color(0xFFFF6B6B)),
          const SizedBox(height: 24),
          const Text('Test głosu', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Adam dopasuje szybkość mówienia do Twoich preferencji.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey)),
          const SizedBox(height: 32),
          // Voice speed options
          _buildVoiceOption('Wolniej', '🐢', 0.8),
          const SizedBox(height: 12),
          _buildVoiceOption('Normalnie', '🐇', 1.0),
          const SizedBox(height: 12),
          _buildVoiceOption('Szybciej', '🐎', 1.3),
        ],
      ),
    );
  }

  int _selectedVoiceSpeed = 1; // 0=slow, 1=normal, 2=fast

  Widget _buildVoiceOption(String label, String emoji, double speed) {
    final selected = _selectedVoiceSpeed == (speed == 0.8 ? 0 : speed == 1.0 ? 1 : 2);
    return GestureDetector(
      onTap: () => setState(() => _selectedVoiceSpeed = speed == 0.8 ? 0 : speed == 1.0 ? 1 : 2),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? AppConfig.brandNavy.withValues(alpha: 0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppConfig.brandNavy : Colors.grey.shade200, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: selected ? AppConfig.brandNavy : Colors.grey.shade700)),
            const Spacer(),
            if (selected) Icon(Icons.check_circle, color: AppConfig.brandNavy),
          ],
        ),
      ),
    );
  }

  // Step 5: Wearable Setup
  Widget _buildWearableStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.watch, size: 80, color: Color(0xFF6C5CE7)),
          const SizedBox(height: 24),
          const Text('Opaska Xiaomi Smart Band 9 Pro',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Monitoruje Twoje tętno, kroki, sen i saturację. Synchronizuje się automatycznie.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey)),
          const SizedBox(height: 32),
          Image.asset('assets/images/band.png', height: 120, errorBuilder: (_, __, ___) =>
              Container(width: 120, height: 120, decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ), child: const Icon(Icons.watch, size: 60, color: Color(0xFF6C5CE7)))),
          const SizedBox(height: 32),
          Text('Koszt: 149 zł (jednorazowo)\nW pakiecie ZDROWIE i AKTYWNY — wliczona w cenę!',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  // Step 6: Complete
  Widget _buildCompleteStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 60, color: Colors.green),
          ),
          const SizedBox(height: 32),
          const Text('Wszystko gotowe! 🎉',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          const Text('Adam jest gotowy, by Ci pomagać.\nZadzwoń do niego w dowolnym momencie.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0 && _currentStep < _totalSteps - 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Wstecz', style: TextStyle(fontSize: 18)),
              ),
            ),
          if (_currentStep > 0 && _currentStep < _totalSteps - 1)
            const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep < _totalSteps - 1 ? _nextStep : _finishOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.brandNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                _currentStep < _totalSteps - 1 ? 'Dalej' : 'Zaczynamy!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (!_consentVoice || !_consentHealth) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wymagane zgody muszą być zaznaczone'), backgroundColor: Colors.red),
        );
        return;
      }
    }
    setState(() => _currentStep++);
    _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _previousStep() {
    setState(() => _currentStep--);
    _pageController.animateToPage(_currentStep, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacementNamed('/senior/home');
  }
}
