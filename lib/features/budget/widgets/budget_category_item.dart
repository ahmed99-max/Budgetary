// lib/features/budget/widgets/enhanced_budget_category_item.dart
// UPDATED VERSION: Shows Spent, Used %, Budget, and Remaining

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
  final VoidCallback onAddExpense; // Add this parameter

  const BudgetCategoryItem({
    super.key,
    required this.budget,
    required this.spent,
    required this.currency,
    required this.onDelete,
    required this.onAddExpense, // Make this required
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
          // Enhanced Header with Add Expense Button
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

              // Action Buttons Row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add Expense Button - NEW!
                  Container(
                    height: 36.h,
                    child: ElevatedButton.icon(
                      onPressed: onAddExpense,
                      icon: Icon(Icons.add, size: 14.sp),
                      label: Text(
                        'Add Expense',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Menu Button
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Colors.grey.shade600,
                      size: 20.sp,
                    ),
                    itemBuilder: (context) => [
                      if (onEdit != null)
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined,
                                  size: 16.sp, color: AppTheme.primaryBlue),
                              SizedBox(width: 8.w),
                              Text('Edit Budget'),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'view_expenses',
                        child: Row(
                          children: [
                            Icon(Icons.visibility,
                                size: 16.sp, color: Colors.green),
                            SizedBox(width: 8.w),
                            Text('View Expenses'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 16.sp, color: Colors.red),
                            SizedBox(width: 8.w),
                            Text('Delete Budget'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'view_expenses':
                          _showExpensesForCategory(context, budget.category);
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // NEW: Stats Row for Spent, Used %, Budget
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: progressColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: progressColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  'Spent',
                  '$currency ${NumberFormat('#,##0').format(spent)}',
                  Icons.trending_up,
                  progressColor,
                ),
                _buildStatItem(
                  'Used',
                  '${percentage.toStringAsFixed(1)}%',
                  Icons.pie_chart,
                  progressColor,
                ),
                _buildStatItem(
                  'Budget',
                  '$currency ${NumberFormat('#,##0').format(budget.allocatedAmount)}',
                  Icons.account_balance_wallet,
                  Colors.grey.shade700,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Enhanced Progress Bar
          Container(
            height: 12.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Stack(
              children: [
                // Background
                Container(
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                // Progress
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (percentage / 100).clamp(0.0, 1.0),
                  child: Container(
                    height: 12.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          progressColor,
                          progressColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Remaining Amount with enhanced styling
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    remaining >= 0 ? Icons.savings : Icons.warning,
                    size: 16.sp,
                    color: remaining >= 0 ? Colors.green : Colors.red,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    remaining >= 0 ? 'Remaining' : 'Over Budget',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (remaining >= 0 ? Colors.green : Colors.red)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: (remaining >= 0 ? Colors.green : Colors.red)
                        .withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '$currency ${NumberFormat('#,##0').format(remaining.abs())}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: remaining >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showExpensesForCategory(BuildContext context, String category) {
    // Navigate to expenses screen filtered by category
    // Implementation depends on your navigation structure
    Navigator.of(context)
        .pushNamed('/expenses', arguments: {'category': category});
  }
}
