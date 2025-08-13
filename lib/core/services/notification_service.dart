// lib/core/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(android: android, iOS: ios);
    await _notifications.initialize(settings);
  }

  static Future<void> showBudgetAlert({
    required String category,
    required double percentage,
  }) async {
    const android = AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Notifications for budget limits',
      importance: Importance.high,
      priority: Priority.high,
    );

    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    await _notifications.show(
      0,
      'Budget Alert!',
      'You have used ${percentage.toStringAsFixed(0)}% of your $category budget',
      details,
    );
  }

  static Future<void> showExpenseReminder(String title, String body) async {
    const android = AndroidNotificationDetails(
      'expense_reminders',
      'Expense Reminders',
      channelDescription: 'Reminders for expense tracking',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);

    await _notifications.show(1, title, body, details);
  }
}
