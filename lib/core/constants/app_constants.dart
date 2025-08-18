import 'package:flutter/material.dart';

class AppConstants {
  // Animation Constants
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 400);
  static const Duration longDuration = Duration(milliseconds: 600);
  static const Duration liquidDuration = Duration(milliseconds: 1000);

  // Liquid Shape Constants
  static const double liquidBorderRadius = 30.0;
  static const double cardElevation = 8.0;
  static const double buttonHeight = 56.0;

  // Color Constants
  static const Color transparentWhite = Color(0x1AFFFFFF);
  static const Color transparentBlack = Color(0x1A000000);

  // Gradient Constants
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF667EEA),
      Color(0xFF764BA2),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFF4ECDC4),
    ],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00F260),
      Color(0xFF0575E6),
    ],
  );

  // Box Shadow Constants
  static List<BoxShadow> get liquidShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 40,
          offset: const Offset(0, 20),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 15,
          offset: const Offset(0, 5),
          spreadRadius: 0,
        ),
      ];

  // Responsive Breakpoints
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
}
