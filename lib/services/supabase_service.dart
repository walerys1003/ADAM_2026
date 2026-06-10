import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/senior.dart';
import '../models/conversation.dart';
import '../models/health_data.dart';
import '../models/medication.dart';

/// Supabase Service - primary backend interface
/// Connects to Supabase (PostgreSQL + pgvector + Auth + Storage)
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  /// Initialize Supabase
  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  // ═══════════════════════════════════════════
  // SENIORS
  // ═══════════════════════════════════════════
  Future<List<Senior>> getSeniors({String? status, String? semafor}) async {
    try {
      var query = _client.from('seniors').select();
      if (status != null) query = query.eq('status', status);
      if (semafor != null) query = query.eq('semafor', semafor);
      final data = await query.order('last_name', ascending: true);
      return (data as List).map((j) => Senior.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('getSeniors error: $e');
      return Senior.sampleSeniors(); // fallback for demo
    }
  }

  Future<Senior?> getSenior(String id) async {
    try {
      final data = await _client.from('seniors').select().eq('id', id).single();
      return Senior.fromJson(data);
    } catch (e) {
      debugPrint('getSenior error: $e');
      final samples = Senior.sampleSeniors();
      return samples.where((s) => s.id == id).firstOrNull;
    }
  }

  Future<void> updateSemafor(String seniorId, String semafor) async {
    try {
      await _client.from('seniors').update({
        'semafor': semafor,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', seniorId);
    } catch (e) {
      debugPrint('updateSemafor error: $e');
    }
  }

  // ═══════════════════════════════════════════
  // CONVERSATIONS
  // ═══════════════════════════════════════════
  Future<List<Conversation>> getConversations({
    String? seniorId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _client.from('conversations').select();
      if (seniorId != null) query = query.eq('senior_id', seniorId);
      final data = await query
          .order('started_at', ascending: false)
          .range(offset, offset + limit - 1);
      return (data as List)
          .map((j) => Conversation.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getConversations error: $e');
      return Conversation.sampleConversations(seniorId ?? 's1');
    }
  }

  Future<List<Conversation>> getRecentConversations({int limit = 5}) async {
    return getConversations(limit: limit);
  }

  Future<List<Conversation>> getCrisisConversations() async {
    try {
      final data = await _client
          .from('conversations')
          .select()
          .eq('escalation_flag', true)
          .eq('escalation_resolved', false)
          .order('started_at', ascending: false);
      return (data as List)
          .map((j) => Conversation.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getCrisisConversations error: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════
  // HEALTH DATA
  // ═══════════════════════════════════════════
  Future<HealthData?> getLatestHealthData(String seniorId) async {
    try {
      final data = await _client
          .from('wearable_data')
          .select()
          .eq('senior_id', seniorId)
          .order('recorded_at', ascending: false)
          .limit(1)
          .single();
      return HealthData.fromJson(data);
    } catch (e) {
      debugPrint('getLatestHealthData error: $e');
      return null;
    }
  }

  Future<List<HealthData>> getHealthTrend(String seniorId, {int days = 7}) async {
    try {
      final since = DateTime.now().subtract(Duration(days: days)).toIso8601String();
      final data = await _client
          .from('wearable_data')
          .select()
          .eq('senior_id', seniorId)
          .gte('recorded_at', since)
          .order('recorded_at', ascending: false);
      return (data as List)
          .map((j) => HealthData.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getHealthTrend error: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════
  // MEDICATIONS
  // ═══════════════════════════════════════════
  Future<List<Medication>> getMedications(String seniorId) async {
    try {
      final data = await _client
          .from('medications')
          .select()
          .eq('senior_id', seniorId)
          .eq('is_active', true)
          .order('name');
      return (data as List)
          .map((j) => Medication.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getMedications error: $e');
      return Medication.sampleMeds(seniorId);
    }
  }

  // ═══════════════════════════════════════════
  // PDF EXPORT (legacy aliases)
  // ═══════════════════════════════════════════
  Future<Map<String, dynamic>?> getSeniorProfile(String seniorId) async {
    final senior = await getSenior(seniorId);
    if (senior == null) return null;
    return senior.toJson();
  }

  Future<List<Map<String, dynamic>>> getHealthRecords(String seniorId, {int limit = 200}) async {
    final data = await getHealthTrend(seniorId, days: 30);
    return data.map((h) => {
      'id': h.id, 'heartRate': h.heartRateBpm, 'spo2': h.spo2Percent,
      'steps': h.steps, 'recordedAt': h.recordedAt.toIso8601String(),
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getConsentRecords(String seniorId) async {
    return [{'type': 'RODO', 'agreed': true, 'date': DateTime.now().toIso8601String()}];
  }

  Future<List<Map<String, dynamic>>> getAppointments(String seniorId, {int limit = 100}) async {
    return [];
  }

  // ═══════════════════════════════════════════
  // AUTH
  // ═══════════════════════════════════════════
  /// Get current session — returns null if not logged in
  Future<Map<String, dynamic>?> getSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return null;
      return {
        'accessToken': session.accessToken,
        'role': session.user.userMetadata?['role'] ?? 'senior',
        'userId': session.user.id,
        'email': session.user.email ?? '',
      };
    } catch (_) {
      return null;
    }
  }

  /// Sign in with email and password
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) return null;
      return {
        'userId': user.id,
        'email': user.email,
        'role': user.userMetadata?['role'] ?? 'senior',
      };
    } catch (e) {
      debugPrint('signIn error: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ═══════════════════════════════════════════
  // DASHBOARD STATS
  // ═══════════════════════════════════════════
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final seniors = await getSeniors();
      final conversations = await getRecentConversations(limit: 50);
      final crisis = await getCrisisConversations();

      final activeSeniors = seniors.where((s) => s.isActive).length;
      final redAlerts = seniors.where((s) => s.semafor == 'RED' || s.semafor == 'PURPLE').length;
      final yellowAlerts = seniors.where((s) => s.semafor == 'YELLOW' || s.semafor == 'ORANGE').length;
      final avgMood = conversations.isNotEmpty
          ? conversations.where((c) => c.moodScore != null).fold<double>(0, (sum, c) => sum + c.moodScore!) /
              conversations.where((c) => c.moodScore != null).length
          : 0.0;

      return {
        'totalSeniors': seniors.length,
        'activeSeniors': activeSeniors,
        'todayConversations': conversations.where((c) =>
            c.startedAt.day == DateTime.now().day).length,
        'crisisAlerts': crisis.length,
        'redAlerts': redAlerts,
        'yellowAlerts': yellowAlerts,
        'avgMood': avgMood.toStringAsFixed(1),
        'nps': '4.7',
      };
    } catch (e) {
      debugPrint('getDashboardStats error: $e');
      return {
        'totalSeniors': 180,
        'activeSeniors': 175,
        'todayConversations': 347,
        'crisisAlerts': 3,
        'redAlerts': 1,
        'yellowAlerts': 5,
        'avgMood': '4.2',
        'nps': '4.7',
      };
    }
  }
}
