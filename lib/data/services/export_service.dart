import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import '../models/financial_report_model.dart';
import '../models/transaction_model.dart';

class ExportService {
  static ExportService? _instance;

  ExportService._();

  static ExportService get instance {
    _instance ??= ExportService._();
    return _instance!;
  }

  // ==================== PDF EXPORT ====================
  Future<Uint8List> generatePDF(
    FinancialReportData reportData,
    String username,
    String userEmail,
  ) async {
    final pdf = pw.Document();

    // Define colors
    final primaryColor = PdfColor.fromInt(0xFF6366F1);
    final accentColor = PdfColor.fromInt(0xFFF97316);
    final textColor = PdfColor.fromInt(0xFF1F2937);
    final lightBg = PdfColor.fromInt(0xFFF3F4F6);

    // Add header page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN KEUANGAN SPENDSENSE',
                      style: pw.TextStyle(
                        font: pw.Font.helveticaBold(),
                        fontSize: 24,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Financial Report Generated',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // User info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Pengguna',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                      pw.Text(
                        username,
                        style: pw.TextStyle(
                          font: pw.Font.helveticaBold(),
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Email',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                      pw.Text(
                        userEmail,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Periode Laporan',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                      pw.Text(
                        _formatDateRange(reportData.startDate, reportData.endDate),
                        style: pw.TextStyle(
                          font: pw.Font.helveticaBold(),
                          fontSize: 12,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 25),

              // Summary boxes
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSummaryBox(
                    'Total Pemasukan',
                    _formatCurrency(reportData.totalIncome),
                    PdfColors.green,
                  ),
                  _buildSummaryBox(
                    'Total Pengeluaran',
                    _formatCurrency(reportData.totalExpense),
                    accentColor,
                  ),
                  _buildSummaryBox(
                    'Saldo Bersih',
                    _formatCurrency(reportData.netBalance),
                    reportData.netBalance >= 0 ? PdfColors.green : PdfColors.red,
                  ),
                ],
              ),
              pw.SizedBox(height: 25),

              // Summary section
              pw.Text(
                'Ringkasan Laporan',
                style: pw.TextStyle(
                  font: pw.Font.helveticaBold(),
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildSummaryTable(reportData),
              pw.SizedBox(height: 25),

              // Expense by category
              pw.Text(
                'Pengeluaran Berdasarkan Kategori',
                style: pw.TextStyle(
                  font: pw.Font.helveticaBold(),
                  fontSize: 14,
                  color: textColor,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildCategoryTable(
                'Pengeluaran',
                reportData.expenseByCategory,
                reportData.totalExpense,
              ),
              pw.SizedBox(height: 20),

              // Income by category
              pw.Text(
                'Pemasukan Berdasarkan Kategori',
                style: pw.TextStyle(
                  font: pw.Font.helveticaBold(),
                  fontSize: 14,
                  color: textColor,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildCategoryTable(
                'Pemasukan',
                reportData.incomeByCategory,
                reportData.totalIncome,
              ),
            ],
          );
        },
      ),
    );

    // Add detailed transactions page
    if (reportData.transactions.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Text(
                  'Daftar Transaksi Detail',
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 16,
                  ),
                ),
                pw.SizedBox(height: 15),
                _buildTransactionsTable(reportData.transactions),
              ],
            );
          },
        ),
      );
    }

    // Return PDF bytes
    return await pdf.save();
  }

  // ==================== EXCEL EXPORT ====================
  Future<Uint8List> generateExcel(
    FinancialReportData reportData,
    String username,
    String userEmail,
  ) async {
    // Excel export is not fully supported on web platform
    if (kIsWeb) {
      throw Exception(
        'Export ke Excel tidak didukung di platform web. Silakan gunakan PDF atau akses dari aplikasi mobile/desktop.',
      );
    }

    try {
      final excel = Excel.createExcel();

      // Remove default sheet
      excel.delete('Sheet1');

      // Sheet 1: Summary
      final summarySheet = excel['Summary'];
      _addExcelSummary(summarySheet, reportData, username, userEmail);

      // Sheet 2: Transactions
      if (reportData.transactions.isNotEmpty) {
        final transSheet = excel['Transaksi'];
        _addExcelTransactions(transSheet, reportData.transactions);
      }

      // Sheet 3: Category Summary
      final categorySheet = excel['Kategori'];
      _addExcelCategorySummary(categorySheet, reportData);

      // Return Excel bytes
      final encoded = excel.encode();
      if (encoded == null) {
        throw Exception('Gagal membuat file Excel');
      }
      return Uint8List.fromList(encoded);
    } catch (e) {
      if (e.toString().contains('Unsupported operation')) {
        throw Exception(
          'Gagal export Excel. Excel tidak sepenuhnya didukung di platform ini. Coba gunakan PDF atau akses dari aplikasi mobile.',
        );
      }
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  pw.Widget _buildSummaryBox(String title, String value, PdfColor bgColor) {
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: bgColor,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: pw.Font.helveticaBold(),
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryTable(FinancialReportData data) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 0.5,
      ),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF3F4F6),
          ),
          children: [
            _buildTableCell('Metrik', isBold: true),
            _buildTableCell('Nilai', isBold: true),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell('Jumlah Transaksi'),
            _buildTableCell('${data.transactions.length}'),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell('Total Pemasukan'),
            _buildTableCell(_formatCurrency(data.totalIncome)),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell('Total Pengeluaran'),
            _buildTableCell(_formatCurrency(data.totalExpense)),
          ],
        ),
        pw.TableRow(
          children: [
            _buildTableCell('Saldo Bersih', isBold: true),
            _buildTableCell(_formatCurrency(data.netBalance), isBold: true),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCategoryTable(
    String title,
    Map<String, double> categoryData,
    double total,
  ) {
    if (categoryData.isEmpty) {
      return pw.Text('Tidak ada data');
    }

    final rows = <pw.TableRow>[];

    // Header
    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFF3F4F6),
        ),
        children: [
          _buildTableCell('Kategori', isBold: true),
          _buildTableCell('Jumlah', isBold: true),
          _buildTableCell('Persentase', isBold: true),
        ],
      ),
    );

    // Data
    categoryData.forEach((category, amount) {
      final percentage = total > 0 ? ((amount / total) * 100).toStringAsFixed(1) : '0';
      rows.add(
        pw.TableRow(
          children: [
            _buildTableCell(category),
            _buildTableCell(_formatCurrency(amount)),
            _buildTableCell('$percentage%'),
          ],
        ),
      );
    });

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 0.5,
      ),
      children: rows,
    );
  }

  pw.Widget _buildTransactionsTable(List<Transaction> transactions) {
    final rows = <pw.TableRow>[];

    // Header
    rows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(
          color: PdfColor.fromInt(0xFFF3F4F6),
        ),
        children: [
          _buildTableCell('Tanggal', isBold: true),
          _buildTableCell('Deskripsi', isBold: true),
          _buildTableCell('Kategori', isBold: true),
          _buildTableCell('Tipe', isBold: true),
          _buildTableCell('Jumlah', isBold: true),
        ],
      ),
    );

    // Data (limit to 50 rows per page)
    for (var i = 0; i < transactions.take(50).length; i++) {
      final tx = transactions[i];
      rows.add(
        pw.TableRow(
          children: [
            _buildTableCell(_formatDate(tx.date)),
            _buildTableCell(tx.description, maxLength: 20),
            _buildTableCell(tx.categoryName ?? '-'),
            _buildTableCell(tx.type),
            _buildTableCell(_formatCurrency(tx.amount)),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 0.5,
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.5),
      },
      children: rows,
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isBold = false,
    int maxLength = 30,
  }) {
    final displayText = text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;

    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        displayText,
        style: pw.TextStyle(
          font: isBold ? pw.Font.helveticaBold() : null,
          fontSize: isBold ? 11 : 10,
        ),
      ),
    );
  }

  void _addExcelSummary(
    Sheet sheet,
    FinancialReportData data,
    String username,
    String userEmail,
  ) {
    int row = 0;

    // Header
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row),
    );
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = 'LAPORAN KEUANGAN SPENDSENSE';
    row += 2;

    // User info
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        'Pengguna:';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
        username;
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        'Email:';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
        userEmail;
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        'Periode:';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
        _formatDateRange(data.startDate, data.endDate);
    row += 2;

    // Summary data
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        'RINGKASAN';
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        'Total Pemasukan';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
        data.totalIncome;
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        'Total Pengeluaran';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
        data.totalExpense;
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        'Saldo Bersih';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
        data.netBalance;
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        'Jumlah Transaksi';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
        data.transactions.length;
  }

  void _addExcelTransactions(Sheet sheet, List<Transaction> transactions) {
    int row = 0;

    // Header
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        'Tanggal';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
        'Deskripsi';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
        'Kategori';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value =
        'Tipe';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value =
        'Jumlah';
    row++;

    // Data
    for (var tx in transactions) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          _formatDate(tx.date);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          tx.description;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
          tx.categoryName ?? '-';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value =
          tx.type;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row)).value =
          tx.amount;
      row++;
    }
  }

  void _addExcelCategorySummary(Sheet sheet, FinancialReportData data) {
    int row = 0;

    // Pengeluaran by category
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        'PENGELUARAN KATEGORI';
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        'Kategori';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
        'Jumlah';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
        'Persentase';
    row++;

    data.expenseByCategory.forEach((category, amount) {
      final percentage = data.totalExpense > 0
          ? ((amount / data.totalExpense) * 100).toStringAsFixed(1)
          : '0';

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          category;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          amount;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
          '$percentage%';
      row++;
    });

    row += 2;

    // Pemasukan by category
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        'PEMASUKAN KATEGORI';
    row++;

    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
        'Kategori';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
        'Jumlah';
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
        'Persentase';
    row++;

    data.incomeByCategory.forEach((category, amount) {
      final percentage = data.totalIncome > 0
          ? ((amount / data.totalIncome) * 100).toStringAsFixed(1)
          : '0';

      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value =
          category;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value =
          amount;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value =
          '$percentage%';
      row++;
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final startStr = DateFormat('dd-MM-yyyy').format(start);
    final endStr = DateFormat('dd-MM-yyyy').format(end);
    return '$startStr s/d $endStr';
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }
}
