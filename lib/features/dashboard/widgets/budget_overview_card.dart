// lib/features/dashboard/widgets/budget_overview_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/budget_provider.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/widgets/liquid_card.dart';

class BudgetOverviewCard extends StatelessWidget {
  final BudgetProvider budgetProvider;
  final ExpenseProvider expenseProvider;
  final String currency;

  const BudgetOverviewCard({
    super.key,
    required this.budgetProvider,
    required this.expenseProvider,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    // Get sorted category totals by spent amount (descending)
    final sortedCategorySpending = expenseProvider.sortedCategoryTotals;
    final budgets = budgetProvider.budgets;

    return LiquidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget Overview 📊',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: AppTheme.liquidBackground,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'This Month',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (budgets.isEmpty && sortedCategorySpending.isEmpty)
            _buildEmptyState()
          else
            _buildBudgetContent(sortedCategorySpending, budgets),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120.h,
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
              'No budget data yet',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Start tracking your expenses',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetContent(
      List<MapEntry<String, double>> sortedCategorySpending, List budgets) {
    return Column(
      children: [
        // Budget summary stats
        Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Total Allocated',
                '$currency ${NumberFormat('#,##0').format(budgetProvider.totalAllocated)}',
                AppTheme.primaryBlue,
                Icons.account_balance_wallet_outlined,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildSummaryItem(
                'Total Spent',
                '$currency ${NumberFormat('#,##0').format(budgetProvider.totalSpent)}',
                AppTheme.primaryPink,
                Icons.trending_down_rounded,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Categories sorted by spending (descending)
        if (sortedCategorySpending.isNotEmpty) ...[
          Text(
            'Categories by Spending',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12.h),
          Column(
            children: sortedCategorySpending.take(5).map((entry) {
              final category = entry.key;
              final spent = entry.value;
              final budget = budgetProvider.getBudgetByCategory(category);
              final allocated = budget?.allocatedAmount ?? 0.0;
              final percentage =
                  allocated > 0 ? (spent / allocated) * 100 : 0.0;
              // In _buildBudgetContent, add checks:
              final percentUsed =
                  allocated > 0 ? (spent / allocated) * 100 : 0.0;

              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                child: _buildBudgetItem(category, spent, allocated, percentage),
              );
            }).toList(),
          ),
        ] else if (budgets.isNotEmpty) ...[
          // Show budgets even if no spending yet
          Text(
            'Budget Categories',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 12.h),

          Column(
            children: budgets.take(5).map((budget) {
              final spent =
                  expenseProvider.categoryTotals[budget.category] ?? 0.0;
              final percentage = budget.allocatedAmount > 0
                  ? (spent / budget.allocatedAmount) * 100
                  : 0.0;

              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                child: _buildBudgetItem(
                    budget.category, spent, budget.allocatedAmount, percentage),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryItem(
      String label, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetItem(
      String category, double spent, double allocated, double percentage) {
    Color progressColor;
    if (percentage >= 90) {
      progressColor = Colors.red;
    } else if (percentage >= 75) {
      progressColor = Colors.orange;
    } else {
      progressColor = AppTheme.primaryPurple;
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: progressColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currency ${NumberFormat('#,##0').format(spent)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                'of $currency ${NumberFormat('#,##0').format(allocated)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 6.h,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.3, end: 0);
  }
}
