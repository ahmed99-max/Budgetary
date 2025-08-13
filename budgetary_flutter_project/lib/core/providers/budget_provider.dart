import 'package:flutter/material.dart';
import '../../models/budget.dart';

/// Enum to represent budget health status
enum BudgetHealth { good, warning, bad }

class BudgetProvider extends ChangeNotifier {
  /// All budgets
  List<Budget> budgets = [];

  /// All savings goals
  List<SavingsGoal> savingsGoals = [];

  /// Totals
  double totalBudget = 0;
  double totalSpent = 0;
  double totalSavings = 0;
  double monthlySavings = 0;
  double savingsRate = 0;
  bool isLoading = false;

  /// Budget health status
  BudgetHealth budgetHealth = BudgetHealth.good;

  /// Recommendations for improving budget health
  List<String> budgetRecommendations = [];

  BudgetProvider() {
    // Optionally load initial data here
  }

  /// Load budgets (could fetch from Firestore/DB/API)
  void loadBudgets() {
    // TODO: load budgets from backend
    _evaluateBudgetHealth();
    notifyListeners();
  }

  /// Add a new budget
  void addBudget(Budget budget) {
    budgets.add(budget);
    _recalculateTotals();
    _evaluateBudgetHealth();
    notifyListeners();
  }

  /// Delete a budget by ID
  void deleteBudget(String id) {
    budgets.removeWhere((b) => b.id == id);
    _recalculateTotals();
    _evaluateBudgetHealth();
    notifyListeners();
  }

  /// Add expense to a budget
  void addExpenseToBudget(String budgetId, double amount, String description) {
    final budgetIndex = budgets.indexWhere((b) => b.id == budgetId);
    if (budgetIndex == -1) return; // Budget not found

    final budget = budgets[budgetIndex];

    // Create new expense
    final expense = BudgetExpense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      amount: amount,
      date: DateTime.now(),
    );

    // Add to budget's expense list
    budget.expenses.add(expense);

    // Update spent value
    budget.spent += amount;

    // Replace updated budget back into list
    budgets[budgetIndex] = budget;

    // Recalculate provider totals
    _recalculateTotals();

    // Check budget health after update
    _evaluateBudgetHealth();

    // Notify UI to refresh
    notifyListeners();
  }

  /// Delete savings goal
  void deleteSavingsGoal(String id) {
    savingsGoals.removeWhere((goal) => goal.id == id);
    notifyListeners();
  }

  /// Add savings amount to goal
  void addSavingsToGoal(String id, double amount) {
    final goalIndex = savingsGoals.indexWhere((goal) => goal.id == id);
    if (goalIndex != -1) {
      final goal = savingsGoals[goalIndex];
      goal.currentAmount += amount;
      savingsGoals[goalIndex] = goal;
      notifyListeners();
    }
  }

  /// Private method to recalculate totals
  void _recalculateTotals() {
    totalBudget = budgets.fold(0, (sum, b) => sum + b.amount);
    totalSpent = budgets.fold(0, (sum, b) => sum + b.spent);
    totalSavings = budgets.fold(0, (sum, b) => sum + (b.amount - b.spent));
    savingsRate = totalBudget > 0 ? (totalSavings / totalBudget) * 100 : 0;
  }

  /// Evaluate budget health and generate recommendations
  void _evaluateBudgetHealth() {
    budgetRecommendations.clear();

    if (totalBudget <= 0) {
      budgetHealth = BudgetHealth.bad;
      budgetRecommendations.add('No budget set. Please create a budget.');
      return;
    }

    double spentPercent = (totalSpent / totalBudget) * 100;

    if (spentPercent < 70) {
      budgetHealth = BudgetHealth.good;
      budgetRecommendations
          .add('Great job! You are keeping your spending low.');
    } else if (spentPercent < 90) {
      budgetHealth = BudgetHealth.warning;
      budgetRecommendations
          .add('You are close to your budget limit. Be cautious.');
    } else {
      budgetHealth = BudgetHealth.bad;
      budgetRecommendations
          .add('You have exceeded your budget. Reduce expenses ASAP.');
    }
  }

  /// String message for budget health
  String getBudgetHealthMessage() {
    switch (budgetHealth) {
      case BudgetHealth.good:
        return 'Your budget is in great shape!';
      case BudgetHealth.warning:
        return 'You are close to overspending. Monitor your expenses carefully.';
      case BudgetHealth.bad:
        return 'Your spending has exceeded your budget. Take action now.';
      default:
        return '';
    }
  }
}
