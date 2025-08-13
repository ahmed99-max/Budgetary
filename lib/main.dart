import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app/app.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/expense_provider.dart';
import 'core/providers/category_provider.dart';
import 'core/providers/budget_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/hive_service.dart';
import 'firebase_options.dart';
import 'dart:developer' as developer;

// Global navigation key for notifications and routing
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Set system UI overlay style for neumorphic design
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFE0E5EC),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    // Set preferred orientations
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      developer.log('Flutter Error: ${details.exception}', 
        name: 'FlutterError', 
        error: details.exception,
        stackTrace: details.stack);
    };

    // Initialize Hive for offline storage
    await Hive.initFlutter();
    await HiveService.initHive();
    developer.log('Hive initialized successfully');

    // Initialize Firebase
    developer.log('Starting Firebase initialization...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase initialized successfully');

    // Initialize notifications
    await NotificationService.initialize();
    await AwesomeNotifications().initialize(
      null, // Use default app icon
      [
        NotificationChannel(
          channelKey: 'expense_alerts',
          channelName: 'Expense Alerts',
          channelDescription: 'Notifications for expense tracking and budget alerts',
          defaultColor: const Color(0xFF6C7CE7),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'budget_notifications',
          channelName: 'Budget Notifications',
          channelDescription: 'Budget limit and goal notifications',
          defaultColor: const Color(0xFF4CAF50),
          importance: NotificationImportance.Default,
        ),
      ],
    );

    // Request notification permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) {
            developer.log('Initializing ThemeProvider');
            return ThemeProvider();
          }),
          ChangeNotifierProvider(create: (_) {
            developer.log('Initializing AuthProvider');
            return AuthProvider();
          }),
          ChangeNotifierProvider(create: (_) {
            developer.log('Initializing UserProvider');
            return UserProvider();
          }),
          ChangeNotifierProvider(create: (_) {
            developer.log('Initializing ExpenseProvider');
            return ExpenseProvider();
          }),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => BudgetProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: MyApp(navigatorKey: navigatorKey),
      ),
    );
    developer.log('App started successfully');
  } catch (e, stackTrace) {
    developer.log('Error starting app: $e', 
      name: 'MainError', 
      error: e,
      stackTrace: stackTrace);
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      theme: const NeumorphicThemeData(
        baseColor: Color(0xFFE0E5EC),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      home: Scaffold(
        backgroundColor: const Color(0xFFE0E5EC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Neumorphic(
                  style: NeumorphicStyle(
                    shape: NeumorphicShape.convex,
                    boxShape: NeumorphicBoxShape.circle(),
                    depth: 8,
                    intensity: 0.6,
                    color: const Color(0xFFE0E5EC),
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
                    child: const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Color(0xFFE74C3C),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Neumorphic(
                  style: const NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.all(Radius.circular(12)),
                    ),
                    depth: -2,
                    intensity: 0.7,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'App Failed to Start',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C3E50),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          error,
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF7F8C8D),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                NeumorphicButton(
                  onPressed: () {
                    // Restart the app
                    SystemNavigator.pop();
                  },
                  style: const NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.roundRect(
                      BorderRadius.all(Radius.circular(12)),
                    ),
                    depth: 4,
                    intensity: 0.6,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          color: const Color(0xFF6C7CE7),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Restart App',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6C7CE7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
