// lib/shared/providers/expense_provider.dart
// FIXED VERSION

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // FIXED: Added for debugPrint

import '../../core/services/firebase_service.dart';
import '../models/expense_model.dart';
import '../../features/loan/models/loan_model.dart';
import 'loan_provider.dart'; // Imports Loan class

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _expenses = []; // Removed final (needs reassignment)
  bool _isLoading = false;
  String? _errorMessage;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalExpenses => _expenses.fold(
        0,
        (previousValue, expense) => previousValue + expense.amount,
      );

  double get monthlyTotal {
    final now = DateTime.now();
    final monthlyExpenses = _expenses.where((expense) =>
        expense.date.year == now.year && expense.date.month == now.month);
    return monthlyExpenses.fold(
      0.0,
      (previousValue, expense) => previousValue + expense.amount,
    );
  }

  Map<String, double> get categoryTotals {
    final Map<String, double> totals = {};
    for (final expense in _expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  double getTotalExpensesForMonth(DateTime date) {
    return _expenses
        .where((expense) =>
            expense.date.year == date.year && expense.date.month == date.month)
        .fold(
          0.0,
          (previousValue, expense) => previousValue + expense.amount,
        );
  }

  List<MapEntry<String, double>> get sortedCategoryTotals {
    final totals = categoryTotals;
    final sortedList = totals.entries.toList();
    sortedList.sort((a, b) => b.value.compareTo(a.value));
    return sortedList;
  }

  List<ExpenseModel> getExpensesByCategory(String category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }

  Future<void> loadExpenses() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setError('No authenticated user');
      return;
    }

    try {
      _setLoading(true);
      _setError(null);
      final querySnapshot = await FirebaseService.expensesCollection
          .where('userId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .get();
      _expenses = querySnapshot.docs
          .map((doc) => ExpenseModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load expenses: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addExpense({
    required String title,
    required String description,
    required double amount,
    required String category,
    String? subcategory,
    required DateTime date,
    String? receiptUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setError('No authenticated user');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);
      final expense = ExpenseModel(
        id: '',
        userId: uid,
        title: title,
        description: description,
        amount: amount,
        category: category,
        subcategory: subcategory ?? '',
        date: date,
        receiptUrl: receiptUrl,
        metadata: metadata,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final docRef =
          await FirebaseService.expensesCollection.add(expense.toFirestore());
      final newExpense = expense.copyWith(id: docRef.id);
      _expenses.insert(0, newExpense);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateExpense(ExpenseModel updatedExpense) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || updatedExpense.userId != uid) {
      _setError('Unauthorized to update this expense');
      return false;
    }

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
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Failed to update expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setError('No authenticated user');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);
      final expenseToDelete = _expenses.firstWhere((e) => e.id == expenseId);
      if (expenseToDelete.userId != uid) {
        _setError('Unauthorized to delete this expense');
        return false;
      }
      await FirebaseService.expensesCollection.doc(expenseId).delete();
      _expenses.removeWhere((expense) => expense.id == expenseId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete expense: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addLoanPayment({
    required String loanId,
    required double amount,
    required String description,
    required DateTime date,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setError('No authenticated user');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);
      final loanProvider =
          LoanProvider(); // Direct init (assuming it's not widget-dependent)
      final loan = await _getLoanById(
          loanId, loanProvider); // FIXED: Added helper to fetch loan

      if (loan == null) {
        _setError('Loan not found');
        return false;
      }

      final expenseData = {
        'userId': uid,
        'title': 'Loan Payment', // Added title
        'amount': amount,
        'category': 'Loan EMIs',
        'subcategory':
            loan.name, // FIXED: Use 'name' (your class has 'name', not 'title')
        'description': description.isNotEmpty
            ? description
            : 'EMI Payment - ${loan.name}', // FIXED: Use 'name'
        'date': Timestamp.fromDate(date),
        'loanId': loanId,
        'isLoanPayment': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await FirebaseFirestore.instance
          .collection('expenses')
          .add(expenseData);

      await loanProvider.makePayment(loanId, amount);

      final expense = ExpenseModel.fromFirestore(await docRef.get());
      _expenses.insert(0, expense);
      _calculateCategoryTotals(); // Define this method if needed or remove
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add loan payment: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // FIXED: Added helper to fetch loan
  Future<LoanModel?> _getLoanById(String loanId, LoanProvider provider) async {
    await provider.loadLoans();
    try {
      return provider.loans.firstWhere((l) => l.id == loanId);
    } catch (e) {
      return null;
    }
  }

  void _calculateCategoryTotals() {
    // Implement if needed, or remove calls to it if not used
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (!loading) notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearExpenses() {
    _expenses.clear();
    notifyListeners();
  }
}
