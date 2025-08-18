import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/budget_model.dart';
import '../models/user_model.dart';
import '../../features/budget/data/budget_repository.dart';
import '../../core/services/firebase_service.dart';

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
  final _repo = BudgetRepository();

  List<BudgetModel> _budgets = [];
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, double> _autoBudgets = {};
  List<ExtraBudget> _extras = [];

  // Getters
  List<BudgetModel> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Map<String, double> get autoBudgets => _autoBudgets;
  List<ExtraBudget> get extraBudgets => _extras;

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

  BudgetProvider() {
    // Use the new repository's watchBudgets stream
    _repo.watchBudgets().listen((list) {
      _budgets = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // CRUD using repository
  Future<void> addBudget(BudgetModel budget) async {
    try {
      _setLoading(true);
      await _repo.addBudget(budget);
    } catch (e) {
      _setError('Failed to add budget');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateBudget(BudgetModel budget) async {
    try {
      _setLoading(true);
      await _repo.updateBudget(budget);
    } catch (e) {
      _setError('Failed to update budget');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      _setLoading(true);
      await _repo.deleteBudget(id);
    } catch (e) {
      _setError('Failed to delete budget');
    } finally {
      _setLoading(false);
    }
  }

  // Additional helpers (from old code)
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

  // Auto-budgets from user profile percentages & income
  void loadUserBudgets(UserModel user) {
    final income = user.monthlyIncome;
    _autoBudgets = user.budgetCategories.map(
      (cat, pct) => MapEntry(cat, pct / 100 * income),
    );
    notifyListeners();
  }

  void addExtraBudget(String category, double amount) {
    final extra = ExtraBudget(
      id: const Uuid().v4(),
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
