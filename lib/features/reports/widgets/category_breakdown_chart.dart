import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';

class CategoryBreakdownChart extends StatelessWidget {
  final Map<String, double> expenses;
  final String currency;

  const CategoryBreakdownChart({
    super.key,
    required this.expenses,
    required this.currency,
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
                'No category data yet',
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

    final sortedExpenses = expenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = expenses.values.fold<double>(0, (sum, value) => sum + value);

    return Container(
      height: 300.h,
      child: Column(
        children: [
          // Bar chart
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: sortedExpenses.first.value * 1.2,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60.w,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '$currency${value.toInt()}',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40.h,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < sortedExpenses.length) {
                          final category = sortedExpenses[value.toInt()].key;
                          return Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              category.length > 8
                                  ? category.substring(0, 8)
                                  : category,
                              style: TextStyle(
                                fontSize: 9.sp,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barGroups: sortedExpenses.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value,
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            _getCategoryColor(entry.key),
                            _getCategoryColor(entry.key).withOpacity(0.7),
                          ],
                        ),
                        width: 20.w,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ],
                  );
                }).toList(),
              ),
            )
                .animate()
                .fadeIn(duration: 1000.ms)
                .slideY(begin: 0.5, end: 0)
                .then()
                .shimmer(
                    duration: 2000.ms, color: Colors.white.withOpacity(0.1)),
          ),

          SizedBox(height: 20.h),

          // Category list with percentages
          ...sortedExpenses.take(5).map((entry) {
            final percentage = (entry.value / total) * 100;
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(sortedExpenses.indexOf(entry)),
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
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '$currency ${NumberFormat('#,##0').format(entry.value)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(
                    delay: Duration(
                        milliseconds: 200 * sortedExpenses.indexOf(entry)))
                .slideX(begin: 0.3, end: 0);
          }).toList(),
        ],
      ),
    );
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
