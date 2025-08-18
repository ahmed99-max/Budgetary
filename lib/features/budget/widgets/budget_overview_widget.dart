import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/liquid_card.dart';

class BudgetOverviewWidget extends StatelessWidget {
  final double totalIncome;
  final double totalBudget;
  final double totalSpent;
  final String currency;

  const BudgetOverviewWidget({
    super.key,
    required this.totalIncome,
    required this.totalBudget,
    required this.totalSpent,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final remainingBudget = totalBudget - totalSpent;
    final budgetUsagePercentage =
        totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;

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
          Text(
            'Budget Overview',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),

          // Budget Progress Circle
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120.w,
                  height: 120.w,
                  child: CircularProgressIndicator(
                    value: (budgetUsagePercentage / 100).clamp(0.0, 1.0),
                    strokeWidth: 8.w,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budgetUsagePercentage > 100
                          ? Colors.red
                          : budgetUsagePercentage > 80
                              ? Colors.orange
                              : Colors.white,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${budgetUsagePercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Used',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate()
              .scale(begin: const Offset(0.8, 0.8))
              .then()
              .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.2)),

          SizedBox(height: 30.h),

          // Budget Statistics
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Budget',
                  '$currency ${NumberFormat('#,##0').format(totalBudget)}',
                  Colors.white,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Spent',
                  '$currency ${NumberFormat('#,##0').format(totalSpent)}',
                  budgetUsagePercentage > 100 ? Colors.red : Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Remaining',
                  '$currency ${NumberFormat('#,##0').format(remainingBudget)}',
                  remainingBudget >= 0 ? Colors.greenAccent : Colors.red,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Income',
                  '$currency ${NumberFormat('#,##0').format(totalIncome)}',
                  Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
