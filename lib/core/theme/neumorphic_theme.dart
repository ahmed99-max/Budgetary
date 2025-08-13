import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class NeumorphicThemeConfig {
  // Light Theme Colors
  static const Color lightBaseColor = Color(0xFFE0E5EC);
  static const Color lightShadowColor = Color(0xFFA3B1C6);
  static const Color lightHighlightColor = Color(0xFFFFFFFF);

  // Dark Theme Colors
  static const Color darkBaseColor = Color(0xFF2C3E50);
  static const Color darkShadowColor = Color(0xFF1A252F);
  static const Color darkHighlightColor = Color(0xFF3F4E5F);

  // Depth and intensity constants
  static const double defaultDepth = 8.0;
  static const double buttonDepth = 4.0;
  static const double cardDepth = 6.0;
  static const double containerDepth = 10.0;
  static const double defaultIntensity = 0.65;

  // Border radius constants
  static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(8));
  static const BorderRadius mediumRadius = BorderRadius.all(Radius.circular(12));
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius extraLargeRadius = BorderRadius.all(Radius.circular(24));

  // Light theme configuration
  static NeumorphicThemeData get lightTheme => NeumorphicThemeData(
    baseColor: lightBaseColor,
    accentColor: AppColors.primary,
    variantColor: const Color(0xFFCFD8E5),
    disabledColor: const Color(0xFFBDC3C7),
    shadowLightColor: lightHighlightColor,
    shadowDarkColor: lightShadowColor,
    defaultTextColor: const Color(0xFF2C3E50),
    depth: defaultDepth,
    intensity: defaultIntensity,
    lightSource: LightSource.topLeft,
    buttonStyle: const NeumorphicStyle(
      shape: NeumorphicShape.flat,
      boxShape: NeumorphicBoxShape.roundRect(mediumRadius),
      depth: buttonDepth,
      intensity: defaultIntensity,
    ),
    iconTheme: const NeumorphicIconThemeData(
      size: 24,
      color: Color(0xFF6C7CE7),
    ),
    textTheme: NeumorphicTextThemeData(
      titleLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2C3E50),
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2C3E50),
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF2C3E50),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF34495E),
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF7F8C8D),
      ),
    ),
  );

  // Dark theme configuration
  static NeumorphicThemeData get darkTheme => NeumorphicThemeData(
    baseColor: darkBaseColor,
    accentColor: AppColors.primary,
    variantColor: const Color(0xFF34495E),
    disabledColor: const Color(0xFF566573),
    shadowLightColor: darkHighlightColor,
    shadowDarkColor: darkShadowColor,
    defaultTextColor: const Color(0xFFECF0F1),
    depth: defaultDepth,
    intensity: 0.8,
    lightSource: LightSource.topLeft,
    buttonStyle: const NeumorphicStyle(
      shape: NeumorphicShape.flat,
      boxShape: NeumorphicBoxShape.roundRect(mediumRadius),
      depth: buttonDepth,
      intensity: 0.8,
    ),
    iconTheme: const NeumorphicIconThemeData(
      size: 24,
      color: Color(0xFF6C7CE7),
    ),
    textTheme: NeumorphicTextThemeData(
      titleLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: const Color(0xFFECF0F1),
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFECF0F1),
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFECF0F1),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFD5DBDB),
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFBDC3C7),
      ),
    ),
  );

  // Common neumorphic styles
  static NeumorphicStyle get flatContainer => const NeumorphicStyle(
    shape: NeumorphicShape.flat,
    boxShape: NeumorphicBoxShape.roundRect(mediumRadius),
    depth: containerDepth,
    intensity: defaultIntensity,
  );

  static NeumorphicStyle get convexContainer => const NeumorphicStyle(
    shape: NeumorphicShape.convex,
    boxShape: NeumorphicBoxShape.roundRect(mediumRadius),
    depth: containerDepth,
    intensity: defaultIntensity,
  );

  static NeumorphicStyle get concaveContainer => const NeumorphicStyle(
    shape: NeumorphicShape.concave,
    boxShape: NeumorphicBoxShape.roundRect(mediumRadius),
    depth: -containerDepth,
    intensity: defaultIntensity,
  );

  static NeumorphicStyle get buttonStyle => const NeumorphicStyle(
    shape: NeumorphicShape.flat,
    boxShape: NeumorphicBoxShape.roundRect(mediumRadius),
    depth: buttonDepth,
    intensity: defaultIntensity,
  );

  static NeumorphicStyle get cardStyle => const NeumorphicStyle(
    shape: NeumorphicShape.flat,
    boxShape: NeumorphicBoxShape.roundRect(largeRadius),
    depth: cardDepth,
    intensity: defaultIntensity,
  );

  static NeumorphicStyle get textFieldStyle => const NeumorphicStyle(
    shape: NeumorphicShape.concave,
    boxShape: NeumorphicBoxShape.roundRect(mediumRadius),
    depth: -4,
    intensity: 0.8,
  );

  // Responsive sizing based on screen size
  static double getResponsiveSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // Mobile
      return baseSize;
    } else if (screenWidth < 1200) {
      // Tablet
      return baseSize * 1.2;
    } else {
      // Desktop
      return baseSize * 1.4;
    }
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // Mobile
      return const EdgeInsets.all(16);
    } else if (screenWidth < 1200) {
      // Tablet
      return const EdgeInsets.all(24);
    } else {
      // Desktop
      return const EdgeInsets.all(32);
    }
  }

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Elevation levels for neumorphic effects
  static const Map<String, double> elevations = {
    'card': 6,
    'button': 4,
    'fab': 8,
    'dialog': 12,
    'drawer': 16,
    'bottomSheet': 10,
  };

  // Color gradients for enhanced neumorphic effects
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFE0E5EC),
    ],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3F4E5F),
      Color(0xFF2C3E50),
    ],
  );
}

// Extension for easier access to neumorphic styles
extension NeumorphicStyleExtensions on BuildContext {
  NeumorphicStyle get flatStyle => NeumorphicThemeConfig.flatContainer;
  NeumorphicStyle get convexStyle => NeumorphicThemeConfig.convexContainer;
  NeumorphicStyle get concaveStyle => NeumorphicThemeConfig.concaveContainer;
  NeumorphicStyle get buttonStyle => NeumorphicThemeConfig.buttonStyle;
  NeumorphicStyle get cardStyle => NeumorphicThemeConfig.cardStyle;
  NeumorphicStyle get textFieldStyle => NeumorphicThemeConfig.textFieldStyle;

  EdgeInsets get responsivePadding => NeumorphicThemeConfig.getResponsivePadding(this);

  double getResponsiveSize(double baseSize) => 
    NeumorphicThemeConfig.getResponsiveSize(this, baseSize);
}
