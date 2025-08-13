import 'package:flutter/material.dart';

class BudgetProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalBudget => 5000.0; // Placeholder
  double get overallProgress => 0.65; // Placeholder

  Future<void> loadBudgets() async {
    _setLoading(true);
    try {
      // TODO: Implement budget loading from Firebase
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
