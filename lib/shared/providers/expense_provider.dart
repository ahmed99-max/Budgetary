import 'package:flutter/material.dart';
import '../../features/expenses/data/expense_repository.dart';
import '../../shared/models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final _repo = ExpenseRepository();

  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Calculated getters
  double get totalExpenses =>
      _expenses.fold(0, (sum, expense) => sum + expense.amount);

  double get monthlyTotal {
    final now = DateTime.now();
    final monthlyExpenses = _expenses.where((expense) =>
        expense.date.year == now.year && expense.date.month == now.month);
    return monthlyExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final expense in _expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  // NEW: Total expenses for a specific month
  double getTotalExpensesForMonth(DateTime month) {
    final monthlyExpenses = _expenses.where((expense) =>
        expense.date.year == month.year && expense.date.month == month.month);
    return monthlyExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  ExpenseProvider() {
    _repo.watchExpenses().listen((list) {
      _expenses = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  // Helpers for internal state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // CRUD operations via repository
  Future<void> addExpense(ExpenseModel e) async {
    try {
      _setLoading(true);
      await _repo.addExpense(e);
    } catch (e) {
      _setError("Failed to add expense: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateExpense(ExpenseModel e) async {
    try {
      _setLoading(true);
      await _repo.updateExpense(e);
    } catch (e) {
      _setError("Failed to update expense: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      _setLoading(true);
      await _repo.deleteExpense(id);
    } catch (e) {
      _setError("Failed to delete expense: $e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadExpenses() async {
    // Optionally add manual load logic here if needed (e.g., force refresh)
    // For now, it triggers UI update from the stream
    notifyListeners();
  }

  // Extra query helpers
  List<ExpenseModel> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  List<ExpenseModel> getExpensesByDateRange(DateTime start, DateTime end) {
    return _expenses
        .where((expense) =>
            expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
