// lib/shared/providers/budget_provider.dart
// Fully fixed version

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/budget_model.dart';
import '../../core/services/firebase_service.dart';
import '../models/user_model.dart';
import 'expense_provider.dart';
import 'loan_provider.dart';

class ExtraBudget {
  final String id;
  final String category;
  final double amount;

  ExtraBudget({required this.id, required this.category, required this.amount});
}

class BudgetProvider extends ChangeNotifier {
  List<BudgetModel> _budgets = []; // Removed final (needs reassignment)
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, double> _autoBudgets = {}; // Removed final
  List<ExtraBudget> _extras = []; // Removed final
  Set<String> _allCategories = {}; // Removed final

  Map<String, double> get autoBudgets => _autoBudgets;
  List<ExtraBudget> get extraBudgets => _extras;
  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalAllocated => _budgets.fold(
        0,
        (previousValue, budget) => previousValue + budget.allocatedAmount,
      );

  double get totalSpent => _budgets.fold(
        0,
        (previousValue, budget) => previousValue + budget.spentAmount,
      );

  double get totalRemaining => totalAllocated - totalSpent;

  List<BudgetModel> get activeBudgets =>
      _budgets.where((budget) => budget.isActive).toList();

  List<BudgetModel> get overBudgets =>
      _budgets.where((budget) => budget.isOverBudget).toList();

  List<BudgetModel> get nearLimitBudgets => _budgets
      .where((budget) => budget.isNearLimit && !budget.isOverBudget)
      .toList();

  double getAvailableBudgetAmount(double totalIncome,
      [String? excludeCategory]) {
    double totalAllocated = 0;
    for (final budget in _budgets) {
      if (budget.isActive && budget.category != excludeCategory) {
        totalAllocated += budget.allocatedAmount;
      }
    }
    return totalIncome - totalAllocated;
  }

  List<String> getAllBudgetCategories() {
    final categories = _budgets.map((budget) => budget.category).toSet();
    _allCategories.addAll(categories);
    return categories.toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    if (!loading) notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadBudgets(ExpenseProvider expenseProvider) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      _setError('No authenticated user');
      return;
    }

    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await FirebaseService.budgetsCollection
          .where('userId', isEqualTo: uid)
          .where('isActive', isEqualTo: true)
          .orderBy('category')
          .get();

      if (querySnapshot.docs.isEmpty) {
        _budgets = [];
      } else {
        _budgets = querySnapshot.docs
            .map((doc) => BudgetModel.fromFirestore(doc))
            .toList();

        for (int i = 0; i < _budgets.length; i++) {
          final budget = _budgets[i];
          final expenses =
              expenseProvider.getExpensesByCategory(budget.category);
          double spent = expenses.fold(
            0.0,
            (previousValue, expense) => previousValue + expense.amount,
          );
          _budgets[i] = budget.copyWith(spentAmount: spent);
        }
      }

      getAllBudgetCategories();
      await createOrUpdateLoanCategory(expenseProvider);
      notifyListeners();
    } catch (e) {
      _setError('Failed to load budgets: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createOrUpdateLoanCategory(
      ExpenseProvider expenseProvider) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final loanProvider = LoanProvider();
      await loanProvider.loadLoans();
      final totalLoanEMI = loanProvider.totalMonthlyInstallments;

      if (totalLoanEMI > 0) {
        final now = DateTime.now();
        final startDate = DateTime(now.year, now.month, 1);
        final endDate = DateTime(now.year, now.month + 1, 0);

        final existingLoanBudget = _budgets.firstWhere(
          (budget) => budget.category == 'Loan EMIs' && budget.isActive,
          orElse: () => BudgetModel(
            id: '',
            userId: uid,
            category: '',
            allocatedAmount: 0,
            spentAmount: 0,
            period: '',
            startDate: now,
            endDate: now,
            isActive: false,
            createdAt: now,
            updatedAt: now,
            isLoanCategory: false,
          ),
        );

        if (existingLoanBudget.id.isNotEmpty) {
          final updatedBudget = existingLoanBudget.copyWith(
            allocatedAmount: totalLoanEMI,
            updatedAt: DateTime.now(),
          );
          await updateBudget(updatedBudget);
        } else {
          final newLoanBudget = BudgetModel(
            id: '',
            userId: uid,
            category: 'Loan EMIs',
            allocatedAmount: totalLoanEMI,
            spentAmount: 0.0,
            period: 'Monthly',
            startDate: startDate,
            endDate: endDate,
            isActive: true,
            isLoanCategory: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await createBudget(newLoanBudget);
        }
      }
      notifyListeners();
    } catch (e) {
      // Handle error silently or log
    }
  }

  Future<bool> createBudget(BudgetModel budget) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      final docRef =
          await FirebaseService.budgetsCollection.add(budget.toFirestore());
      final newBudget = budget.copyWith(id: docRef.id, userId: uid);
      _budgets.add(newBudget);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBudget(BudgetModel updatedBudget) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || updatedBudget.userId != uid) return false;

    try {
      await FirebaseService.budgetsCollection
          .doc(updatedBudget.id)
          .update(updatedBudget.toFirestore());
      final index = _budgets.indexWhere((b) => b.id == updatedBudget.id);
      if (index != -1) {
        _budgets[index] = updatedBudget;
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBudget(String budgetId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    try {
      await FirebaseService.budgetsCollection.doc(budgetId).delete();
      _budgets.removeWhere((budget) => budget.id == budgetId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  BudgetModel? getBudgetByCategory(String category) {
    try {
      return _budgets.firstWhere(
        (budget) => budget.category == category && budget.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void loadUserBudgets(UserModel user) {
    final income = user.monthlyIncome;
    _autoBudgets = user.budgetCategories
        .map((cat, pct) => MapEntry(cat, pct / 100 * income));
    notifyListeners();
  }

  void addExtraBudget(String category, double amount) {
    final extra =
        ExtraBudget(id: Uuid().v4(), category: category, amount: amount);
    _extras.add(extra);
    notifyListeners();
  }

  void removeExtra(String id) {
    _extras.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void clearBudgets() {
    _budgets.clear();
    _autoBudgets.clear();
    _extras.clear();
    _allCategories.clear();
    notifyListeners();
  }
}
