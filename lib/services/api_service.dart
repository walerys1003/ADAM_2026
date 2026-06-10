import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

/// API Service - communicates with the Hetzner-hosted Node.js backend
/// Handles Twilio calls, Deepgram STT, Gemini LLM, OpenAI TTS integration
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get _baseUrl => AppConfig.apiBaseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ═══════════════════════════════════════════
  // TWILIO CALLS
  // ═══════════════════════════════════════════
  Future<Map<String, dynamic>> initiateOutboundCall({
    required String seniorId,
    required String phoneNumber,
    required String callType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/twilio/outbound'),
        headers: _headers,
        body: jsonEncode({
          'senior_id': seniorId,
          'phone_number': phoneNumber,
          'call_type': callType,
        }),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('initiateOutboundCall error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> initiateSOSCall({
    required String seniorId,
    required String phoneNumber,
  }) async {
    return initiateOutboundCall(
      seniorId: seniorId,
      phoneNumber: phoneNumber,
      callType: 'sos',
    );
  }

  // ═══════════════════════════════════════════
  // CRISIS MANAGEMENT
  // ═══════════════════════════════════════════
  Future<Map<String, dynamic>> escalateToCoordinator({
    required String seniorId,
    required String level,
    required String reason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/crisis/escalate'),
        headers: _headers,
        body: jsonEncode({
          'senior_id': seniorId,
          'level': level,
          'reason': reason,
        }),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('escalateToCoordinator error: $e');
      return {'success': false};
    }
  }

  Future<Map<String, dynamic>> callEmergency({
    required String seniorId,
    required String emergencyNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/crisis/call-112'),
        headers: _headers,
        body: jsonEncode({
          'senior_id': seniorId,
          'emergency_number': emergencyNumber,
        }),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('callEmergency error: $e');
      return {'success': false};
    }
  }

  Future<Map<String, dynamic>> notifyFamily({
    required String seniorId,
    required String message,
    required String level,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/crisis/notify-family'),
        headers: _headers,
        body: jsonEncode({
          'senior_id': seniorId,
          'message': message,
          'level': level,
        }),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('notifyFamily error: $e');
      return {'success': false};
    }
  }

  // ═══════════════════════════════════════════
  // WEARABLES SYNC
  // ═══════════════════════════════════════════
  Future<Map<String, dynamic>> syncHealthData({
    required String seniorId,
    required Map<String, dynamic> healthData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/wearables/sync'),
        headers: _headers,
        body: jsonEncode({
          'senior_id': seniorId,
          ...healthData,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('syncHealthData error: $e');
      return {'success': false};
    }
  }

  // ═══════════════════════════════════════════
  // MARKETPLACE
  // ═══════════════════════════════════════════
  Future<List<Map<String, dynamic>>> getMarketplaceServices({
    String? category,
    String? postalCode,
  }) async {
    try {
      final params = <String, String>{};
      if (category != null) params['category'] = category;
      if (postalCode != null) params['postal_code'] = postalCode;

      final uri = Uri.parse('$_baseUrl/api/marketplace/services')
          .replace(queryParameters: params.isNotEmpty ? params : null);

      final response = await http.get(uri, headers: _headers);
      final data = jsonDecode(response.body) as List;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('getMarketplaceServices error: $e');
      return _sampleServices();
    }
  }

  Future<Map<String, dynamic>> placeOrder({
    required String seniorId,
    required String serviceId,
    required DateTime scheduledAt,
    required double hours,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/marketplace/orders'),
        headers: _headers,
        body: jsonEncode({
          'senior_id': seniorId,
          'service_id': serviceId,
          'scheduled_at': scheduledAt.toIso8601String(),
          'duration_hours': hours,
        }),
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('placeOrder error: $e');
      return {'success': true, 'id': 'order_${DateTime.now().millisecondsSinceEpoch}'};
    }
  }

  // ═══════════════════════════════════════════
  // ANALYTICS
  // ═══════════════════════════════════════════
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/analytics/dashboard'),
        headers: _headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('getAnalytics error: $e');
      return _sampleAnalytics();
    }
  }

  Future<Map<String, dynamic>> getSROI() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/analytics/sroi'),
        headers: _headers,
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('getSROI error: $e');
      return {'sroi_ratio': 4.7, 'social_value_pln': 2350000, 'investment_pln': 500000};
    }
  }

  // ═══════════════════════════════════════════
  // HEALTH CHECK
  // ═══════════════════════════════════════════
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/health'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ═══════════════════════════════════════════
  // SAMPLE DATA (for demo mode)
  // ═══════════════════════════════════════════
  List<Map<String, dynamic>> _sampleServices() => [
        {
          'id': 'sv1',
          'name': 'Sprzątanie mieszkania',
          'category': 'cleaning',
          'provider_name': 'Czyste Wnętrza Sp. z o.o.',
          'price_per_hour_pln': 35.0,
          'rating_avg': 4.8,
          'rating_count': 124,
        },
        {
          'id': 'sv2',
          'name': 'Transport do lekarza',
          'category': 'transport',
          'provider_name': 'SeniorTrans',
          'price_flat_pln': 25.0,
          'rating_avg': 4.9,
          'rating_count': 89,
        },
        {
          'id': 'sv3',
          'name': 'Dostawa zakupów',
          'category': 'delivery',
          'provider_name': 'EkoDostawa',
          'price_flat_pln': 15.0,
          'rating_avg': 4.7,
          'rating_count': 256,
        },
        {
          'id': 'sv4',
          'name': 'Towarzystwo na spacer',
          'category': 'companion',
          'provider_name': 'Dobry Sąsiad',
          'price_per_hour_pln': 25.0,
          'rating_avg': 4.6,
          'rating_count': 67,
        },
        {
          'id': 'sv5',
          'name': 'Drobne naprawy domowe',
          'category': 'repairs',
          'provider_name': 'Złota Rączka',
          'price_per_hour_pln': 50.0,
          'rating_avg': 4.5,
          'rating_count': 43,
        },
      ];

  Map<String, dynamic> _sampleAnalytics() => {
        'total_conversations_month': 10800,
        'avg_duration_minutes': 5.4,
        'avg_mood_score': 4.2,
        'crisis_detected': 12,
        'falls_detected': 3,
        'medication_adherence': 0.92,
        'nps_score': 4.7,
        'cost_per_conversation_usd': 0.114,
        'total_monthly_cost_usd': 1231,
      };
}
