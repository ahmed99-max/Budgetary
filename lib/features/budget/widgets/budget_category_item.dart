import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/budget_model.dart';
import '../../../core/theme/app_theme.dart';

class BudgetCategoryItem extends StatelessWidget {
  final BudgetModel budget;
  final double spent;
  final String currency;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BudgetCategoryItem({
    super.key,
    required this.budget,
    required this.spent,
    required this.currency,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        budget.allocatedAmount > 0 ? spent / budget.allocatedAmount : 0;
    final isOverBudget = spent > budget.allocatedAmount;
    final remaining = budget.allocatedAmount - spent;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.category,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '$currency ${NumberFormat('#,##0').format(spent)} of ${NumberFormat('#,##0').format(budget.allocatedAmount)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      color: AppTheme.primaryPurple,
                      size: 20.sp,
                    ),
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0) as double,
              minHeight: 10.h,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget
                    ? Colors.red
                    : progress > 0.8
                        ? Colors.orange
                        : AppTheme.primaryPurple,
              ),
            ),
          ).animate().fadeIn(duration: 800.ms).slideX(begin: -1, end: 0),

          SizedBox(height: 8.h),

          // Status and remaining amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? Colors.red.withOpacity(0.1)
                      : progress > 0.8
                          ? Colors.orange.withOpacity(0.1)
                          : AppTheme.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  isOverBudget
                      ? 'Over Budget'
                      : progress > 0.8
                          ? 'Near Limit'
                          : 'On Track',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: isOverBudget
                        ? Colors.red
                        : progress > 0.8
                            ? Colors.orange
                            : AppTheme.primaryPurple,
                  ),
                ),
              ),
              Text(
                isOverBudget
                    ? 'Over by $currency ${NumberFormat('#,##0').format(-remaining)}'
                    : '$currency ${NumberFormat('#,##0').format(remaining)} left',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isOverBudget ? Colors.red : Colors.grey.shade600,
                ),
              ),
            ],
          ),

          if (budget != budget) // Add divider between items (except last)
            Container(
              margin: EdgeInsets.only(top: 16.h),
              height: 1.h,
              color: Colors.grey.shade200,
            ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0);
  }
}
