// lib/core/providers/expense_provider.dart
// Updated to include categoryName getter in ExpenseModel (mapped to category for compatibility)
// Preserved all original fields, methods, sample data, and logic
// No changes to ExpenseProvider class itself, as it was already functional

import 'package:flutter/material.dart';

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category; // Original field preserved
  final DateTime date;
  final String description;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description = '',
  });

  // Added categoryName getter (maps to category to match dashboard usage)
  // This resolves the undefined getter errors without changing existing logic
  String get categoryName => category;
}

class ExpenseProvider with ChangeNotifier {
  final List<ExpenseModel> _expenses = [
    ExpenseModel(
        id: '1',
        title: 'Grocery Shopping',
        amount: 85.50,
        category: 'Food & Dining',
        date: DateTime.now().subtract(Duration(days: 1)),
        description: 'Weekly groceries'),
    ExpenseModel(
        id: '2',
        title: 'Gas Station',
        amount: 45.20,
        category: 'Transportation',
        date: DateTime.now().subtract(Duration(days: 2)),
        description: 'Fuel for car'),
    ExpenseModel(
        id: '3',
        title: 'Coffee Shop',
        amount: 12.75,
        category: 'Food & Dining',
        date: DateTime.now().subtract(Duration(days: 3)),
        description: 'Morning coffee'),
    ExpenseModel(
        id: '4',
        title: 'Movie Tickets',
        amount: 28.00,
        category: 'Entertainment',
        date: DateTime.now().subtract(Duration(days: 4)),
        description: 'Weekend movie'),
    ExpenseModel(
        id: '5',
        title: 'Electric Bill',
        amount: 125.30,
        category: 'Bills',
        date: DateTime.now().subtract(Duration(days: 5)),
        description: 'Monthly electricity'),
  ];

  List<ExpenseModel> get expenses => _expenses;
  double get totalExpenses =>
      _expenses.fold(0, (sum, expense) => sum + expense.amount);
  double get monthlyTotal {
    final currentMonth = DateTime.now().month;
    return _expenses
        .where((e) => e.date.month == currentMonth)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  void addExpense(ExpenseModel expense) {
    _expenses.insert(0, expense);
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }

  void updateExpense(String id, ExpenseModel updatedExpense) {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      _expenses[index] = updatedExpense;
      notifyListeners();
    }
  }
}
