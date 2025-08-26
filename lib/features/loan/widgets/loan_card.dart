// Updated lib/features/loan/widgets/loan_card.dart
// (Assuming this is the file; if named differently, apply changes there)
// Changed parameter from LoanModel to Loan
// Updated field accesses to match Loan getters (e.g., title instead of name, totalRemaining instead of remainingAmount)

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/providers/loan_provider.dart'; // Import Loan class

class LoanCard extends StatelessWidget {
  final Loan loan; // FIXED: Changed from LoanModel to Loan
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LoanCard({
    super.key,
    required this.loan,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        loan.completionPercentage / 100; // FIXED: Use completionPercentage
    final remaining = loan.totalRemaining; // FIXED: Use totalRemaining
    final total = loan.amount; // FIXED: Use amount

    return LiquidCard(
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.25),
          Colors.white.withOpacity(0.15),
        ],
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Text(
                  loan.title, // FIXED: Use title
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit, color: Colors.white70),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 8.h,
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _kv('Total', total),
              _kv('Remaining', remaining),
              Text(
                '${loan.remainingMonths} mo',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, double v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white70,
            )),
        SizedBox(height: 2.h),
        Text(
          v.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
