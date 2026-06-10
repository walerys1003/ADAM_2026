import 'package:flutter/foundation.dart';
import '../models/senior.dart';
import '../models/conversation.dart';
import '../models/health_data.dart';
import '../models/medication.dart';
import '../services/supabase_service.dart';
import '../services/api_service.dart';

/// Main application state provider
/// Manages: user role, seniors list, conversations, health data, navigation
class AppProvider extends ChangeNotifier {
  final SupabaseService _supabase = SupabaseService();
  final ApiService _api = ApiService();

  // ── User & Auth ──
  String _userRole = 'family'; // 'senior', 'family', 'coordinator', 'admin'
  String get userRole => _userRole;
  bool get isSenior => _userRole == 'senior';
  bool get isFamily => _userRole == 'family';
  bool get isAdmin => _userRole == 'coordinator' || _userRole == 'admin';

  // ── Seniors ──
  List<Senior> _seniors = [];
  List<Senior> get seniors => _seniors;
  Senior? _selectedSenior;
  Senior? get selectedSenior => _selectedSenior;

  // ── Conversations ──
  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;
  List<Conversation> _recentConversations = [];
  List<Conversation> get recentConversations => _recentConversations;
  List<Conversation> _crisisConversations = [];
  List<Conversation> get crisisConversations => _crisisConversations;

  // ── Health ──
  HealthData? _latestHealth;
  HealthData? get latestHealth => _latestHealth;
  List<HealthData> _healthTrend = [];
  List<HealthData> get healthTrend => _healthTrend;

  // ── Medications ──
  List<Medication> _medications = [];
  List<Medication> get medications => _medications;

  // ── Dashboard ──
  Map<String, dynamic> _dashboardStats = {};
  Map<String, dynamic> get dashboardStats => _dashboardStats;

  // ── Loading ──
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ── Connectivity ──
  bool _isBackendAvailable = true;
  bool get isBackendAvailable => _isBackendAvailable;

  // ═══════════════════════════════════════════
  // INITIALIZATION
  // ═══════════════════════════════════════════
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _supabase.initialize();
      await loadDashboard();
    } catch (e) {
      debugPrint('AppProvider init: $e');
    }
    _setLoading(false);
  }

  /// Switch between viewing modes (senior / family / admin)
  void switchRole(String role) {
    _userRole = role;
    notifyListeners();
    loadDashboard();
  }

  // ═══════════════════════════════════════════
  // DASHBOARD
  // ═══════════════════════════════════════════
  Future<void> loadDashboard() async {
    _setLoading(true);
    try {
      _seniors = await _supabase.getSeniors();
      _recentConversations = await _supabase.getRecentConversations();
      _crisisConversations = await _supabase.getCrisisConversations();
      _dashboardStats = await _supabase.getDashboardStats();
    } catch (e) {
      debugPrint('loadDashboard error: $e');
      _seniors = Senior.sampleSeniors();
      _recentConversations = Conversation.sampleConversations('s1');
      _dashboardStats = {
        'totalSeniors': 180, 'activeSeniors': 175,
        'todayConversations': 347, 'crisisAlerts': 3,
        'redAlerts': 1, 'yellowAlerts': 5,
        'avgMood': '4.2', 'nps': '4.7',
      };
    }
    _setLoading(false);
  }

  // ═══════════════════════════════════════════
  // SENIOR DETAIL
  // ═══════════════════════════════════════════
  Future<void> selectSenior(String id) async {
    _setLoading(true);
    try {
      _selectedSenior = await _supabase.getSenior(id);
      _conversations = await _supabase.getConversations(seniorId: id);
      _medications = await _supabase.getMedications(id);
      _latestHealth = await _supabase.getLatestHealthData(id);
      _healthTrend = await _supabase.getHealthTrend(id, days: 7);
    } catch (e) {
      debugPrint('selectSenior error: $e');
      final samples = Senior.sampleSeniors();
      _selectedSenior = samples.where((s) => s.id == id).firstOrNull ?? samples.first;
      _conversations = Conversation.sampleConversations(id);
      _medications = Medication.sampleMeds(id);
    }
    _setLoading(false);
  }

  // ═══════════════════════════════════════════
  // CALL ACTIONS
  // ═══════════════════════════════════════════
  Future<void> callSenior(String seniorId, String phoneNumber) async {
    await _api.initiateOutboundCall(
      seniorId: seniorId,
      phoneNumber: phoneNumber,
      callType: 'welfare_check_morning',
    );
  }

  Future<void> triggerSOS(String seniorId, String phoneNumber) async {
    await _api.initiateSOSCall(
      seniorId: seniorId,
      phoneNumber: phoneNumber,
    );
    await _api.notifyFamily(
      seniorId: seniorId,
      message: 'SOS - Senior aktywował przycisk awaryjny!',
      level: 'RED',
    );
    await _supabase.updateSemafor(seniorId, 'RED');
    await loadDashboard();
  }

  // ═══════════════════════════════════════════
  // CRISIS
  // ═══════════════════════════════════════════
  Future<void> escalateAlert(String seniorId, String level, String reason) async {
    await _api.escalateToCoordinator(
      seniorId: seniorId,
      level: level,
      reason: reason,
    );
    await _supabase.updateSemafor(seniorId, level);
    await loadDashboard();
  }

  // ═══════════════════════════════════════════
  // HEALTH CHECK
  // ═══════════════════════════════════════════
  Future<void> checkBackendHealth() async {
    _isBackendAvailable = await _api.healthCheck();
    notifyListeners();
  }

  // ═══════════════════════════════════════════
  // UTILITY
  // ═══════════════════════════════════════════
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
