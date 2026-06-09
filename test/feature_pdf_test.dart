import 'package:flutter_test/flutter_test.dart';

import 'package:spendsense/data/models/financial_report_model.dart';
import 'package:spendsense/data/models/transaction_model.dart';
import 'package:spendsense/data/services/export_service.dart';

void main() {
  group('Export PDF - Sunny Day', () {
    late ExportService exportService;

    setUp(() {
      exportService = ExportService.instance;
    });

    test('PDF berhasil dibuat dengan data valid', () async {
      final report = _validReport();

      final pdf = await exportService.generatePDF(
        report,
        'Farrel',
        'farrel@test.com',
      );

      expect(pdf.isNotEmpty, true);
    });

    test('PDF berhasil dibuat dengan banyak transaksi', () async {
      final transactions = List.generate(
        100,
        (index) => Transaction(
          id: index,
          accountId: 1,
          categoryId: 1,
          type: 'expense',
          amount: 10000,
          date: DateTime.now(),
          description: 'Transaksi $index',
          createdAt: DateTime.now(),
          categoryName: 'Makanan',
        ),
      );

      final report = FinancialReportData(
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        transactions: transactions,
        totalIncome: 0,
        totalExpense: 1000000,
        netBalance: -1000000,
        expenseByCategory: {
          'Makanan': 1000000,
        },
        incomeByCategory: {},
        reportType: 'monthly',
        generatedAt: DateTime.now().toIso8601String(),
      );

      final pdf = await exportService.generatePDF(
        report,
        'Farrel',
        'farrel@test.com',
      );

      expect(pdf.isNotEmpty, true);
    });

    test('PDF memiliki ukuran file yang valid', () async {
      final report = _validReport();

      final pdf = await exportService.generatePDF(
        report,
        'Farrel',
        'farrel@test.com',
      );

      expect(pdf.length, greaterThan(1000));
    });
  });

  group('Export PDF - Rainy Day', () {
    late ExportService exportService;

    setUp(() {
      exportService = ExportService.instance;
    });

    test('PDF tetap dibuat ketika transaksi kosong', () async {
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

      final pdf = await exportService.generatePDF(
        report,
        'Tester',
        'tester@test.com',
      );

      expect(pdf.isNotEmpty, true);
    });

    test('PDF tetap dibuat ketika kategori kosong', () async {
      final report = FinancialReportData(
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        transactions: [],
        totalIncome: 100000,
        totalExpense: 50000,
        netBalance: 50000,
        expenseByCategory: {},
        incomeByCategory: {},
        reportType: 'monthly',
        generatedAt: DateTime.now().toIso8601String(),
      );

      final pdf = await exportService.generatePDF(
        report,
        'Farrel',
        'farrel@test.com',
      );

      expect(pdf.isNotEmpty, true);
    });

    test('PDF tetap dibuat ketika username kosong', () async {
      final report = _validReport();

      final pdf = await exportService.generatePDF(
        report,
        '',
        'farrel@test.com',
      );

      expect(pdf.isNotEmpty, true);
    });

    test('PDF tetap dibuat ketika email kosong', () async {
      final report = _validReport();

      final pdf = await exportService.generatePDF(
        report,
        'Farrel',
        '',
      );

      expect(pdf.isNotEmpty, true);
    });
  });
}

FinancialReportData _validReport() {
  return FinancialReportData(
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
}