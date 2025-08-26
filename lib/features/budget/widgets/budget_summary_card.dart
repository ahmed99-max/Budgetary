import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/budget_provider.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/widgets/liquid_card.dart';

class BudgetSummaryCard extends StatelessWidget {
  final UserModel user;
  final BudgetProvider budgetProvider;
  final ExpenseProvider expenseProvider;

  const BudgetSummaryCard({
    super.key,
    required this.user,
    required this.budgetProvider,
    required this.expenseProvider,
  });

  @override
  Widget build(BuildContext context) {
    final income = user.monthlyIncome;
    final totalAllocated = budgetProvider.totalAllocated;
    final totalSpent = budgetProvider.totalSpent;
    final totalRemaining = totalAllocated - totalSpent;
    final available = budgetProvider.getAvailableBudgetAmount(income);
    final percentUsed =
        totalAllocated > 0 ? (totalSpent / totalAllocated) * 100 : 0.0;
    final percentAlloc = income > 0 ? (totalAllocated / income) * 100 : 0.0;

    return LiquidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Overview',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 20.h),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isWide = constraints.maxWidth > 500;
              return GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                childAspectRatio: isWide ? 2.7 : 1.8,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                children: [
                  _metricCard(
                    'Total Allocated',
                    '${user.currency} ${NumberFormat('#,##0').format(totalAllocated)}',
                    '${percentAlloc.toStringAsFixed(1)}% of income',
                    AppTheme.primaryBlue,
                    Icons.account_balance_wallet_outlined,
                  ),
                  _metricCard(
                    'Total Spent',
                    '${user.currency} ${NumberFormat('#,##0').format(totalSpent)}',
                    '${percentUsed.toStringAsFixed(1)}% used',
                    AppTheme.primaryPink,
                    Icons.trending_down_rounded,
                  ),
                  _metricCard(
                    'Remaining',
                    '${user.currency} ${NumberFormat('#,##0').format(totalRemaining)}',
                    totalRemaining >= 0 ? 'Available' : 'Over budget',
                    totalRemaining >= 0 ? Colors.green : Colors.red,
                    totalRemaining >= 0
                        ? Icons.savings_outlined
                        : Icons.warning_rounded,
                  ),
                  _metricCard(
                    'To Allocate',
                    '${user.currency} ${NumberFormat('#,##0').format(available)}',
                    'Unallocated income',
                    AppTheme.primaryPurple,
                    Icons.add_circle_outline,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 20.h),
          Text(
            'Budget Utilization',
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700),
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: totalAllocated > 0
                  ? (totalSpent / totalAllocated).clamp(0.0, 1.0)
                  : 0,
              minHeight: 10.h,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(
                totalSpent > totalAllocated
                    ? Colors.red
                    : totalSpent > totalAllocated * 0.8
                        ? Colors.orange
                        : AppTheme.primaryPurple,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          _statusRow(percentUsed, totalAllocated, totalSpent),
        ],
      ),
    );
  }

  Widget _metricCard(
      String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 8.h),
          Text(value,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 4.h),
          Text(subtitle,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _statusRow(double percentUsed, double allocated, double spent) {
    final userColor = percentUsed >= 100
        ? Colors.red
        : percentUsed >= 80
            ? Colors.orange
            : Colors.green;
    final remaining = (allocated - spent).abs();
    final currency = user.currency;

    String message;
    if (percentUsed >= 100) {
      message = 'Over budget by $currency ${remaining.toStringAsFixed(0)}';
    } else if (percentUsed >= 80) {
      message = 'Close to limit—$currency ${remaining.toStringAsFixed(0)} left';
    } else {
      message = 'On track—$currency ${remaining.toStringAsFixed(0)} remaining';
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: userColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: userColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            percentUsed >= 100 ? Icons.error : Icons.check_circle,
            color: userColor,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(child: Text(message, style: TextStyle(color: userColor))),
        ],
      ),
    );
  }
}
