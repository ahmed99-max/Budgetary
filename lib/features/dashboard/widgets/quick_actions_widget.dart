import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/liquid_card.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildActionItem(
                  context,
                  'Add Expense',
                  Icons.add_circle_outline,
                  AppTheme.primaryPink,
                  () => context.go('/expenses'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionItem(
                  context,
                  'View Budget',
                  Icons.pie_chart_outline,
                  AppTheme.primaryBlue,
                  () => context.go('/budget'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionItem(
                  context,
                  'Reports',
                  Icons.analytics_outlined,
                  AppTheme.primaryPurple,
                  () => context.go('/reports'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .scale(begin: const Offset(0.9, 0.9))
        .then()
        .shimmer(duration: 2000.ms, color: color.withOpacity(0.1));
  }
}
