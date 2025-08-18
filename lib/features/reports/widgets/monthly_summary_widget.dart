import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/liquid_card.dart';

class MonthlySummaryWidget extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final double totalBudget;
  final String currency;

  const MonthlySummaryWidget({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalBudget,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final savings = totalIncome - totalExpenses;
    final savingsRate = totalIncome > 0 ? (savings / totalIncome) * 100 : 0;

    return LiquidCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.25),
          Colors.white.withOpacity(0.15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Summary',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  DateFormat('MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Financial metrics in a grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 16.h,
            children: [
              _buildMetricItem(
                'Total Income',
                '$currency ${NumberFormat('#,##0').format(totalIncome)}',
                Icons.trending_up_rounded,
                Colors.greenAccent,
                0,
              ),
              _buildMetricItem(
                'Total Expenses',
                '$currency ${NumberFormat('#,##0').format(totalExpenses)}',
                Icons.trending_down_rounded,
                Colors.orangeAccent,
                100,
              ),
              _buildMetricItem(
                'Net Savings',
                '$currency ${NumberFormat('#,##0').format(savings)}',
                savings >= 0 ? Icons.savings_rounded : Icons.warning_rounded,
                savings >= 0 ? Colors.greenAccent : Colors.red,
                200,
              ),
              _buildMetricItem(
                'Savings Rate',
                '${savingsRate.toStringAsFixed(1)}%',
                Icons.pie_chart_rounded,
                AppTheme.primaryPurple,
                300,
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Progress indicator for budget vs expenses
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Budget Utilization',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    '${totalBudget > 0 ? ((totalExpenses / totalBudget) * 100).toStringAsFixed(1) : 0}%',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: LinearProgressIndicator(
                  value: totalBudget > 0
                      ? (totalExpenses / totalBudget).clamp(0.0, 1.0)
                      : 0,
                  minHeight: 8.h,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    totalExpenses > totalBudget
                        ? Colors.red
                        : totalExpenses > totalBudget * 0.8
                            ? Colors.orange
                            : Colors.white,
                  ),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 800.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
      String title, String value, IconData icon, Color color, int delay) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16.sp,
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8))
        .then()
        .shimmer(duration: 2000.ms, color: color.withOpacity(0.2));
  }
}
