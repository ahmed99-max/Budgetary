import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/widgets/liquid_card.dart';

class SpendingInsightsWidget extends StatelessWidget {
  final ExpenseProvider expenseProvider;
  final String currency;

  const SpendingInsightsWidget({
    super.key,
    required this.expenseProvider,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final categoryTotals = expenseProvider.sortedCategoryTotals;
    final topCategory = categoryTotals.isNotEmpty ? categoryTotals.first : null;

    return LiquidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Insights',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16.h),
          if (topCategory != null) ...[
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryPurple.withOpacity(0.1),
                    AppTheme.primaryBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                border:
                    Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppTheme.primaryPurple,
                        size: 20.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Top Spending Category',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        topCategory.key,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        '$currency ${NumberFormat('#,##0').format(topCategory.value)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            if (categoryTotals.length > 1)
              Column(
                children: categoryTotals.skip(1).take(3).map((entry) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '$currency ${NumberFormat('#,##0').format(entry.value)}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ] else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 100.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.insights_outlined,
              size: 40.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 8.h),
            Text(
              'No insights available yet',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
