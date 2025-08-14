import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart'; // Updated to the maintained package
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../core/providers/theme_provider.dart';
import '../core/providers/auth_provider.dart';
import '../core/routing/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              title: 'Budgetary - Smart Finance Tracker',
              debugShowCheckedModeBanner: false,
              routerConfig: AppRouter.createRouter(),
              themeMode:
                  themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

              // Wrap the app with NeumorphicTheme for styling
              builder: (context, routerWidget) {
                return NeumorphicTheme(
                  theme: NeumorphicThemeData(
                    baseColor: const Color(0xFFE0E5EC),
                    lightSource: LightSource.topLeft,
                    depth: 6,
                    intensity: 0.65,
                    variantColor: const Color(0xFF6C7CE7),
                  ),
                  darkTheme: NeumorphicThemeData(
                    baseColor: const Color(0xFF2C3E50),
                    lightSource: LightSource.topLeft,
                    depth: 4,
                    intensity: 0.5,
                    variantColor: const Color(0xFF6C7CE7),
                  ),
                  themeMode: themeProvider.isDarkMode
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  child: routerWidget ?? const SizedBox(),
                );
              },

              // Light Theme with Material 3 support
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                primarySwatch: Colors.indigo,
                fontFamily: 'Inter', // Using local font
                scaffoldBackgroundColor: const Color(0xFFE0E5EC),
                colorScheme: ColorScheme.light(
                  primary: const Color(0xFF6C7CE7),
                  secondary: const Color(0xFF6C7CE7),
                  surface: const Color(0xFFE0E5EC),
                  background: const Color(0xFFE0E5EC),
                ),
                textTheme: const TextTheme(
                  displayLarge: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2C3E50)),
                  displayMedium: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50)),
                  displaySmall: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50)),
                  headlineLarge: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50)),
                  headlineMedium: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50)),
                  titleLarge: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50)),
                  titleMedium: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C3E50)),
                  bodyLarge: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF2C3E50)),
                  bodyMedium: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF7F8C8D)),
                  labelLarge: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50)),
                ),
              ),

              // Dark Theme with Material 3 support
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                primarySwatch: Colors.indigo,
                fontFamily: 'Inter', // Using local font
                scaffoldBackgroundColor: const Color(0xFF2C3E50),
                colorScheme: ColorScheme.dark(
                  primary: const Color(0xFF6C7CE7),
                  secondary: const Color(0xFF6C7CE7),
                  surface: const Color(0xFF2C3E50),
                  background: const Color(0xFF2C3E50),
                ),
                textTheme: const TextTheme(
                  displayLarge: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFECF0F1)),
                  displayMedium: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFECF0F1)),
                  displaySmall: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFECF0F1)),
                  headlineLarge: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFECF0F1)),
                  headlineMedium: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFECF0F1)),
                  titleLarge: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFECF0F1)),
                  titleMedium: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFECF0F1)),
                  bodyLarge: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFECF0F1)),
                  bodyMedium: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFBDC3C7)),
                  labelLarge: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFECF0F1)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
