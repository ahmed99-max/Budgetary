import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/expense_provider.dart';
import 'core/providers/category_provider.dart'; // Added this import to fix the error
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  developer.log('Starting Firebase initialization...');
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDkOu-mz4sf3OJzA-441F6QU1yNNvBJEKw",
          authDomain: "expensewise-app-51036.firebaseapp.com",
          projectId: "expensewise-app-51036",
          storageBucket: "expensewise-app-51036.firebasestorage.app",
          messagingSenderId: "877358190612",
          appId: "1:877358190612:web:4e0e5c83fdd2c816249701",
          measurementId: "G-44318Q6QR0"),
    );
  } else {
    await Firebase.initializeApp();
  }
  developer.log('Firebase initialized.');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          developer.log('Initializing ThemeProvider.');
          return ThemeProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          developer.log('Initializing AuthProvider.');
          return AuthProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          developer.log('Initializing UserProvider.');
          return UserProvider();
        }),
        ChangeNotifierProvider(create: (_) {
          developer.log('Initializing ExpenseProvider.');
          return ExpenseProvider();
        }),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
  developer.log('runApp executed, app started.');
}
