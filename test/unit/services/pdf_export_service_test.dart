import 'package:flutter_test/flutter_test.dart';
import 'package:senior_companion/services/pdf/pdf_export_service.dart';
import 'package:senior_companion/services/supabase_service.dart';

void main() {
  group('PdfExportService', () {
    late PdfExportService service;

    setUp(() {
      service = PdfExportService(SupabaseService());
    });

    test('exportToJson returns valid JSON structure', () async {
      final result = await service.exportToJson('senior-test-001');

      // Metadata
      expect(result.containsKey('metadata'), true);
      expect(result['metadata']['senior_id'], 'senior-test-001');
      expect(result['metadata']['request_type'], 'GDPR_DATA_PORTABILITY');
      expect(result['metadata']['legal_basis'], 'RODO Art. 20 — Prawo do przenoszenia danych');

      // Required sections
      expect(result.containsKey('profile'), true);
      expect(result.containsKey('health_records'), true);
      expect(result.containsKey('medications'), true);
      expect(result.containsKey('conversations'), true);
      expect(result.containsKey('consent_records'), true);
      expect(result.containsKey('appointment_history'), true);
    });

    test('exportToJson generates unique export_id', () async {
      final result1 = await service.exportToJson('senior-test-001');
      final result2 = await service.exportToJson('senior-test-001');

      expect(
        result1['metadata']['export_id'],
        isNot(equals(result2['metadata']['export_id'])),
      );
    });

    test('exportToJson handles empty data gracefully', () async {
      final result = await service.exportToJson('non-existent-senior');

      expect(result['metadata']['senior_id'], 'non-existent-senior');
      expect(result['health_records'], isEmpty);
      expect(result['medications'], isEmpty);
    });

    test('generateSummaryReport produces text report', () async {
      final report = await service.generateSummaryReport('senior-test-001');

      expect(report, contains('RAPORT DANYCH — AGENT ADAM'));
      expect(report, contains('SilverTech Senior Companion'));
      expect(report, contains('PROFIL ZDROWOTNY'));
      expect(report, contains('POMIARY ZDROWOTNE'));
      expect(report, contains('LEKI'));
      expect(report, contains('HISTORIA ROZMÓW'));
      expect(report, contains('Koniec raportu'));
    });

    test('generateSummaryReport includes senior info', () async {
      final report = await service.generateSummaryReport('senior-test-001');

      expect(report, contains('Senior ID: senior-test-001'));
    });

    test('saveExportToFile creates valid JSON file', () async {
      final file = await service.saveExportToFile('senior-test-001');

      expect(file, isNotNull);
      expect(await file.exists(), true);
      expect(file.path.endsWith('.json'), true);
    });
  });
}
