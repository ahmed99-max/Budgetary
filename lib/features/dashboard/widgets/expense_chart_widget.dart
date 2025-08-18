import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../shared/models/expense_model.dart';
import '../../../core/theme/app_theme.dart';

class ExpenseChartWidget extends StatelessWidget {
  final List<ExpenseModel> expenses;

  const ExpenseChartWidget({
    super.key,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Container(
        height: 200.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 48.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 12.h),
              Text(
                'No expenses yet',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final categoryTotals = <String, double>{};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      height: 250.h,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40.r,
                sections: _buildPieChartSections(sortedCategories),
                pieTouchData: PieTouchData(enabled: true),
              ),
            )
                .animate()
                .fadeIn(duration: 1000.ms)
                .scale(begin: const Offset(0.8, 0.8))
                .then()
                .shimmer(
                    duration: 2000.ms, color: Colors.white.withOpacity(0.1)),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: sortedCategories.take(5).map((entry) {
                final color =
                    _getCategoryColor(sortedCategories.indexOf(entry));
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(
                        delay: Duration(
                            milliseconds:
                                200 * sortedCategories.indexOf(entry)))
                    .slideX(begin: 0.3, end: 0);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
      List<MapEntry<String, double>> categories) {
    final total = categories.fold<double>(0, (sum, entry) => sum + entry.value);

    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final percentage = (category.value / total) * 100;

      return PieChartSectionData(
        color: _getCategoryColor(index),
        value: category.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 60.r,
        titleStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(int index) {
    final colors = [
      AppTheme.primaryPurple,
      AppTheme.primaryPink,
      AppTheme.primaryBlue,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.tealAccent,
      Colors.purpleAccent,
      Colors.cyanAccent,
    ];
    return colors[index % colors.length];
  }
}
