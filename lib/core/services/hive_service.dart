import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static Future<void> initHive() async {
    try {
      await Hive.openBox('settings');
      await Hive.openBox('expenses');
      await Hive.openBox('categories');
      await Hive.openBox('budgets');
      await Hive.openBox('users');
    } catch (e) {
      print('Error initializing Hive: \$e');
    }
  }

  static Box get settingsBox => Hive.box('settings');
  static Box get expenseBox => Hive.box('expenses');
  static Box get categoryBox => Hive.box('categories');
  static Box get budgetBox => Hive.box('budgets');
  static Box get userBox => Hive.box('users');

  static Future<void> clearAllData() async {
    await settingsBox.clear();
    await expenseBox.clear();
    await categoryBox.clear();
    await budgetBox.clear();
    await userBox.clear();
  }
}