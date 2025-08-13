import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      body: child,
      bottomNavigationBar: NeumorphicBottomNavigation(),
    );
  }
}

class NeumorphicBottomNavigation extends StatefulWidget {
  @override
  _NeumorphicBottomNavigationState createState() =>
      _NeumorphicBottomNavigationState();
}

class _NeumorphicBottomNavigationState
    extends State<NeumorphicBottomNavigation> {
  int _currentIndex = 0;

  final List<BottomNavItem> _items = [
    BottomNavItem(
        icon: Icons.dashboard, label: 'Dashboard', route: '/dashboard'),
    BottomNavItem(
        icon: Icons.receipt_long, label: 'Expenses', route: '/expenses'),
    BottomNavItem(icon: Icons.savings, label: 'Budget', route: '/budget'),
    BottomNavItem(icon: Icons.analytics, label: 'Reports', route: '/reports'),
    BottomNavItem(icon: Icons.person, label: 'Profile', route: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        )),
        depth: -8,
        intensity: 0.8,
      ),
      child: Container(
        height: 80.h + MediaQuery.of(context).padding.bottom,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = _currentIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() => _currentIndex = index);
                context.go(item.route);
              },
              child: Neumorphic(
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape: NeumorphicBoxShape.circle(),
                  depth: isSelected ? -4 : 2,
                  intensity: 0.6,
                  color: isSelected ? Color(0xFF6C7CE7).withOpacity(0.1) : null,
                ),
                child: Container(
                  width: 50.w,
                  height: 50.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected
                            ? Color(0xFF6C7CE7)
                            : NeumorphicTheme.defaultTextColor(context)
                                ?.withOpacity(0.6),
                        size: 24.sp,
                      ),
                      if (isSelected) ...[
                        SizedBox(height: 2.h),
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6C7CE7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final String label;
  final String route;

  BottomNavItem({required this.icon, required this.label, required this.route});
}
