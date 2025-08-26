import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/budget_model.dart';
import '../../../shared/widgets/liquid_card.dart';

class BudgetCategoryItem extends StatelessWidget {
  final BudgetModel budget;
  final double spent;
  final String currency;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const BudgetCategoryItem({
    super.key,
    required this.budget,
    required this.spent,
    required this.currency,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = budget.allocatedAmount > 0
        ? (spent / budget.allocatedAmount) * 100
        : 0.0;
    final remaining = budget.allocatedAmount - spent;

    Color progressColor;
    if (percentage >= 100) {
      progressColor = Colors.red;
    } else if (percentage >= 80) {
      progressColor = Colors.orange;
    } else {
      progressColor = AppTheme.primaryPurple;
    }

    return LiquidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      budget.period,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(
                        Icons.edit_outlined,
                        color: AppTheme.primaryBlue,
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
          SizedBox(height: 16.h),
          // Replace Row with:
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                // Use Expanded instead of Flexible for better spacing
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Spent',
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.grey.shade600)),
                    Text('$currency ${NumberFormat('#,##0').format(spent)}',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: progressColor),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: progressColor)),
                    Text('Used',
                        style: TextStyle(
                            fontSize: 10.sp, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Budget',
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.grey.shade600)),
                    Text(
                        '$currency ${NumberFormat('#,##0').format(budget.allocatedAmount)}',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 8.h,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(progressColor),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                remaining >= 0 ? 'Remaining' : 'Over Budget',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '$currency ${NumberFormat('#,##0').format(remaining.abs())}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: remaining >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
