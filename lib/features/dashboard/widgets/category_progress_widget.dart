import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/budget_model.dart';
import '../../../core/theme/app_theme.dart';

class CategoryProgressWidget extends StatelessWidget {
  final List<BudgetModel> budgets;
  final Map<String, double> expenses;
  final String currency;

  const CategoryProgressWidget({
    super.key,
    required this.budgets,
    required this.expenses,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    if (budgets.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 48.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 12.h),
              Text(
                'No budgets set yet',
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

    return Column(
      children: budgets.take(4).map((budget) {
        final spent = expenses[budget.category] ?? 0;
        final progress =
            budget.allocatedAmount > 0 ? spent / budget.allocatedAmount : 0;
        final isOverBudget = spent > budget.allocatedAmount;

        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    budget.category,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    '$currency ${NumberFormat('#,##0').format(spent)} / ${NumberFormat('#,##0').format(budget.allocatedAmount)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isOverBudget ? Colors.red : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0) as double,
                  minHeight: 8.h,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget
                        ? Colors.red
                        : progress > 0.8
                            ? Colors.orange
                            : AppTheme.primaryPurple,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              if (isOverBudget)
                Text(
                  'Over budget by $currency ${NumberFormat('#,##0').format(spent - budget.allocatedAmount)}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                )
              else
                Text(
                  '${((1 - progress) * 100).toStringAsFixed(0)}% remaining',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
        )
            .animate()
            .fadeIn(
                delay: Duration(milliseconds: 200 * budgets.indexOf(budget)))
            .slideX(begin: 0.3, end: 0);
      }).toList(),
    );
  }
}
