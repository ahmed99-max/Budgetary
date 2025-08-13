import 'package:flutter/material.dart';
import '../../models/expense_model.dart';

class ExpenseProvider with ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ExpenseModel> get expenses => _expenses;
  List<ExpenseModel> get recentExpenses => _expenses.take(10).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get monthlyTotal => _expenses
      .where((e) => e.date?.month == DateTime.now().month)
      .fold(0.0, (sum, e) => sum + (e.amount ?? 0));

  Future<void> loadExpenses() async {
    _setLoading(true);
    try {
      // TODO: Implement expense loading from Firebase
      await Future.delayed(const Duration(milliseconds: 500));
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
