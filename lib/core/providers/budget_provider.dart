import 'package:flutter/material.dart';

class BudgetModel {
  final String id;
  final String categoryId;
  final String categoryName;
  final double budgetAmount;
  final double spentAmount;
  final DateTime month;

  BudgetModel({required this.id, required this.categoryId, required this.categoryName, required this.budgetAmount, required this.spentAmount, required this.month});

  double get remainingAmount => budgetAmount - spentAmount;
  double get progressPercentage => budgetAmount > 0 ? (spentAmount / budgetAmount).clamp(0.0, 1.0) : 0.0;
  bool get isOverBudget => spentAmount > budgetAmount;
}

class BudgetProvider with ChangeNotifier {
  final List<BudgetModel> _budgets = [
    BudgetModel(id: '1', categoryId: '1', categoryName: 'Food & Dining', budgetAmount: 800.0, spentAmount: 520.0, month: DateTime.now()),
    BudgetModel(id: '2', categoryId: '2', categoryName: 'Transportation', budgetAmount: 400.0, spentAmount: 280.0, month: DateTime.now()),
    BudgetModel(id: '3', categoryId: '4', categoryName: 'Entertainment', budgetAmount: 300.0, spentAmount: 150.0, month: DateTime.now()),
    BudgetModel(id: '4', categoryId: '5', categoryName: 'Bills', budgetAmount: 600.0, spentAmount: 580.0, month: DateTime.now()),
  ];

  List<BudgetModel> get budgets => _budgets;
  double get totalBudget => _budgets.fold(0.0, (sum, budget) => sum + budget.budgetAmount);
  double get totalSpent => _budgets.fold(0.0, (sum, budget) => sum + budget.spentAmount);
  double get overallProgress => totalBudget > 0 ? (totalSpent / totalBudget).clamp(0.0, 1.0) : 0.0;

  void setBudget(String categoryId, String categoryName, double amount) {
    final existingIndex = _budgets.indexWhere((b) => b.categoryId == categoryId);
    if (existingIndex != -1) {
      _budgets[existingIndex] = BudgetModel(
        id: _budgets[existingIndex].id,
        categoryId: categoryId,
        categoryName: categoryName,
        budgetAmount: amount,
        spentAmount: _budgets[existingIndex].spentAmount,
        month: DateTime.now(),
      );
    } else {
      _budgets.add(BudgetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: categoryId,
        categoryName: categoryName,
        budgetAmount: amount,
        spentAmount: 0.0,
        month: DateTime.now(),
      ));
    }
    notifyListeners();
  }
}