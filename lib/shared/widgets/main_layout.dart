// lib/shared/widgets/enhanced_main_layout.dart
// BATCH 5: REPLACE THE EXISTING main_layout.dart WITH THIS VERSION

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import 'modern_bottom_nav.dart';
import 'liquid_bottom_nav.dart';

enum NavigationStyle {
  modern,
  original,
}

class MainLayout extends StatefulWidget {
  final Widget child;
  final NavigationStyle navigationStyle; // Add this parameter

  const MainLayout({
    super.key,
    required this.child,
    this.navigationStyle = NavigationStyle.modern, // Default to modern
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _pageTransitionController;
  late Animation<Offset> _pageSlideAnimation;

  final List<NavItem> _navItems = [
    NavItem(
      icon: Icons.dashboard_rounded,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    NavItem(
      icon: Icons.wallet_travel_outlined,
      label: 'Expense',
      route: '/expenses',
    ),
    NavItem(
      icon: Icons.pie_chart_rounded,
      label: 'Budget',
      route: '/budget',
    ),
    NavItem(
      icon: Icons.analytics_rounded,
      label: 'Reports',
      route: '/reports',
    ),
    NavItem(
      icon: Icons.person_rounded,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pageTransitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pageSlideAnimation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _pageTransitionController,
      curve: Curves.easeInOutCubic,
    ));

    _pageTransitionController.forward();
  }

  @override
  void dispose() {
    _pageTransitionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCurrentIndex();
  }

  void _updateCurrentIndex() {
    final location = GoRouterState.of(context).uri.path;
    final index = _navItems.indexWhere((item) => item.route == location);
    if (index != -1 && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _pageTransitionController.reset();
      _pageTransitionController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.liquidBackground,
        ),
        child: AnimatedBuilder(
          animation: _pageSlideAnimation,
          builder: (context, child) {
            return SlideTransition(
              position: _pageSlideAnimation,
              child: FadeTransition(
                opacity: _pageTransitionController,
                child: widget.child,
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
      extendBody: true, // Allow content to extend behind navigation
    );
  }

  Widget _buildBottomNavigation() {
    switch (widget.navigationStyle) {
      case NavigationStyle.modern:
        return ModernBottomNav(
          currentIndex: _currentIndex,
          items: _navItems,
          onTap: _onNavTap,
        );
      case NavigationStyle.original:
        return LiquidBottomNav(
          // Your original navigation
          currentIndex: _currentIndex,
          items: _navItems,
          onTap: _onNavTap,
        );
    }
  }

  void _onNavTap(int index) {
    if (index != _currentIndex) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      // Navigation
      context.go(_navItems[index].route);

      // Update state
      setState(() {
        _currentIndex = index;
      });

      // Trigger page transition animation
      _pageTransitionController.reset();
      _pageTransitionController.forward();
    }
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final String route;

  NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });
}
