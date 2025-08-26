// lib/features/dashboard/widgets/loan_overview_card.dart

import 'package:budgetary/shared/providers/loan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/liquid_card.dart';

class LoanOverviewCard extends StatelessWidget {
  final VoidCallback? onViewDetails; // navigate to Budget > Loans

  const LoanOverviewCard({super.key, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    final loans = context.watch<LoanProvider>().loans;
    final totalOutstanding = loans.fold(
        0.0, (s, l) => s + l.totalRemaining); // FIXED: Use totalRemaining
    final avgProgress = loans.isEmpty
        ? 0.0
        : loans.map((l) => l.completionPercentage).reduce((a, b) => a + b) /
            loans.length; // FIXED: Use completionPercentage

    return LiquidCard(
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.25),
          Colors.white.withOpacity(0.15),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Loans Overview',
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stat('Active', loans.length.toString()),
              _stat('Outstanding', totalOutstanding.toStringAsFixed(2)),
              _stat('Avg. Progress',
                  '${(avgProgress * 100).toStringAsFixed(0)}%'), // FIXED: Null-safe
            ],
          ),
          if (onViewDetails != null) ...[
            SizedBox(height: 8.h),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onViewDetails,
                child: const Text('View details'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stat(String k, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: TextStyle(color: Colors.white70, fontSize: 11.sp)),
          SizedBox(height: 2.h),
          Text(v,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700)),
        ],
      );
}
