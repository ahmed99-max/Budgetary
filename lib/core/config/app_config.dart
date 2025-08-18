import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = 'Budgetary';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration liquidAnimation = Duration(milliseconds: 800);

  // Spacing
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  // Elevation
  static const double elevationS = 2.0;
  static const double elevationM = 4.0;
  static const double elevationL = 8.0;
  static const double elevationXL = 12.0;

  // Liquid Animation Curves
  static const Curve liquidCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.bounceOut;

  // Currency Settings
  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'INR',
    'JPY',
    'CNY',
    'CAD',
    'AUD'
  ];

  // Default Budget Categories
  static const Map<String, String> defaultCategories = {
    'Food & Dining': '🍽️',
    'Transportation': '🚗',
    'Shopping': '🛍️',
    'Entertainment': '🎬',
    'Bills & Utilities': '📱',
    'Healthcare': '⚕️',
    'Education': '📚',
    'Travel': '✈️',
    'Savings': '💰',
    'Investment': '📈',
  };

  // Motivational Quotes
  static const List<String> motivationalQuotes = [
    "Every penny saved is a penny earned! 💪",
    "Small steps lead to big financial goals! 🎯",
    "Your future self will thank you for saving today! ✨",
    "Budget like a boss, save like a champion! 🏆",
    "Financial freedom starts with smart choices! 🚀",
    "Track your spending, secure your future! 💎",
  ];
}
