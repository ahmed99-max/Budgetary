// lib/shared/widgets/modern_bottom_nav.dart
// COMPLETE ENHANCED VERSION

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
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: _calculateNavHeight(),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.90),
                    Colors.grey.shade50.withOpacity(0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(_getBorderRadius()),
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
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
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 25,
                    offset: const Offset(0, 5),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_getBorderRadius()),
                child: Stack(
                  children: [
                    // Animated background indicator
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOutCubic,
                      left: _getIndicatorPosition(context),
                      top: _getIndicatorTopMargin(),
                      child: Container(
                        width: _getItemWidth(context),
                        height: _getIndicatorHeight(),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryPurple,
                              AppTheme.primaryBlue,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(_getBorderRadius() - 5),
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

                    // Navigation items with responsive layout
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: widget.items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isSelected = index == widget.currentIndex;

                          return Expanded(
                            child: _buildNavItem(item, index, isSelected),
                          );
                        }).toList(),
                      ),
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

  Widget _buildNavItem(NavItem item, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        _bubbleController.forward().then((_) {
          _bubbleController.reverse();
        });
        widget.onTap(index);
      },
      child: Container(
        height: _calculateNavHeight(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Bubble effect
            AnimatedBuilder(
              animation: _bubbleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: isSelected && index == widget.currentIndex
                      ? 1.0 + (_bubbleAnimation.value * 0.1)
                      : 1.0,
                  child: Container(
                    width: _getItemWidth(context) * 0.8,
                    height: _getIndicatorHeight() * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                  ),
                );
              },
            ),

            // Icon and label container
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon with enhanced animations
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(isSelected ? 8.w : 6.w),
                  child: Transform.rotate(
                    angle: isSelected ? math.pi * 2 : 0,
                    child: Icon(
                      item.icon,
                      size: _getIconSize(isSelected),
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                )
                    .animate(target: isSelected ? 1 : 0)
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.15, 1.15),
                      duration: 250.ms,
                    )
                    .then()
                    .shake(
                      hz: 2,
                      curve: Curves.easeInOut,
                      duration: 400.ms,
                    ),

                SizedBox(height: _getLabelSpacing()),

                // Label with enhanced typography
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: _getLabelFontSize(isSelected),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    letterSpacing: 0.5,
                    height: 1.0,
                  ),
                  child: Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
    );
  }

  // Responsive calculations based on number of items
  double _calculateNavHeight() {
    if (widget.items.length <= 4) return 80.h;
    if (widget.items.length <= 6) return 75.h;
    return 70.h; // For more than 6 items
  }

  double _getBorderRadius() {
    if (widget.items.length <= 4) return 30.r;
    if (widget.items.length <= 6) return 25.r;
    return 20.r; // For more than 6 items
  }

  double _getIconSize(bool isSelected) {
    final baseSize = widget.items.length <= 4
        ? 24.sp
        : widget.items.length <= 6
            ? 22.sp
            : 20.sp;
    return isSelected ? baseSize + 2.sp : baseSize;
  }

  double _getLabelFontSize(bool isSelected) {
    final baseSize = widget.items.length <= 4
        ? 11.sp
        : widget.items.length <= 6
            ? 10.sp
            : 9.sp;
    return isSelected ? baseSize + 0.5.sp : baseSize;
  }

  double _getLabelSpacing() {
    if (widget.items.length <= 4) return 4.h;
    if (widget.items.length <= 6) return 3.h;
    return 2.h; // For more than 6 items
  }

  double _getIndicatorHeight() {
    return _calculateNavHeight() - 20.h;
  }

  double _getIndicatorTopMargin() {
    return 10.h;
  }

  double _getIndicatorPosition(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final navWidth = screenWidth - 40.w; // Account for margins
    final itemWidth = navWidth / widget.items.length;
    return (itemWidth * widget.currentIndex) + 8.w;
  }

  double _getItemWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final navWidth = screenWidth - 40.w; // Account for margins
    final itemWidth = navWidth / widget.items.length;
    return itemWidth - 16.w; // Account for padding and spacing
  }
}
