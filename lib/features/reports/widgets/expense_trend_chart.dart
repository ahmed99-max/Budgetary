// lib/features/reports/widgets/expense_trend_chart.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/expense_model.dart';
import '../../../core/theme/app_theme.dart';

class ExpenseTrendChart extends StatefulWidget {
  final List<ExpenseModel> expenses;

  const ExpenseTrendChart({
    super.key,
    required this.expenses,
  });

  @override
  State<ExpenseTrendChart> createState() => _ExpenseTrendChartState();
}

class _ExpenseTrendChartState extends State<ExpenseTrendChart> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.expenses.isEmpty) {
      return _buildEmptyState();
    }

    final dailyExpenses = <DateTime, double>{};
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    // Initialize all days with 0
    for (int i = 0; i < endOfMonth.day; i++) {
      final date = DateTime(now.year, now.month, i + 1);
      dailyExpenses[date] = 0.0;
    }

    // Add actual expenses
    for (final expense in widget.expenses) {
      if (expense.date
              .isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(endOfMonth.add(const Duration(days: 1)))) {
        final date =
            DateTime(expense.date.year, expense.date.month, expense.date.day);
        dailyExpenses[date] = (dailyExpenses[date] ?? 0) + expense.amount;
      }
    }

    final sortedDates = dailyExpenses.keys.toList()..sort();
    final spots = sortedDates.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), dailyExpenses[entry.value]!);
    }).toList();

    final maxY = dailyExpenses.values.isNotEmpty
        ? dailyExpenses.values.reduce((a, b) => a > b ? a : b) * 1.2
        : 100.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              drawHorizontalLine: true,
              verticalInterval: isSmallScreen ? 5 : 3,
              horizontalInterval: maxY / 5,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
                dashArray: [5, 5],
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: isSmallScreen ? 50.w : 60.w,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Text(
                        '\$${(value / 1000).toStringAsFixed(0)}k',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 9.sp : 10.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                  interval: maxY / 5,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: isSmallScreen ? 25.h : 30.h,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 &&
                        value.toInt() < sortedDates.length) {
                      final date = sortedDates[value.toInt()];
                      final shouldShow =
                          isSmallScreen ? value % 5 == 0 : value % 3 == 0;

                      if (shouldShow) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 9.sp : 10.sp,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            minX: 0,
            maxX: (sortedDates.length - 1).toDouble(),
            minY: 0,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.35,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPurple,
                    AppTheme.primaryBlue,
                    AppTheme.primaryPink,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
                barWidth: isSmallScreen ? 3 : 4,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    final isSelected = _selectedIndex == index;
                    return FlDotCirclePainter(
                      radius: isSelected ? 8 : 5,
                      color: Colors.white,
                      strokeWidth: 2.5,
                      strokeColor: isSelected
                          ? AppTheme.primaryPink
                          : AppTheme.primaryPurple,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryPurple.withOpacity(0.4),
                      AppTheme.primaryBlue.withOpacity(0.2),
                      AppTheme.primaryPink.withOpacity(0.1),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.3, 0.7, 1.0],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              touchCallback: (event, response) {
                if (event is FlTapUpEvent) {
                  setState(() {
                    _selectedIndex =
                        response?.lineBarSpots?.first.spotIndex ?? -1;
                  });
                }
              },
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: Colors.white.withOpacity(0.95),
                tooltipRoundedRadius: 12.r,
                tooltipPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                tooltipMargin: 16,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final date = sortedDates[spot.x.toInt()];
                    return LineTooltipItem(
                      '${DateFormat('MMM d').format(date)}\n\$${NumberFormat('#,##0.00').format(spot.y)}',
                      TextStyle(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    );
                  }).toList();
                },
              ),
              getTouchedSpotIndicator: (barData, spotIndexes) {
                return spotIndexes.map((index) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: AppTheme.primaryPurple.withOpacity(0.8),
                      strokeWidth: 2,
                      dashArray: [3, 3],
                    ),
                    FlDotData(
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: 8,
                        color: Colors.white,
                        strokeWidth: 3,
                        strokeColor: AppTheme.primaryPurple,
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          ),
        )
            .animate()
            .fadeIn(duration: 1200.ms, curve: Curves.easeOutCubic)
            .slideY(begin: 0.3, end: 0)
            .then()
            .shimmer(
              duration: 2000.ms,
              color: AppTheme.primaryPurple.withOpacity(0.1),
            );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade300,
                    Colors.grey.shade200,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.trending_up_rounded,
                size: 40.sp,
                color: Colors.grey.shade500,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.2, 1.2),
                  duration: 2000.ms,
                )
                .then()
                .scale(
                  begin: const Offset(1.2, 1.2),
                  end: const Offset(0.8, 0.8),
                  duration: 2000.ms,
                ),
            SizedBox(height: 16.h),
            Text(
              'No expense data yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start tracking your expenses to see trends',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0);
  }
}
