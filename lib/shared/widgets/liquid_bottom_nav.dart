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
      height: 80.h + MediaQuery.of(context).padding.bottom,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF8FAFC),
          ],
        ),
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.r),
        child: Stack(
          children: [
            // Liquid background indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: (MediaQuery.of(context).size.width - 40.w) /
                      items.length *
                      currentIndex +
                  10.w,
              top: 10.h,
              child: Container(
                width:
                    (MediaQuery.of(context).size.width - 40.w) / items.length -
                        20.w,
                height: 60.h,
                decoration: BoxDecoration(
                  gradient: AppTheme.liquidBackground,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ).animate().scale(begin: const Offset(0.8, 0.8)).then().shimmer(
                  duration: 1000.ms, color: Colors.white.withOpacity(0.3)),
            ),

            // Navigation items
            Row(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = index == currentIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(index),
                    child: Container(
                      height: 80.h,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item.icon,
                            size: 24.sp,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                          )
                              .animate(target: isSelected ? 1 : 0)
                              .scale(end: const Offset(1.2, 1.2))
                              .then()
                              .shake(hz: 2, curve: Curves.easeInOutCubic),
                          SizedBox(height: 4.h),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          )
                              .animate(target: isSelected ? 1 : 0)
                              .fadeIn()
                              .slideY(begin: 0.3, end: 0),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
