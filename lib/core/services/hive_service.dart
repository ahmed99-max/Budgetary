import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static late Box _userBox;
  static late Box _expenseBox;
  static late Box _budgetBox;
  static late Box _settingsBox;

  static Future<void> init() async {
    _userBox = await Hive.openBox('user');
    _expenseBox = await Hive.openBox('expenses');
    _budgetBox = await Hive.openBox('budgets');
    _settingsBox = await Hive.openBox('settings');
  }

  // User Data
  static Box get userBox => _userBox;
  static Future<void> saveUserData(String key, dynamic value) async {
    await _userBox.put(key, value);
  }

  static T? getUserData<T>(String key) => _userBox.get(key);

  // Expense Data
  static Box get expenseBox => _expenseBox;
  static Future<void> saveExpense(String key, dynamic value) async {
    await _expenseBox.put(key, value);
  }

  static T? getExpense<T>(String key) => _expenseBox.get(key);

  // Budget Data
  static Box get budgetBox => _budgetBox;
  static Future<void> saveBudget(String key, dynamic value) async {
    await _budgetBox.put(key, value);
  }

  static T? getBudget<T>(String key) => _budgetBox.get(key);

  // Settings Data
  static Box get settingsBox => _settingsBox;
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key) => _settingsBox.get(key);

  // Clear all data
  static Future<void> clearAllData() async {
    await _userBox.clear();
    await _expenseBox.clear();
    await _budgetBox.clear();
    await _settingsBox.clear();
  }
}
