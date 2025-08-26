import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_card.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _currentQuoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _startQuoteRotation();
  }

  void _startQuoteRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentQuoteIndex =
              (_currentQuoteIndex + 1) % AppConfig.motivationalQuotes.length;
        });
        _startQuoteRotation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.liquidBackground),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 60.h),
                Container(
                  width: 280.w,
                  height: 280.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.05)
                    ]),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.savings_rounded,
                          size: 120.sp,
                          color: Colors.white,
                        )
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.1, 1.1),
                                duration: 2000.ms)
                            .then()
                            .scale(
                                begin: const Offset(1.1, 1.1),
                                end: const Offset(1, 1),
                                duration: 2000.ms),
                      ),
                      Positioned(
                        top: 40.h,
                        right: 40.w,
                        child: Icon(Icons.monetization_on,
                                size: 24.sp, color: Colors.amber)
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .moveY(begin: -10, end: 10, duration: 2000.ms)
                            .then()
                            .moveY(begin: 10, end: -10, duration: 2000.ms),
                      ),
                      Positioned(
                        bottom: 60.h,
                        left: 50.w,
                        child: Icon(Icons.attach_money,
                                size: 20.sp, color: Colors.greenAccent)
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .moveX(begin: -8, end: 8, duration: 1500.ms)
                            .then()
                            .moveX(begin: 8, end: -8, duration: 1500.ms),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 1000.ms)
                    .scale(begin: const Offset(0.8, 0.8))
                    .then()
                    .shimmer(
                        duration: 3000.ms,
                        color: Colors.white.withOpacity(0.2)),
                SizedBox(height: 40.h),
                Text(
                  'Welcome to\nYour Financial Future',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                    shadows: [
                      Shadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 8)
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 1000.ms)
                    .slideY(begin: 0.3, end: 0),
                SizedBox(height: 20.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    AppConfig.motivationalQuotes[_currentQuoteIndex],
                    key: ValueKey(_currentQuoteIndex),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4),
                  ),
                ).animate().fadeIn(delay: 800.ms, duration: 1000.ms),
                SizedBox(height: 60.h),
                LiquidCard(
                  gradient: LinearGradient(colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05)
                  ]),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                          Icons.dashboard_rounded,
                          'Smart Dashboard',
                          'Track your expenses with beautiful visualizations',
                          0),
                      SizedBox(height: 20.h),
                      _buildFeatureItem(
                          Icons.pie_chart_rounded,
                          'Budget Management',
                          'Set and monitor budgets by category',
                          200),
                      SizedBox(height: 20.h),
                      _buildFeatureItem(
                          Icons.analytics_rounded,
                          'Detailed Reports',
                          'Export and analyze your financial data',
                          400),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 1000.ms)
                    .slideY(begin: 0.3, end: 0),
                SizedBox(height: 40.h),
                Column(
                  children: [
                    LiquidButton(
                      text: 'Get Started',
                      gradient: LinearGradient(colors: [
                        Colors.greenAccent,
                        Colors.greenAccent.withOpacity(0.7)
                      ]), // NEW: Green for emphasis
                      onPressed: () => context.go('/signup'),
                      icon: Icons.rocket_launch_rounded,
                    )
                        .animate()
                        .fadeIn(delay: 1200.ms, duration: 800.ms)
                        .slideY(begin: 0.3, end: 0)
                        .scale(begin: Offset(0.9, 0.9), end: Offset(1, 1)),
                    SizedBox(height: 16.h),
                    LiquidButton(
                      text: 'Already have an account? Sign In',
                      isOutlined: true,
                      gradient: LinearGradient(colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.7)
                      ]),
                      onPressed: () => context.go('/login'),
                    )
                        .animate()
                        .fadeIn(delay: 1400.ms, duration: 800.ms)
                        .slideY(begin: 0.3, end: 0)
                        .scale(begin: Offset(0.9, 0.9), end: Offset(1, 1)),
                  ],
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      IconData icon, String title, String description, int delay) {
    return Row(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
              gradient: AppTheme.liquidBackground, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 24.sp),
        )
            .animate()
            .fadeIn(
                delay: Duration(milliseconds: 1200 + delay), duration: 600.ms)
            .scale(begin: const Offset(0.5, 0.5))
            .then()
            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              SizedBox(height: 4.h),
              Text(description,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8))),
            ],
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 1200 + delay), duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
  }
}
