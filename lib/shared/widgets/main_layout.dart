import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import 'liquid_bottom_nav.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({
    super.key,
    required this.child,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.liquidBackground,
        ),
        child: widget.child
            .animate()
            .fadeIn(duration: 300.ms)
            .slideX(begin: 0.1, end: 0),
      ),
      bottomNavigationBar: LiquidBottomNav(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) {
          if (index != _currentIndex) {
            context.go(_navItems[index].route);
            setState(() {
              _currentIndex = index;
            });
          }
        },
      ),
    );
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
