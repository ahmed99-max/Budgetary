import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Track Your Expenses",
      description:
          "Easily monitor your daily spending with our intuitive expense tracking system",
      icon: Icons.analytics,
      color: Color(0xFF6C7CE7),
    ),
    OnboardingPage(
      title: "Smart Budgeting",
      description:
          "Set intelligent budgets and get insights to help you save more money",
      icon: Icons.savings,
      color: Color(0xFF27AE60),
    ),
    OnboardingPage(
      title: "Financial Reports",
      description:
          "Get detailed analytics and reports to understand your spending patterns",
      icon: Icons.assessment,
      color: Color(0xFFE67E22),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budgetary',
                    style: GoogleFonts.inter(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: NeumorphicTheme.defaultTextColor(context),
                    ),
                  ),
                  NeumorphicButton(
                    onPressed: () => context.go('/login'),
                    style: NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.roundRect(
                          BorderRadius.circular(20.r)),
                      depth: 2,
                      intensity: 0.8,
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: NeumorphicTheme.defaultTextColor(context)),
                    ),
                  ),
                ],
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),

            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _currentPage == index ? 20.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Color(0xFF6C7CE7)
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ).animate().scale(duration: 300.ms),
              ),
            ),

            SizedBox(height: 40.h),

            // Action buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: NeumorphicButton(
                        onPressed: () => _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut),
                        style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(12.r)),
                          depth: 4,
                          intensity: 0.8,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Text('Previous',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color:
                                    NeumorphicTheme.defaultTextColor(context))),
                      ),
                    ),
                  if (_currentPage > 0) SizedBox(width: 16.w),
                  Expanded(
                    child: NeumorphicButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        } else {
                          context.go('/login');
                        }
                      },
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12.r)),
                        depth: 4,
                        intensity: 0.8,
                        color: Color(0xFF6C7CE7),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Text(
                        _currentPage < _pages.length - 1
                            ? 'Next'
                            : 'Get Started',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Neumorphic(
            style: NeumorphicStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.circle(),
              depth: 8,
              intensity: 0.8,
              color: page.color.withOpacity(0.1),
            ),
            child: Container(
              width: 120.w,
              height: 120.w,
              child: Icon(page.icon, size: 60.sp, color: page.color),
            ),
          ).animate().scale(duration: 600.ms).fadeIn(),

          SizedBox(height: 60.h),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: NeumorphicTheme.defaultTextColor(context)),
          )
              .animate()
              .slideY(duration: 600.ms, begin: 0.3)
              .fadeIn(delay: 200.ms),

          SizedBox(height: 20.h),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color:
                    NeumorphicTheme.defaultTextColor(context)?.withOpacity(0.7),
                height: 1.5),
          )
              .animate()
              .slideY(duration: 600.ms, begin: 0.3)
              .fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage(
      {required this.title,
      required this.description,
      required this.icon,
      required this.color});
}
