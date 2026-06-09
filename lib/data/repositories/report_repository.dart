import '../models/financial_report_model.dart';
import '../models/transaction_model.dart';
import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';

class ReportRepository {
  final SupabaseService _supabaseService;
  final LocalStorageService _localStorageService;

  ReportRepository({
    required SupabaseService supabaseService,
    required LocalStorageService localStorageService,
  })  : _supabaseService = supabaseService,
        _localStorageService = localStorageService;

  /// Get financial report data based on date range
  Future<FinancialReportData> getFinancialReport({
    required DateTime startDate,
    required DateTime endDate,
    String reportType = 'custom',
  }) async {
    try {
      // Get all transactions from Supabase
      final transactions = await _supabaseService.getTransactions();

      // Filter by date range
      final filteredTransactions = transactions.where((tx) {
        return tx.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            tx.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      // Calculate totals
      double totalIncome = 0;
      double totalExpense = 0;

      for (var tx in filteredTransactions) {
        if (tx.type == 'income') {
          totalIncome += tx.amount;
        } else if (tx.type == 'expense') {
          totalExpense += tx.amount;
        }
      }

      final netBalance = totalIncome - totalExpense;

      // Calculate by category
      final expenseByCategory = _calculateByCategory(
        filteredTransactions,
        'expense',
      );
      final incomeByCategory = _calculateByCategory(
        filteredTransactions,
        'income',
      );

      return FinancialReportData(
        startDate: startDate,
        endDate: endDate,
        transactions: filteredTransactions,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        netBalance: netBalance,
        expenseByCategory: expenseByCategory,
        incomeByCategory: incomeByCategory,
        reportType: reportType,
        generatedAt: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      throw Exception('Gagal mendapatkan laporan: $e');
    }
  }

  /// Get report for current month
  Future<FinancialReportData> getMonthlyReport([DateTime? month]) async {
    final now = month ?? DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0);

    return getFinancialReport(
      startDate: startDate,
      endDate: endDate,
      reportType: 'monthly',
    );
  }

  /// Get report for previous month
  Future<FinancialReportData> getPreviousMonthReport() async {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final startDate = previousMonth;
    final endDate = DateTime(previousMonth.year, previousMonth.month + 1, 0);

    return getFinancialReport(
      startDate: startDate,
      endDate: endDate,
      reportType: 'monthly',
    );
  }

  /// Get report for current year
  Future<FinancialReportData> getYearlyReport([int? year]) async {
    final targetYear = year ?? DateTime.now().year;
    final startDate = DateTime(targetYear, 1, 1);
    final endDate = DateTime(targetYear, 12, 31);

    return getFinancialReport(
      startDate: startDate,
      endDate: endDate,
      reportType: 'yearly',
    );
  }

  /// Get report for previous year
  Future<FinancialReportData> getPreviousYearReport() async {
    final previousYear = DateTime.now().year - 1;
    final startDate = DateTime(previousYear, 1, 1);
    final endDate = DateTime(previousYear, 12, 31);

    return getFinancialReport(
      startDate: startDate,
      endDate: endDate,
      reportType: 'yearly',
    );
  }

  /// Get all time report
  Future<FinancialReportData> getAllTimeReport() async {
    try {
      final transactions = await _supabaseService.getTransactions();

      if (transactions.isEmpty) {
        final now = DateTime.now();
        return FinancialReportData(
          startDate: now,
          endDate: now,
          transactions: [],
          totalIncome: 0,
          totalExpense: 0,
          netBalance: 0,
          expenseByCategory: {},
          incomeByCategory: {},
          reportType: 'all_time',
          generatedAt: DateTime.now().toIso8601String(),
        );
      }

      // Sort transactions
      transactions.sort((a, b) => a.date.compareTo(b.date));
      final startDate = transactions.first.date;
      final endDate = transactions.last.date;

      return getFinancialReport(
        startDate: startDate,
        endDate: endDate,
        reportType: 'all_time',
      );
    } catch (e) {
      throw Exception('Gagal mendapatkan laporan all time: $e');
    }
  }

  /// Helper method to calculate totals by category
  Map<String, double> _calculateByCategory(
    List<Transaction> transactions,
    String type,
  ) {
    final result = <String, double>{};

    for (var tx in transactions) {
      if (tx.type == type) {
        final category = tx.categoryName ?? 'Other';
        result[category] = (result[category] ?? 0) + tx.amount;
      }
    }

    return result;
  }

  /// Get transactions by date for detailed view
  Map<DateTime, List<Transaction>> getTransactionsByDate(
    List<Transaction> transactions,
  ) {
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
}
