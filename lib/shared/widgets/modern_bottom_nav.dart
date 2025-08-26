// lib/shared/widgets/modern_bottom_nav.dart
// BATCH 5: CREATE THIS NEW FILE

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import '../../core/theme/app_theme.dart';
import 'main_layout.dart';

class ModernBottomNav extends StatefulWidget {
  final int currentIndex;
  final List<NavItem> items;
  final Function(int) onTap;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  State<ModernBottomNav> createState() => _ModernBottomNavState();
}

class _ModernBottomNavState extends State<ModernBottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _bubbleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bubbleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _bubbleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bubbleController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: 80.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.r),
                child: Stack(
                  children: [
                    // Animated background indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                      left: _getIndicatorPosition(context),
                      top: 10.h,
                      child: Container(
                        width: _getItemWidth(context),
                        height: 60.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryPurple,
                              AppTheme.primaryBlue,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .scale(begin: const Offset(0.8, 0.8))
                          .then()
                          .shimmer(
                            duration: 1500.ms,
                            color: Colors.white.withOpacity(0.3),
                          ),
                    ),

                    // Navigation items
                    Row(
                      children: widget.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final isSelected = index == widget.currentIndex;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _bubbleController.forward().then((_) {
                                _bubbleController.reverse();
                              });
                              widget.onTap(index);
                            },
                            child: Container(
                              height: 80.h,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Bubble effect
                                  AnimatedBuilder(
                                    animation: _bubbleAnimation,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: isSelected &&
                                                index == widget.currentIndex
                                            ? 1.0 +
                                                (_bubbleAnimation.value * 0.1)
                                            : 1.0,
                                        child: Container(
                                          width: 50.w,
                                          height: 50.h,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected
                                                ? Colors.transparent
                                                : Colors.transparent,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // Icon and label
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Icon with rotation animation
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: Transform.rotate(
                                          angle: isSelected ? math.pi * 2 : 0,
                                          child: Icon(
                                            item.icon,
                                            size: isSelected ? 26.sp : 22.sp,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      )
                                          .animate(target: isSelected ? 1 : 0)
                                          .scale(
                                            begin: const Offset(1.0, 1.0),
                                            end: const Offset(1.2, 1.2),
                                            duration: 200.ms,
                                          )
                                          .then()
                                          .shake(
                                            hz: 2,
                                            curve: Curves.easeInOut,
                                            duration: 400.ms,
                                          ),

                                      SizedBox(height: 2.h),

                                      // Label with slide animation
                                      AnimatedOpacity(
                                        opacity: isSelected ? 1.0 : 0.8,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: Text(
                                          item.label,
                                          style: TextStyle(
                                            fontSize:
                                                isSelected ? 11.sp : 10.sp,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? Colors.white
                                                : Colors.grey.shade600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      )
                                          .animate(target: isSelected ? 1 : 0)
                                          .slideY(
                                            begin: 0.3,
                                            end: 0,
                                            duration: 300.ms,
                                          )
                                          .fadeIn(duration: 200.ms),
                                    ],
                                  ),
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
            ),
          );
        },
      ),
    );
  }

  double _getIndicatorPosition(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final navWidth = screenWidth - 32.w; // Account for margins
    final itemWidth = navWidth / widget.items.length;
    return (itemWidth * widget.currentIndex) + 16.w;
  }

  double _getItemWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final navWidth = screenWidth - 32.w; // Account for margins
    return navWidth / widget.items.length - 20.w; // Account for padding
  }
}
