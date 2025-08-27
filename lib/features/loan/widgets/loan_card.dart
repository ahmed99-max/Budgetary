// lib/features/loan/widgets/loan_card.dart
// FIXED VERSION

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../features/loan/models/loan_model.dart'; // Changed from Loan to LoanModel
import '../../../shared/widgets/liquid_card.dart';

class LoanCard extends StatelessWidget {
  final LoanModel loan; // Fixed: Changed from Loan to LoanModel
  final String currency;
  final VoidCallback? onTap;

  const LoanCard({
    super.key,
    required this.loan,
    required this.currency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: LiquidCard(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple.withValues(
                alpha: 0.8), // Fixed: use withValues instead of withOpacity
            AppTheme.primaryBlue.withValues(
                alpha: 0.6), // Fixed: use withValues instead of withOpacity
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 12.h),
              _buildProgress(),
              SizedBox(height: 12.h),
              _buildStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2), // Fixed: use withValues
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.account_balance,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loan.name,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                loan.status,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white
                      .withValues(alpha: 0.8), // Fixed: use withValues
                ),
              ),
            ],
          ),
        ),
        Text(
          '${loan.progressPercentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 8.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3), // Fixed: use withValues
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: loan.progress,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${loan.monthsElapsed} completed',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white
                    .withValues(alpha: 0.8), // Fixed: use withValues
              ),
            ),
            Text(
              '${loan.remainingMonths} remaining',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white
                    .withValues(alpha: 0.8), // Fixed: use withValues
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatItem(
          'EMI',
          '$currency ${NumberFormat('#,##0').format(loan.emiAmount)}',
        ),
        _buildStatItem(
          'Remaining',
          '$currency ${NumberFormat('#,##0').format(loan.remainingAmount)}',
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white.withValues(alpha: 0.8), // Fixed: use withValues
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
