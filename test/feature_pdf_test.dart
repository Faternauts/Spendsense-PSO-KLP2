import 'package:flutter_test/flutter_test.dart';

import 'package:spendsense/data/models/financial_report_model.dart';
import 'package:spendsense/data/models/transaction_model.dart';
import 'package:spendsense/data/services/export_service.dart';

void main() {
  group('Export PDF Tests', () {
    late ExportService exportService;

    setUp(() {
      exportService = ExportService.instance;
    });

    test('PDF berhasil dibuat', () async {
      final report = FinancialReportData(
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 1, 31),
        transactions: [],
        totalIncome: 1000000,
        totalExpense: 500000,
        netBalance: 500000,
        expenseByCategory: {
          'Makanan': 300000,
          'Transport': 200000,
        },
        incomeByCategory: {
          'Gaji': 1000000,
        },
        reportType: 'monthly',
        generatedAt: DateTime.now().toIso8601String(),
      );

      final pdfBytes = await exportService.generatePDF(
        report,
        'Farrel',
        'farrel@test.com',
      );

      expect(pdfBytes.isNotEmpty, true);
    });

    test('PDF tetap bisa dibuat walaupun tidak ada transaksi', () async {
      final report = FinancialReportData(
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        transactions: [],
        totalIncome: 0,
        totalExpense: 0,
        netBalance: 0,
        expenseByCategory: {},
        incomeByCategory: {},
        reportType: 'all_time',
        generatedAt: DateTime.now().toIso8601String(),
      );

      final pdfBytes = await exportService.generatePDF(
        report,
        'Tester',
        'tester@test.com',
      );

      expect(pdfBytes.length, greaterThan(0));
    });
  });
}