// lib/features/reports/widgets/category_breakdown_chart.dart
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
      ..sort((a, b) =>
          b.value.compareTo(a.value)); // Ensure compareTo for int return
    final total = expenses.values
        .fold(0.0, (sum, value) => sum + value); // Use double for sum

    return Container(
      height: 300.h,
      child: Column(
        children: [
          // Bar chart with enhanced styling
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: sortedExpenses.first.value * 1.2,
                barTouchData: BarTouchData(
                  enabled: true, // Enhanced: Enable touch for tooltips
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final category = sortedExpenses[group.x.toInt()].key;
                      final value = rod.toY;
                      return BarTooltipItem(
                        '$category\n$currency${value.toStringAsFixed(0)}',
                        TextStyle(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
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
                borderData: FlBorderData(
                  show: true, // Enhanced: Subtle border
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
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
                        borderRadius: BorderRadius.circular(
                            8.r), // Rounded bars for appeal
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: sortedExpenses.first.value * 1.2,
                          color:
                              Colors.grey.withOpacity(0.1), // Subtle background
                        ),
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
          // Enhanced: Added legend for categories
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: sortedExpenses.take(5).map((entry) {
              final percentage = (entry.value / total) * 100;
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(width: 8.w),
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
          ),
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
