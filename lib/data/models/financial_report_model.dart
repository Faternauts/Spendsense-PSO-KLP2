import 'transaction_model.dart';

class FinancialReportData {
  final DateTime startDate;
  final DateTime endDate;
  final List<Transaction> transactions;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final Map<String, double> expenseByCategory;
  final Map<String, double> incomeByCategory;
  final String reportType; // 'daily', 'weekly', 'monthly', 'yearly', 'custom'
  final String generatedAt;

  FinancialReportData({
    required this.startDate,
    required this.endDate,
    required this.transactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.reportType,
    required this.generatedAt,
  });

  // Calculate summary statistics
  Map<String, dynamic> getSummary() {
    return {
      'periode': _formatDateRange(startDate, endDate),
      'jumlah_transaksi': transactions.length,
      'total_pemasukan': totalIncome,
      'total_pengeluaran': totalExpense,
      'saldo_bersih': netBalance,
      'rata_rata_transaksi': transactions.isEmpty
          ? 0
          : (totalIncome + totalExpense) / transactions.length,
    };
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final formatter = _SimpleDateFormatter();
    if (reportType == 'monthly') {
      return formatter.formatMonthYear(startDate);
    } else if (reportType == 'yearly') {
      return formatter.formatYear(startDate);
    } else {
      return '${formatter.formatDate(start)} - ${formatter.formatDate(end)}';
    }
  }

  // Get transactions grouped by date
  Map<DateTime, List<Transaction>> getTransactionsByDate() {
    final grouped = <DateTime, List<Transaction>>{};
    for (var transaction in transactions) {
      final dateKey = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }
    return grouped;
  }

  // Get transactions grouped by category
  Map<String, List<Transaction>> getTransactionsByCategory() {
    final grouped = <String, List<Transaction>>{};
    for (var transaction in transactions) {
      final categoryName = transaction.categoryName ?? 'Other';
      if (!grouped.containsKey(categoryName)) {
        grouped[categoryName] = [];
      }
      grouped[categoryName]!.add(transaction);
    }
    return grouped;
  }
}

class _SimpleDateFormatter {
  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String formatMonthYear(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String formatYear(DateTime date) {
    return '${date.year}';
  }
}

class ExportOptions {
  final String format; // 'pdf' or 'excel'
  final String exportType; // 'download' or 'email'
  final String? emailRecipient;
  final bool includeCharts;
  final bool includeSummary;
  final bool detailedView; // Include semua transaksi atau hanya summary

  ExportOptions({
    required this.format,
    required this.exportType,
    this.emailRecipient,
    this.includeCharts = true,
    this.includeSummary = true,
    this.detailedView = true,
  });
}
