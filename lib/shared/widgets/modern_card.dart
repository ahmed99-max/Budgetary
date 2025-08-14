import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/providers/theme_provider.dart'; // Adjust path if needed

class ModernCard extends StatelessWidget {
  final Widget child;
  final double? elevation;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Color? color;

  const ModernCard({
    super.key,
    required this.child,
    this.elevation = 4.0,
    this.borderRadius,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Neumorphic(
      style: NeumorphicStyle(
        depth: elevation,
        intensity: 0.6,
        shape: NeumorphicShape.concave,
        boxShape: NeumorphicBoxShape.roundRect(
          borderRadius ?? BorderRadius.circular(12.r),
        ),
        color: color ??
            (isDark ? const Color(0xFF2C3E50) : const Color(0xFFE0E5EC)),
        lightSource: LightSource.topLeft,
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(16.sp),
        child: child,
      ),
    );
  }
}
