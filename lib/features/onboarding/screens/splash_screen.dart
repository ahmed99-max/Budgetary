// lib/features/onboarding/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated) {
      if (authProvider.hasCompletedProfileSetup) {
        context.go('/dashboard');
      } else {
        context.go('/profile-setup');
      }
    } else {
      context.go('/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.liquidBackground,
        ),
        child: Stack(
          children: [
            // Floating liquid shapes
            Positioned(
              top: -100.h,
              left: -50.w,
              child: Container(
                width: 300.w,
                height: 300.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 4000.ms,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1, 1),
                    duration: 4000.ms,
                  ),
            ),
            Positioned(
              bottom: -150.h,
              right: -100.w,
              child: Container(
                width: 400.w,
                height: 400.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPink.withOpacity(0.1),
                      AppTheme.primaryBlue.withOpacity(0.05),
                    ],
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .rotate(duration: 20000.ms),
            ),
            // Main content (fixed overflow with scroll and constrain)
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Logo with liquid animation
                        Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white, Colors.white70],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 60.sp,
                            color: AppTheme.primaryPurple,
                          ),
                        )
                            .animate()
                            .scale(duration: 1000.ms, curve: Curves.elasticOut)
                            .then(delay: 500.ms)
                            .shimmer(
                                duration: 2000.ms,
                                color: Colors.white.withOpacity(0.5))
                            .then()
                            .shake(hz: 1, curve: Curves.easeInOutCubic),
                        SizedBox(height: 40.h),
                        // App Name
                        Text(
                          'Budgetary',
                          style: TextStyle(
                            fontSize: 42.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 800.ms, duration: 1000.ms)
                            .slideY(begin: 0.3, end: 0)
                            .then()
                            .shimmer(
                                duration: 3000.ms,
                                color: Colors.white.withOpacity(0.3)),
                        SizedBox(height: 16.h),
                        // Tagline
                        Text(
                          'Smart Financial Management',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 1200.ms, duration: 1000.ms)
                            .slideY(begin: 0.3, end: 0),
                        SizedBox(height: 80.h),
                        // Loading indicator
                        Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        )
                            .animate(
                                onPlay: (controller) => controller.repeat())
                            .rotate(duration: 2000.ms)
                            .then()
                            .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.1, 1.1),
                                duration: 1000.ms)
                            .then()
                            .scale(
                                begin: const Offset(1.1, 1.1),
                                end: const Offset(1, 1),
                                duration: 1000.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
