import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  bool _budgetAlertsEnabled = true;
  bool _expenseRemindersEnabled = true;
  bool _weeklyReportsEnabled = true;
  bool _monthlyReportsEnabled = true;

  bool get budgetAlertsEnabled => _budgetAlertsEnabled;
  bool get expenseRemindersEnabled => _expenseRemindersEnabled;
  bool get weeklyReportsEnabled => _weeklyReportsEnabled;
  bool get monthlyReportsEnabled => _monthlyReportsEnabled;

  void setBudgetAlerts(bool enabled) {
    _budgetAlertsEnabled = enabled;
    notifyListeners();
  }

  void setExpenseReminders(bool enabled) {
    _expenseRemindersEnabled = enabled;
    notifyListeners();
  }

  void setWeeklyReports(bool enabled) {
    _weeklyReportsEnabled = enabled;
    notifyListeners();
  }

  void setMonthlyReports(bool enabled) {
    _monthlyReportsEnabled = enabled;
    notifyListeners();
  }
}