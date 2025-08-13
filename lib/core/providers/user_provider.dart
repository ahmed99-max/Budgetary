import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _userName = 'Demo User';
  String _userEmail = 'demo@budgetary.com';
  double _totalIncome = 5000.0;
  double _totalExpenses = 2500.0;
  double _totalSavings = 1500.0;

  String get userName => _userName;
  String get userEmail => _userEmail;
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;
  double get totalSavings => _totalSavings;
  double get netWorth => _totalIncome - _totalExpenses;

  void updateUserData({String? name, String? email, double? income, double? expenses, double? savings}) {
    if (name != null) _userName = name;
    if (email != null) _userEmail = email;
    if (income != null) _totalIncome = income;
    if (expenses != null) _totalExpenses = expenses;
    if (savings != null) _totalSavings = savings;
    notifyListeners();
  }
}