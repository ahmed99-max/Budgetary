// lib/shared/widgets/liquid_bottom_nav.dart
// COMPLETE ENHANCED VERSION

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import 'main_layout.dart';

class LiquidBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<NavItem> items;
  final Function(int) onTap;

  const LiquidBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _calculateNavHeight() + MediaQuery.of(context).padding.bottom,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
          ],
        ),
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.15),
            blurRadius: 35,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_getBorderRadius()),
        child: Stack(
          children: [
            // Liquid background indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              left: _getIndicatorPosition(context),
              top: _getIndicatorMargin(),
              child: Container(
                width: _getIndicatorWidth(context),
                height: _getIndicatorHeight(),
                decoration: BoxDecoration(
                  gradient: AppTheme.liquidBackground,
                  borderRadius: BorderRadius.circular(_getBorderRadius() - 5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.35),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ).animate().scale(begin: const Offset(0.8, 0.8)).then().shimmer(
                    duration: 1200.ms,
                    color: Colors.white.withOpacity(0.3),
                  ),
            ),

            // Navigation items with responsive layout
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == currentIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(index),
                      child: Container(
                        height: _calculateNavHeight(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon with responsive sizing
                            Container(
                              padding: EdgeInsets.all(isSelected ? 8.w : 6.w),
                              child: Icon(
                                item.icon,
                                size: _getIconSize(isSelected),
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            )
                                .animate(target: isSelected ? 1 : 0)
                                .scale(
                                  begin: const Offset(1.0, 1.0),
                                  end: const Offset(1.2, 1.2),
                                  duration: 250.ms,
                                )
                                .then()
                                .shake(
                                  hz: 2,
                                  curve: Curves.easeInOutCubic,
                                  duration: 300.ms,
                                ),

                            SizedBox(height: _getLabelSpacing()),

                            // Label with responsive typography
                            Text(
                              item.label,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: _getLabelFontSize(isSelected),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                letterSpacing: 0.3,
                                height: 1.0,
                              ),
                            )
                                .animate(target: isSelected ? 1 : 0)
                                .fadeIn(duration: 200.ms)
                                .slideY(begin: 0.3, end: 0, duration: 250.ms),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Responsive calculations
  double _calculateNavHeight() {
    if (items.length <= 4) return 80.h;
    if (items.length <= 6) return 75.h;
    return 70.h;
  }

  double _getBorderRadius() {
    if (items.length <= 4) return 25.r;
    if (items.length <= 6) return 22.r;
    return 20.r;
  }

  double _getIconSize(bool isSelected) {
    final baseSize = items.length <= 4
        ? 24.sp
        : items.length <= 6
            ? 22.sp
            : 20.sp;
    return isSelected ? baseSize : baseSize - 1.sp;
  }

  double _getLabelFontSize(bool isSelected) {
    final baseSize = items.length <= 4
        ? 10.sp
        : items.length <= 6
            ? 9.sp
            : 8.sp;
    return isSelected ? baseSize + 0.5.sp : baseSize;
  }

  double _getLabelSpacing() {
    if (items.length <= 4) return 4.h;
    if (items.length <= 6) return 3.h;
    return 2.h;
  }

  double _getIndicatorHeight() {
    return _calculateNavHeight() - 20.h;
  }

  double _getIndicatorMargin() {
    return 10.h;
  }

  double _getIndicatorPosition(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final navWidth = screenWidth - 40.w;
    final itemWidth = navWidth / items.length;
    return (itemWidth * currentIndex) + 8.w;
  }

  double _getIndicatorWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final navWidth = screenWidth - 40.w;
    final itemWidth = navWidth / items.length;
    return itemWidth - 16.w;
  }
}
