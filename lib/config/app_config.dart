import 'dart:ui';

/// SilverTech Agent Adam - App Configuration
/// Optimized stack for June 2026
class AppConfig {
  AppConfig._();

  // ──────────────────────────────────────────────
  // Brand Identity
  // ──────────────────────────────────────────────
  static const String brandName = 'SilverTech';
  static const String productName = 'Agent Adam';
  static const String tagline = 'Przyjaciel Seniora';
  static const String organization = 'Spółdzielnia Socjalna SilverTech';
  static const String location = 'Poznań, Polska';

  // ──────────────────────────────────────────────
  // Supabase Configuration
  // ──────────────────────────────────────────────
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  // ──────────────────────────────────────────────
  // API Endpoints (Backend on Hetzner VPS)
  // ──────────────────────────────────────────────
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.silvertech.pl',
  );

  // ──────────────────────────────────────────────
  // Packages (PLN/month)
  // ──────────────────────────────────────────────
  static const Map<String, PackageInfo> packages = {
    'KONTAKT': PackageInfo(
      name: 'KONTAKT',
      price: 99,
      description: '2 rozmowy dziennie, przypomnienia o lekach, SMS do rodziny',
      features: [
        '2 rozmowy dziennie (poranna + wieczorna)',
        'Przypomnienia o lekach',
        'SMS do rodziny po każdej rozmowie',
        'Historia rozmów',
        'Check-in poranny',
      ],
    ),
    'ZDROWIE': PackageInfo(
      name: 'ZDROWIE',
      price: 199,
      description: 'Wszystko z KONTAKT + opaska Xiaomi + monitoring zdrowia',
      features: [
        'Wszystko z pakietu KONTAKT',
        'Opaska Xiaomi Smart Band 9 Pro',
        'Monitoring tętna 24/7',
        'Monitoring SpO2 (saturacja)',
        'Monitoring snu',
        'Powiadomienia zdrowotne dla rodziny',
        'Raport zdrowotny tygodniowy',
      ],
    ),
    'AKTYWNY': PackageInfo(
      name: 'AKTYWNY',
      price: 299,
      description: 'Wszystko z ZDROWIE + Apple Watch + wizyty opiekuna + marketplace',
      features: [
        'Wszystko z pakietu ZDROWIE',
        'Apple Watch SE (fall detection)',
        'Wizyty opiekuna (2x/miesiąc)',
        'Marketplace usług (5 usług/miesiąc)',
        'Priorytetowa eskalacja',
        'Dedykowany koordynator',
      ],
    ),
  };

  // ──────────────────────────────────────────────
  // Brand Colors (backward compat aliases → AppTheme)
  // ──────────────────────────────────────────────
  static const Color brandNavy = Color(0xFF1E3A5F);
  static const Color brandGold = Color(0xFFF5A623);
  static const Color seniorBackgroundColor = Color(0xFFFAF8F5);

  // ──────────────────────────────────────────────
  // Semafor Colors (4-level escalation)
  // ──────────────────────────────────────────────
  static const Color semaforGreen = Color(0xFF4CAF50);
  static const Color semaforYellow = Color(0xFFFFC107);
  static const Color semaforOrange = Color(0xFFFF9800);
  static const Color semaforRed = Color(0xFFF44336);
  static const Color semaforPurple = Color(0xFF9C27B0);

  static const Map<String, int> semaforColors = {
    'GREEN': 0xFF4CAF50,
    'YELLOW': 0xFFFFC107,
    'ORANGE': 0xFFFF9800,
    'RED': 0xFFF44336,
    'PURPLE': 0xFF9C27B0,
  };

  // ──────────────────────────────────────────────
  // Conversation Types
  // ──────────────────────────────────────────────
  static const List<String> conversationTypes = [
    'welfare_check_morning',
    'welfare_check_evening',
    'senior_initiated',
    'crisis',
    'emotional_support',
    'marketplace_request',
    'fall_detection_alert',
  ];

  // ──────────────────────────────────────────────
  // Cost per conversation (June 2026 optimized)
  // ──────────────────────────────────────────────
  static const double costTelecomPerMinute = 0.0024; // Twilio PSTN PL
  static const double costSttPerMinute = 0.0048; // Deepgram Nova-3
  static const double costLlmPerConversation = 0.005; // Gemini Flash Live
  static const double costTtsPer1kChars = 0.015; // OpenAI TTS-1
  static const double costInfraPerConversation = 0.003; // Hetzner + Supabase
  static const double avgConversationMinutes = 5.4;
  static const double avgResponseChars = 4320;

  // ──────────────────────────────────────────────
  // Features Flags
  // ──────────────────────────────────────────────
  static const bool enableWearableSync = true;
  static const bool enableMarketplace = true;
  static const bool enableVoiceCloning = false; // Future: ElevenLabs
  static const bool enableFallDetection = true;
}

class PackageInfo {
  final String name;
  final int price;
  final String description;
  final List<String> features;

  const PackageInfo({
    required this.name,
    required this.price,
    required this.description,
    required this.features,
  });
}
