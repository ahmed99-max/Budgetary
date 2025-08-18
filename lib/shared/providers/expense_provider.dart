import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/expense_model.dart';
import '../../core/services/firebase_service.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadExpenses(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await FirebaseService.expensesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      _expenses = querySnapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _setError('Failed to load expenses');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addExpense({
    required String userId,
    required String title,
    required String description,
    required double amount,
    required String category,
    String? subcategory,
    required DateTime date,
    String? receiptUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final expense = ExpenseModel(
        id: '', // Will be set by Firestore
        userId: userId,
        title: title,
        description: description,
        amount: amount,
        category: category,
        subcategory: subcategory,
        date: date,
        receiptUrl: receiptUrl,
        metadata: metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef =
          await FirebaseService.expensesCollection.add(expense.toFirestore());

      // Add to local list with the generated ID
      final newExpense = ExpenseModel(
        id: docRef.id,
        userId: userId,
        title: title,
        description: description,
        amount: amount,
        category: category,
        subcategory: subcategory,
        date: date,
        receiptUrl: receiptUrl,
        metadata: metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _expenses.insert(0, newExpense);

      return true;
    } catch (e) {
      _setError('Failed to add expense');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateExpense(ExpenseModel updatedExpense) async {
    try {
      _setLoading(true);
      _setError(null);

      await FirebaseService.expensesCollection
          .doc(updatedExpense.id)
          .update(updatedExpense.toFirestore());

      final index =
          _expenses.indexWhere((expense) => expense.id == updatedExpense.id);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }

      return true;
    } catch (e) {
      _setError('Failed to update expense');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      _setLoading(true);
      _setError(null);

      await FirebaseService.expensesCollection.doc(expenseId).delete();

      _expenses.removeWhere((expense) => expense.id == expenseId);

      return true;
    } catch (e) {
      _setError('Failed to delete expense');
      return false;
    } finally {
      _setLoading(false);
    }
  }

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
