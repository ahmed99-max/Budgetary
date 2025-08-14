// lib/core/providers/user_provider.dart
// Updated to include monthlyIncome getter (mapped to _totalIncome for compatibility)
// Preserved all original fields, methods, and logic

import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  // Your existing fields (preserved)
  String _userName = 'Demo User';
  String _userEmail = 'demo@budgetary.com';
  double _totalIncome = 5000.0;
  double _totalExpenses = 2500.0;
  double _totalSavings = 1500.0;

  // Your existing getters (preserved)
  String get userName => _userName;
  String get userEmail => _userEmail;
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;
  double get totalSavings => _totalSavings;
  double get netWorth => _totalIncome - _totalExpenses;
  double get monthlyIncome => _totalIncome;

  // Added for fixes: isLoading getter and backing field
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Your existing method (preserved)
  void updateUserData(
      {String? name,
      String? email,
      double? income,
      double? expenses,
      double? savings}) {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (income != null) _totalIncome = income;
    if (expenses != null) _totalExpenses = expenses;
    if (savings != null) _totalSavings = savings;
    notifyListeners();
  }

  // Added for fixes: saveUserSetup method (simulates async save; add real logic here)
  Future<bool> saveUserSetup({
    required String userId,
    required String? name,
    required String? email,
    required int age,
    required double monthlyIncome,
    required String country,
    required String currency,
    required List<dynamic> emiLoans,
    required Map<String, double> budgetPercentages,
  }) async {
    _isLoading = true;
    notifyListeners();

    // Simulate saving (replace with real Firebase/cloud storage call)
    await Future.delayed(const Duration(seconds: 2));

    // Update local state (example; adjust as needed)
    _userName = name ?? _userName;
    _userEmail = email ?? _userEmail;
    _totalIncome = monthlyIncome;

    _isLoading = false;
    notifyListeners();
    return true; // Return false on failure in real implementation
  }
}
