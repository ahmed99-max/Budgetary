// lib/features/budget/widgets/loan_budget_category_item.dart
// BATCH 3: CREATE THIS NEW FILE

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/budget_model.dart';
import '../../../shared/providers/loan_provider.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';

class LoanBudgetCategoryItem extends StatelessWidget {
  final BudgetModel budget;
  final double spent;
  final String currency;
  final VoidCallback onAddExpense;
  final VoidCallback? onEdit;

  const LoanBudgetCategoryItem({
    super.key,
    required this.budget,
    required this.spent,
    required this.currency,
    required this.onAddExpense,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = budget.allocatedAmount > 0
        ? (spent / budget.allocatedAmount) * 100
        : 0.0;
    final remaining = budget.allocatedAmount - spent;

    return Consumer<LoanProvider>(
      builder: (context, loanProvider, _) {
        final activeLoans = loanProvider.activeLoans;

        return LiquidCard(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPurple.withOpacity(0.15),
              AppTheme.primaryBlue.withOpacity(0.1),
              Colors.orange.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Loan Icon
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryPurple.withOpacity(0.8),
                          AppTheme.primaryBlue.withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🏦 ${budget.category}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${activeLoans.length} active loans',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Add Expense Button
                  Container(
                    height: 36.h,
                    child: ElevatedButton.icon(
                      onPressed: onAddExpense,
                      icon: Icon(Icons.add, size: 16.sp),
                      label: Text(
                        'Add Payment',
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
                ],
              ),
              SizedBox(height: 16.h),

              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paid This Month',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '$currency ${NumberFormat('#,##0').format(spent)}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: percentage >= 100
                                ? Colors.green
                                : AppTheme.primaryPurple,
                          ),
                        ),
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Monthly Target',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '$currency ${NumberFormat('#,##0').format(budget.allocatedAmount)}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: LinearProgressIndicator(
                  value: (percentage / 100).clamp(0.0, 1.0),
                  minHeight: 8.h,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    percentage >= 100 ? Colors.green : AppTheme.primaryPurple,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Remaining Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    remaining >= 0 ? 'Remaining This Month' : 'Over Target',
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
                      color: remaining >= 0 ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),

              // Active Loans List
              if (activeLoans.isNotEmpty) ...[
                Text(
                  'Active Loans:',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: activeLoans.take(3).map((loan) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: AppTheme.primaryPurple.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        '${loan.title} - $currency ${NumberFormat('#,##0').format(loan.monthlyInstallment)}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (activeLoans.length > 3)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      '+${activeLoans.length - 3} more loans',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
