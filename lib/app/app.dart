import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart'; // Updated import
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

              // Light Theme (Material 3 compatible)
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                primarySwatch: Colors.indigo,
                scaffoldBackgroundColor: const Color(0xFFE0E5EC),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF6C7CE7),
                  brightness: Brightness.light,
                  surface: const Color(0xFFE0E5EC),
                ),
                textTheme: Theme.of(context).textTheme.apply(
                      bodyColor: const Color(0xFF2C3E50),
                      displayColor: const Color(0xFF2C3E50),
                    ),
              ),

              // Dark Theme (Material 3 compatible)
              darkTheme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                primarySwatch: Colors.indigo,
                scaffoldBackgroundColor: const Color(0xFF2C3E50),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF6C7CE7),
                  brightness: Brightness.dark,
                  surface: const Color(0xFF2C3E50),
                ),
                textTheme: Theme.of(context).primaryTextTheme.apply(
                      bodyColor: const Color(0xFFECF0F1),
                      displayColor: const Color(0xFFECF0F1),
                    ),
              ),
            );
          },
        );
      },
    );
  }
}
