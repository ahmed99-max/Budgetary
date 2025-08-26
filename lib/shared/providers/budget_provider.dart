// lib/shared/providers/budget_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/budget_model.dart';
import '../../core/services/firebase_service.dart';
import '../models/user_model.dart';
import 'expense_provider.dart';

class ExtraBudget {
  final String id;
  final String category;
  final double amount;

  ExtraBudget({required this.id, required this.category, required this.amount});
}

class BudgetProvider extends ChangeNotifier {
  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, double> _autoBudgets = {};
  List<ExtraBudget> _extras = [];
  Set<String> _allCategories = {};

  Map<String, double> get autoBudgets => _autoBudgets;
  List<ExtraBudget> get extraBudgets => _extras;
  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalAllocated =>
      _budgets.fold(0, (sum, budget) => sum + budget.allocatedAmount);

  double get totalSpent =>
      _budgets.fold(0, (sum, budget) => sum + budget.spentAmount);

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
    _allCategories = categories;
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
    print("🔍 LOADING BUDGETS FOR USER: $uid");

    if (uid == null || uid.isEmpty) {
      print("❌ NO USER ID - Cannot load budgets");
      _setError('No authenticated user');
      return;
    }

    try {
      _setLoading(true);
      _setError(null);

      print("🚀 Starting Firestore query...");
      final querySnapshot = await FirebaseService.budgetsCollection
          .where('userId', isEqualTo: uid) // 👈 USER-SPECIFIC FILTERING
          .where('isActive', isEqualTo: true)
          .orderBy('category')
          .get();

      print(
          "📋 FIRESTORE QUERY RESULT: ${querySnapshot.docs.length} documents found");

      if (querySnapshot.docs.isEmpty) {
        print("❌ NO BUDGETS FOUND IN FIRESTORE FOR USER: $uid");
        _budgets = [];
      } else {
        for (var doc in querySnapshot.docs) {
          print("📄 Budget doc: ${doc.id} - ${doc.data()}");
        }

        _budgets = querySnapshot.docs
            .map((doc) => BudgetModel.fromFirestore(doc))
            .toList();

        print("✅ LOADED ${_budgets.length} BUDGETS TO PROVIDER");
        print(
            "📊 Budget categories: ${_budgets.map((b) => b.category).toList()}");

        // Update spentAmount for each budget from expenses
        for (int i = 0; i < _budgets.length; i++) {
          final budget = _budgets[i];
          final expenses =
              expenseProvider.getExpensesByCategory(budget.category);
          double spent =
              expenses.fold(0.0, (sum, expense) => sum + expense.amount);
          _budgets[i] = budget.copyWith(spentAmount: spent);
          print(
              "💰 Updated ${budget.category}: spent $spent of ${budget.allocatedAmount}");
        }
      }

      getAllBudgetCategories();
      notifyListeners();
      print("🔄 NOTIFIED LISTENERS - UI SHOULD UPDATE NOW");
    } catch (e) {
      print("💥 ERROR LOADING BUDGETS: $e");
      _setError('Failed to load budgets: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createBudget({
    required String category,
    required double allocatedAmount,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      _setError('No authenticated user');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      final budget = BudgetModel(
        id: '', // Will be set by Firestore
        userId: uid, // 👈 ENSURE USER-SPECIFIC
        category: category,
        allocatedAmount: allocatedAmount,
        spentAmount: 0,
        period: period,
        startDate: startDate,
        endDate: endDate,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final docRef =
          await FirebaseService.budgetsCollection.add(budget.toFirestore());

      final newBudget = budget.copyWith(id: docRef.id);
      _budgets.add(newBudget);

      if (!_allCategories.contains(category)) {
        _allCategories.add(category);
      }

      print('✅ CREATED BUDGET FOR USER: $uid - $category');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ ERROR CREATING BUDGET: $e');
      _setError('Failed to create budget: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateBudget(BudgetModel updatedBudget) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || updatedBudget.userId != uid) {
      _setError('Unauthorized to update this budget');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      await FirebaseService.budgetsCollection
          .doc(updatedBudget.id)
          .update(updatedBudget.toFirestore());

      final index =
          _budgets.indexWhere((budget) => budget.id == updatedBudget.id);
      if (index != -1) {
        _budgets[index] = updatedBudget;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Failed to update budget: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteBudget(String budgetId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _setError('No authenticated user');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);

      // Check if budget belongs to current user before deleting
      final budgetToDelete = _budgets.firstWhere((b) => b.id == budgetId);
      if (budgetToDelete.userId != uid) {
        _setError('Unauthorized to delete this budget');
        return false;
      }

      await FirebaseService.budgetsCollection.doc(budgetId).delete();
      _budgets.removeWhere((budget) => budget.id == budgetId);

      getAllBudgetCategories();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete budget: $e');
      return false;
    } finally {
      _setLoading(false);
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
