import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../supabase_service.dart';

/// PDF Export Service for EMIAL (RODO Article 20 — Data Portability)
/// Generates PDF + JSON export packages of senior health and conversation data
class PdfExportService {
  final SupabaseService _supabase;

  PdfExportService(this._supabase);

  /// Export all senior data as a structured JSON package (GDPR-compliant)
  Future<Map<String, dynamic>> exportToJson(String seniorId) async {
    final now = DateTime.now();

    final exportPackage = {
      'metadata': {
        'export_id': 'export-${seniorId}-${now.millisecondsSinceEpoch}',
        'export_date': now.toIso8601String(),
        'senior_id': seniorId,
        'request_type': 'GDPR_DATA_PORTABILITY',
        'legal_basis': 'RODO Art. 20 — Prawo do przenoszenia danych',
        'format_version': '1.0.0',
      },
      'profile': await _getProfileData(seniorId),
      'health_records': await _getHealthRecords(seniorId),
      'medications': await _getMedications(seniorId),
      'conversations': await _getConversationHistory(seniorId),
      'consent_records': await _getConsentRecords(seniorId),
      'appointment_history': await _getAppointmentHistory(seniorId),
    };

    return exportPackage;
  }

  /// Generate a human-readable text summary for PDF generation
  Future<String> generateSummaryReport(String seniorId) async {
    final data = await exportToJson(seniorId);
    final profile = data['profile'] as Map<String, dynamic>? ?? {};
    final health = data['health_records'] as List? ?? [];
    final meds = data['medications'] as List? ?? [];
    final conversations = data['conversations'] as List? ?? [];
    final now = DateTime.now();

    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('  RAPORT DANYCH — AGENT ADAM');
    buffer.writeln('  SilverTech Senior Companion');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('');
    buffer.writeln('Data eksportu: ${_formatDate(now)}');
    buffer.writeln('Senior ID: $seniorId');
    buffer.writeln('Imię: ${profile['first_name'] ?? '—'} ${profile['last_name'] ?? '—'}');
    buffer.writeln('Wiek: ${profile['age'] ?? '—'}');
    buffer.writeln('');
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('  1. PROFIL ZDROWOTNY');
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('Choroby przewlekłe: ${(profile['chronic_conditions'] as List?)?.join(', ') ?? 'brak'}');
    buffer.writeln('Alergie: ${(profile['allergies'] as List?)?.join(', ') ?? 'brak'}');
    buffer.writeln('Grupa krwi: ${profile['blood_type'] ?? 'nieznana'}');
    buffer.writeln('');
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('  2. POMIARY ZDROWOTNE (ostatnie 30 dni)');
    buffer.writeln('───────────────────────────────────────');
    if (health.isEmpty) {
      buffer.writeln('Brak pomiarów w wybranym okresie.');
    } else {
      for (final record in health.take(30)) {
        buffer.writeln(
            '${record['date'] ?? ''}: HR=${record['heart_rate'] ?? '—'} bpm, '
            'BP=${record['systolic'] ?? '—'}/${record['diastolic'] ?? '—'} mmHg, '
            'Steps=${record['steps'] ?? '—'}, '
            'Sleep=${record['sleep_hours'] ?? '—'}h');
      }
    }
    buffer.writeln('');
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('  3. LEKI');
    buffer.writeln('───────────────────────────────────────');
    if (meds.isEmpty) {
      buffer.writeln('Brak leków.');
    } else {
      for (final med in meds) {
        buffer.writeln('- ${med['name']}: ${med['dosage']}, ${med['frequency']}');
      }
    }
    buffer.writeln('');
    buffer.writeln('───────────────────────────────────────');
    buffer.writeln('  4. HISTORIA ROZMÓW (ostatnie 50)');
    buffer.writeln('───────────────────────────────────────');
    if (conversations.isEmpty) {
      buffer.writeln('Brak rozmów.');
    } else {
      for (final conv in conversations.take(50)) {
        buffer.writeln(
            '[${conv['timestamp'] ?? ''}] Senior: "${conv['senior_text'] ?? ''}" → '
            'Adam: "${conv['adam_response'] ?? ''}"');
      }
    }
    buffer.writeln('');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('  Koniec raportu');
    buffer.writeln('  Wygenerowano przez SilverTech Agent Adam');
    buffer.writeln('═══════════════════════════════════════');

    return buffer.toString();
  }

  /// Save export package to local file
  Future<File> saveExportToFile(String seniorId) async {
    final data = await exportToJson(seniorId);
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);

    final exportDir = Directory('/home/user/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final fileName =
        'export-${seniorId}-${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${exportDir.path}/$fileName');
    await file.writeAsString(jsonStr);

    return file;
  }

  // ─── Private data extractors ────────────────────────────────────────

  Future<Map<String, dynamic>> _getProfileData(String seniorId) async {
    try {
      final data = await _supabase.getSeniorProfile(seniorId);
      return data ?? {};
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch profile: $e');
      }
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> _getHealthRecords(String seniorId) async {
    try {
      final data = await _supabase.getHealthRecords(seniorId, limit: 200);
      return data;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch health records: $e');
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getMedications(String seniorId) async {
    try {
      final data = await _supabase.getMedications(seniorId);
      return data.map((m) => {
        'id': m.id, 'name': m.name, 'dosage': m.dosage,
        'frequency': m.frequency, 'isActive': m.isActive,
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch medications: $e');
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getConversationHistory(
      String seniorId) async {
    try {
      final data =
          await _supabase.getConversations(seniorId: seniorId, limit: 50);
      return data.map((c) => c.toJson()).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch conversations: $e');
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getConsentRecords(
      String seniorId) async {
    try {
      final data = await _supabase.getConsentRecords(seniorId);
      return data;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch consent records: $e');
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getAppointmentHistory(
      String seniorId) async {
    try {
      final data =
          await _supabase.getAppointments(seniorId, limit: 100);
      return data;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch appointments: $e');
      }
      return [];
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }
}
