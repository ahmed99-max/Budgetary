import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/providers/theme_provider.dart';
import '../core/theme/neumorphic_theme.dart';
import '../core/routing/app_router.dart';
import '../shared/widgets/error_screen.dart';

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigatorKey;

  const MyApp({super.key, this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ScreenUtilInit(
          designSize: const Size(375, 812), // iPhone 11 Pro design size
          minTextAdapt: true,
          splitScreenMode: true,
          useInheritedMediaQuery: true,
          builder: (context, child) {
            return NeumorphicApp(
              title: 'Budgetary - Smart Finance Tracker',
              debugShowCheckedModeBanner: false,

              // Neumorphic theme configuration
              themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              theme: NeumorphicThemeConfig.lightTheme,
              darkTheme: NeumorphicThemeConfig.darkTheme,

              // Material app integration for router
              materialAppBuilder: (context, widget) {
                return MaterialApp.router(
                  title: 'Budgetary - Smart Finance Tracker',
                  debugShowCheckedModeBanner: false,

                  // Router configuration
                  routerConfig: AppRouter.createRouter(),

                  // Theme configuration for Material components
                  theme: _buildMaterialLightTheme(),
                  darkTheme: _buildMaterialDarkTheme(),
                  themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

                  // Global navigation key
                  key: navigatorKey,

                  // Builder for global configurations
                  builder: (context, widget) {
                    // Set system UI overlay style based on theme
                    SystemChrome.setSystemUIOverlayStyle(
                      themeProvider.isDarkMode
                          ? const SystemUiOverlayStyle(
                              statusBarColor: Colors.transparent,
                              statusBarIconBrightness: Brightness.light,
                              statusBarBrightness: Brightness.dark,
                              systemNavigationBarColor: Color(0xFF2C3E50),
                              systemNavigationBarIconBrightness: Brightness.light,
                            )
                          : const SystemUiOverlayStyle(
                              statusBarColor: Colors.transparent,
                              statusBarIconBrightness: Brightness.dark,
                              statusBarBrightness: Brightness.light,
                              systemNavigationBarColor: Color(0xFFE0E5EC),
                              systemNavigationBarIconBrightness: Brightness.dark,
                            ),
                    );

                    // Global error widget builder
                    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                      return ErrorScreen(
                        error: errorDetails.exception.toString(),
                        details: errorDetails.toString(),
                        onRetry: () => Navigator.of(context).pushNamedAndRemoveUntil(
                          '/',
                          (route) => false,
                        ),
                      );
                    };

                    return MediaQuery(
                      // Prevent font scaling issues while maintaining accessibility
                      data: MediaQuery.of(context).copyWith(
                        textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
                      ),
                      child: widget ?? const SizedBox(),
                    );
                  },

                  // Localization support (future enhancement)
                  supportedLocales: const [
                    Locale('en', 'US'),
                    Locale('es', 'ES'),
                    Locale('fr', 'FR'),
                    Locale('de', 'DE'),
                    Locale('it', 'IT'),
                  ],

                  // Performance optimizations
                  scrollBehavior: const MaterialScrollBehavior().copyWith(
                    dragDevices: {
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.touch,
                      PointerDeviceKind.stylus,
                      PointerDeviceKind.unknown,
                    },
                    scrollbars: false, // Custom neumorphic scrollbars
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  ThemeData _buildMaterialLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primarySwatch: Colors.indigo,
      primaryColor: const Color(0xFF6C7CE7),
      scaffoldBackgroundColor: const Color(0xFFE0E5EC),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFE0E5EC),
        foregroundColor: Color(0xFF2C3E50),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Card theme for neumorphic cards
      cardTheme: CardTheme(
        color: const Color(0xFFE0E5EC),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C7CE7),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFF2C3E50)),
        displayMedium: TextStyle(color: Color(0xFF2C3E50)),
        displaySmall: TextStyle(color: Color(0xFF2C3E50)),
        headlineLarge: TextStyle(color: Color(0xFF2C3E50)),
        headlineMedium: TextStyle(color: Color(0xFF2C3E50)),
        headlineSmall: TextStyle(color: Color(0xFF2C3E50)),
        titleLarge: TextStyle(color: Color(0xFF2C3E50)),
        titleMedium: TextStyle(color: Color(0xFF2C3E50)),
        titleSmall: TextStyle(color: Color(0xFF2C3E50)),
        bodyLarge: TextStyle(color: Color(0xFF34495E)),
        bodyMedium: TextStyle(color: Color(0xFF34495E)),
        bodySmall: TextStyle(color: Color(0xFF7F8C8D)),
        labelLarge: TextStyle(color: Color(0xFF2C3E50)),
        labelMedium: TextStyle(color: Color(0xFF34495E)),
        labelSmall: TextStyle(color: Color(0xFF7F8C8D)),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: Color(0xFF6C7CE7),
        size: 24,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE0E5EC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C7CE7), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFE0E5EC),
        selectedItemColor: Color(0xFF6C7CE7),
        unselectedItemColor: Color(0xFF7F8C8D),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6C7CE7),
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFFE0E5EC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFBDC3C7),
        thickness: 1,
        space: 1,
      ),
    );
  }

  ThemeData _buildMaterialDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.indigo,
      primaryColor: const Color(0xFF6C7CE7),
      scaffoldBackgroundColor: const Color(0xFF2C3E50),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2C3E50),
        foregroundColor: Color(0xFFECF0F1),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // Card theme
      cardTheme: CardTheme(
        color: const Color(0xFF2C3E50),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C7CE7),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFFECF0F1)),
        displayMedium: TextStyle(color: Color(0xFFECF0F1)),
        displaySmall: TextStyle(color: Color(0xFFECF0F1)),
        headlineLarge: TextStyle(color: Color(0xFFECF0F1)),
        headlineMedium: TextStyle(color: Color(0xFFECF0F1)),
        headlineSmall: TextStyle(color: Color(0xFFECF0F1)),
        titleLarge: TextStyle(color: Color(0xFFECF0F1)),
        titleMedium: TextStyle(color: Color(0xFFECF0F1)),
        titleSmall: TextStyle(color: Color(0xFFECF0F1)),
        bodyLarge: TextStyle(color: Color(0xFFD5DBDB)),
        bodyMedium: TextStyle(color: Color(0xFFD5DBDB)),
        bodySmall: TextStyle(color: Color(0xFFBDC3C7)),
        labelLarge: TextStyle(color: Color(0xFFECF0F1)),
        labelMedium: TextStyle(color: Color(0xFFD5DBDB)),
        labelSmall: TextStyle(color: Color(0xFFBDC3C7)),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: Color(0xFF6C7CE7),
        size: 24,
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF34495E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C7CE7), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF2C3E50),
        selectedItemColor: Color(0xFF6C7CE7),
        unselectedItemColor: Color(0xFFBDC3C7),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF6C7CE7),
        foregroundColor: Colors.white,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
      ),

      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: const Color(0xFF2C3E50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFF566573),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
