import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/budget_model.dart';
import '../../core/services/firebase_service.dart';
import '../models/user_model.dart'; // Ensure this import is present

class ExtraBudget {
  final String id;
  final String category;
  final double amount;
  ExtraBudget({
    required this.id,
    required this.category,
    required this.amount,
  });
}

class BudgetProvider extends ChangeNotifier {
  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, double> _autoBudgets = {};
  List<ExtraBudget> _extras = [];

  Map<String, double> get autoBudgets => _autoBudgets;
  List<ExtraBudget> get extraBudgets => _extras;

  // Getters
  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Calculated getters
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> loadBudgets(String userId) async {
    try {
      _setLoading(true);
      _setError(null);

      final querySnapshot = await FirebaseService.budgetsCollection
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('category')
          .get();

      _budgets = querySnapshot.docs
          .map((doc) => BudgetModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _setError('Failed to load budgets');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createBudget({
    required String userId,
    required String category,
    required double allocatedAmount,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final budget = BudgetModel(
        id: '', // Will be set by Firestore
        userId: userId,
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

      // Add to local list with the generated ID
      final newBudget = BudgetModel(
        id: docRef.id,
        userId: userId,
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

      _budgets.add(newBudget);

      return true;
    } catch (e) {
      _setError('Failed to create budget');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateBudgetSpent(String category, double amount) async {
    try {
      final budgetIndex = _budgets.indexWhere(
          (budget) => budget.category == category && budget.isActive);

      if (budgetIndex == -1) return false;
      final budget = _budgets[budgetIndex];
      final updatedBudget = budget.copyWith(
        spentAmount: budget.spentAmount + amount,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.budgetsCollection
          .doc(budget.id)
          .update(updatedBudget.toFirestore());

      _budgets[budgetIndex] = updatedBudget;
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to update budget');
      return false;
    }
  }

  Future<bool> updateBudget(BudgetModel updatedBudget) async {
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
      }

      return true;
    } catch (e) {
      _setError('Failed to update budget');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteBudget(String budgetId) async {
    try {
      _setLoading(true);
      _setError(null);

      await FirebaseService.budgetsCollection.doc(budgetId).delete();

      _budgets.removeWhere((budget) => budget.id == budgetId);

      return true;
    } catch (e) {
      _setError('Failed to delete budget');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  BudgetModel? getBudgetByCategory(String category) {
    try {
      return _budgets.firstWhere(
          (budget) => budget.category == category && budget.isActive);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // NEW: Build auto-budgets from user profile percentages & income
  void loadUserBudgets(UserModel user) {
    final income = user.monthlyIncome;
    _autoBudgets = user.budgetCategories.map(
      (cat, pct) => MapEntry(cat, pct / 100 * income),
    );
    notifyListeners();
  }

  void addExtraBudget(String category, double amount) {
    final extra = ExtraBudget(
      id: Uuid().v4(),
      category: category,
      amount: amount,
    );
    _extras.add(extra);
    notifyListeners();
  }

  void removeExtra(String id) {
    _extras.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
