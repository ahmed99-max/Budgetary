import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/budget_provider.dart';
import '../../../shared/widgets/liquid_card.dart';

class BalanceOverviewCard extends StatelessWidget {
  final UserModel user;
  final double totalExpenses;
  final BudgetProvider budgetProvider;

  const BalanceOverviewCard({
    super.key,
    required this.user,
    required this.totalExpenses,
    required this.budgetProvider,
  });

  @override
  Widget build(BuildContext context) {
    final income = user.monthlyIncome;
    final balance = income - totalExpenses;
    final spentPercent =
        income > 0 ? (totalExpenses / income).clamp(0.0, 1.0) : 0.0;

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
            'Balance Overview',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Balance',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${user.currency} ${NumberFormat('#,##0').format(balance)}',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              CircularPercentIndicator(
                radius: 48.w,
                lineWidth: 8.w,
                percent: spentPercent,
                backgroundColor: Colors.white.withOpacity(0.15),
                progressColor: spentPercent >= 0.95
                    ? Colors.red
                    : spentPercent >= 0.75
                        ? Colors.orange
                        : Colors.greenAccent,
                circularStrokeCap: CircularStrokeCap.round,
                center: Text(
                  '${(spentPercent * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                  child: _buildStat(
                      'Income', income, Icons.trending_up, Colors.greenAccent)),
              SizedBox(width: 12.w),
              Expanded(
                  child: _buildStat('Expenses', totalExpenses,
                      Icons.trending_down, Colors.orangeAccent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, double value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 8.w),
          Column(
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
                '${user.currency} ${NumberFormat('#,##0').format(value)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
