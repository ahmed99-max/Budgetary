import 'package:flutter/material.dart';
import '../../models/expense.dart';

/// Enum for insights in reports tab
enum InsightType { warning, positive, info }

class Insight {
  final InsightType type;
  final String message;
  Insight({required this.type, required this.message});
}

class CategoryData {
  final String category;
  final double amount;
  final int count;
  CategoryData({
    required this.category,
    required this.amount,
    required this.count,
  });
}

class CategoryAnalysisData extends CategoryData {
  final double average;
  final double percentage;
  CategoryAnalysisData({
    required super.category,
    required super.amount,
    required super.count,
    required this.average,
    required this.percentage,
  });
}

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];
  final List<Expense> _filteredExpenses = [];
  bool _isLoading = false;
  Expense? _lastDeletedExpense;

  bool get isLoading => _isLoading;
  List<Expense> get expenses => _expenses;
  List<Expense> get filteredExpenses =>
      _filteredExpenses.isNotEmpty ? _filteredExpenses : _expenses;

  // === Stats ===
  double get totalExpenses => _expenses.fold(0, (sum, e) => sum + e.amount);

  double get monthlyExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get weeklyExpenses {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _expenses
        .where((e) => e.date.isAfter(weekAgo))
        .fold(0, (sum, e) => sum + e.amount);
  }

  double get dailyAverageExpenses {
    if (_expenses.isEmpty) return 0;
    DateTime first = _expenses.first.date;
    DateTime last = _expenses.last.date;
    int days = last.difference(first).inDays + 1;
    return totalExpenses / days;
  }

  Map<String, List<Expense>> get expensesByCategory {
    final Map<String, List<Expense>> data = {};
    for (var e in _expenses) {
      data.putIfAbsent(e.category, () => []);
      data[e.category]!.add(e);
    }
    return data;
  }

  double get todayExpenses {
    final now = DateTime.now();
    return _expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold(0, (sum, e) => sum + e.amount);
  }

  Map<DateTime, List<Expense>> get monthlyExpensesData {
    final Map<DateTime, List<Expense>> data = {};
    for (var e in _expenses) {
      final key = DateTime(e.date.year, e.date.month);
      data.putIfAbsent(key, () => []);
      data[key]!.add(e);
    }
    return data;
  }

  // === CRUD ===
  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300)); // simulate
    _isLoading = false;
    notifyListeners();
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void updateExpense(Expense expense) {
    final idx = _expenses.indexWhere((e) => e.id == expense.id);
    if (idx != -1) {
      _expenses[idx] = expense;
      notifyListeners();
    }
  }

  void deleteExpense(String id) {
    _lastDeletedExpense = _expenses.firstWhere((e) => e.id == id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void undoDeleteExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  // === Filters ===
  void filterExpensesByDateRange(DateTimeRange range) {
    _filteredExpenses
      ..clear()
      ..addAll(_expenses.where((e) =>
          e.date.isAfter(range.start.subtract(const Duration(days: 1))) &&
          e.date.isBefore(range.end.add(const Duration(days: 1)))));
    notifyListeners();
  }

  void filterExpensesByCategory(String category) {
    if (category == "All") {
      _filteredExpenses.clear();
    } else {
      _filteredExpenses
        ..clear()
        ..addAll(_expenses.where((e) => e.category == category));
    }
    notifyListeners();
  }

  void clearFilters() {
    _filteredExpenses.clear();
    notifyListeners();
  }

  // ========== REPORTS TAB ADDITIONS ==========
  double _totalExpensesForPeriod = 0;
  double _expenseTrend = 0;
  double _averageDailyExpenses = 0;
  int _activeCategoriesCount = 0;
  int _totalTransactionsForPeriod = 0;

  List<double> _dailySpendingData = [];
  List<CategoryData> _topCategories = [];
  Map<String, double> _categoryBreakdownData = {};
  List<CategoryAnalysisData> _categoryAnalysisData = [];
  Map<String, double> _monthlyTrendData = {};
  Map<int, double> _weeklyPatternData = {};
  Map<String, double> _budgetVsActualData = {};

  // ===== Getters =====
  double get totalExpensesForPeriod => _totalExpensesForPeriod;
  double get expenseTrend => _expenseTrend;
  double get averageDailyExpensesReport =>
      _averageDailyExpenses; // renamed to avoid duplicate
  int get activeCategoriesCount => _activeCategoriesCount;
  int get totalTransactionsForPeriod => _totalTransactionsForPeriod;

  List<double> get dailySpendingData => _dailySpendingData;
  List<CategoryData> get topCategories => _topCategories;
  Map<String, double> get categoryBreakdownData => _categoryBreakdownData;
  List<CategoryAnalysisData> get categoryAnalysisData => _categoryAnalysisData;
  Map<String, double> get monthlyTrendData => _monthlyTrendData;
  Map<int, double> get weeklyPatternData => _weeklyPatternData;
  Map<String, double> get budgetVsActualData => _budgetVsActualData;

  void loadExpensesForPeriod(DateTime start, DateTime end) {
    _isLoading = true;
    notifyListeners();

    final filtered = _expenses
        .where((e) =>
            e.date.isAfter(start) &&
            e.date.isBefore(end.add(const Duration(days: 1))))
        .toList();

    _filteredExpenses
      ..clear()
      ..addAll(filtered);

    _totalExpensesForPeriod = filtered.fold(0, (sum, e) => sum + e.amount);
    _totalTransactionsForPeriod = filtered.length;
    _activeCategoriesCount = filtered.map((e) => e.category).toSet().length;
    _averageDailyExpenses =
        filtered.isNotEmpty ? _totalExpensesForPeriod / filtered.length : 0;

    _isLoading = false;
    notifyListeners();
  }

  void generateReportData(DateTime start, DateTime end) {
    final filtered =
        _filteredExpenses.isNotEmpty ? _filteredExpenses : _expenses;

    // Daily spending
    _dailySpendingData = [];
    final days = end.difference(start).inDays + 1;
    for (int i = 0; i < days; i++) {
      final day = start.add(Duration(days: i));
      final totalForDay = filtered
          .where((e) =>
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day)
          .fold<double>(0.0, (sum, e) => sum + e.amount);
      _dailySpendingData.add(totalForDay);
    }

    // Top categories
    final categorySums = <String, double>{};
    final categoryCounts = <String, int>{};
    for (var e in filtered) {
      categorySums[e.category] = (categorySums[e.category] ?? 0) + e.amount;
      categoryCounts[e.category] = (categoryCounts[e.category] ?? 0) + 1;
    }

    _topCategories = categorySums.entries
        .map((entry) => CategoryData(
              category: entry.key,
              amount: entry.value,
              count: categoryCounts[entry.key] ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    // Category breakdown
    _categoryBreakdownData = Map.from(categorySums);

    // Category analysis
    _categoryAnalysisData = _topCategories
        .map((cat) => CategoryAnalysisData(
              category: cat.category,
              amount: cat.amount,
              count: cat.count,
              average: cat.count > 0 ? cat.amount / cat.count : 0,
              percentage: _totalExpensesForPeriod > 0
                  ? (cat.amount / _totalExpensesForPeriod) * 100
                  : 0,
            ))
        .toList();

    // Monthly trend
    _monthlyTrendData = {};
    for (var e in filtered) {
      final key = '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}';
      _monthlyTrendData[key] = (_monthlyTrendData[key] ?? 0) + e.amount;
    }

    // Weekly pattern
    _weeklyPatternData = {};
    for (var e in filtered) {
      final weekday = e.date.weekday - 1;
      _weeklyPatternData[weekday] =
          (_weeklyPatternData[weekday] ?? 0) + e.amount;
    }

    // Budget vs actual
    _budgetVsActualData = Map.from(categorySums);

    notifyListeners();
  }

  List<Insight> generateInsights(
      DateTime start, DateTime end, double monthlyIncome) {
    final insights = <Insight>[];

    if (_totalExpensesForPeriod > monthlyIncome) {
      insights.add(Insight(
          type: InsightType.warning,
          message: 'You have exceeded your monthly income in expenses.'));
    } else if (_totalExpensesForPeriod > monthlyIncome * 0.8) {
      insights.add(Insight(
          type: InsightType.info,
          message:
              'Your spending is approaching your monthly income. Keep monitoring.'));
    } else {
      insights.add(Insight(
          type: InsightType.positive,
          message: 'You are well within your budget.'));
    }

    if (_topCategories.isNotEmpty &&
        _topCategories.first.amount > monthlyIncome * 0.5) {
      insights.add(Insight(
          type: InsightType.warning,
          message:
              'High spending in ${_topCategories.first.category}. Consider reducing it.'));
    }

    return insights;
  }
}
