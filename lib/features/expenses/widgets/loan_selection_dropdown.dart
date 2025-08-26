import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/loan_provider.dart';
import '../../../core/theme/app_theme.dart';

class LoanSelectionDropdown extends StatelessWidget {
  final String? selectedLoanId;
  final ValueChanged<String?> onLoanSelected;
  final String currency; // NEW: Required parameter for currency symbol

  const LoanSelectionDropdown({
    Key? key,
    this.selectedLoanId,
    required this.onLoanSelected,
    required this.currency,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LoanProvider>(
      builder: (context, loanProvider, child) {
        final activeLoans =
            loanProvider.loans.where((loan) => !loan.isCompleted).toList();

        if (activeLoans.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              'No active loans available. Add one from Budget screen.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14.sp,
              ),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Loan to Pay',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                value: selectedLoanId,
                decoration: InputDecoration(
                  hintText: 'Choose a loan for this payment',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                ),
                items: activeLoans.map((loan) {
                  return DropdownMenuItem<String>(
                    value: loan.id,
                    child: Row(
                      children: [
                        Icon(Icons.account_balance,
                            size: 20.sp, color: AppTheme.primaryPurple),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loan.title,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Remaining: $currency ${NumberFormat('#,##0').format(loan.totalRemaining)}',
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onLoanSelected,
              ),
            ],
          ),
        );
      },
    );
  }
}
