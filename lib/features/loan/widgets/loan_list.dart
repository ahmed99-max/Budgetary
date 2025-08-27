// lib/features/loan/widgets/loan_list.dart
// FIXED VERSION

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/loan_provider.dart'; // Import the kept LoanProvider (which defines Loan)
import '../../budget/widgets/enhanced_loan_card_widget.dart'; // FIXED: Use the enhanced widget instead of LoanCard
import 'add_loan_dialog.dart';

class LoanList extends StatelessWidget {
  const LoanList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoanProvider>();
    final loans = provider.loans;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: Text(
                'Loans',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const AddLoanDialog(), // FIXED: Added const
              ),
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromRGBO(
                    255, 255, 255, 0.12), // FIXED: Added const
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (provider.isLoading && loans.isEmpty)
          const Center(child: CircularProgressIndicator()) // FIXED: Added const
        else if (loans.isEmpty)
          Text(
            'No loans yet. Add one to get started.',
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          )
        else
          Column(
            children: loans
                .map((l) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: EnhancedLoanCardWidget(
                        // FIXED: Use EnhancedLoanCardWidget instead of LoanCard
                        loan: l,
                        currency:
                            'USD', // FIXED: Added required currency (replace with actual currency if dynamic)
                        onUpdated: () {
                          // FIXED: Removed onEdit/onDelete (not needed in enhanced widget; handle updates via onUpdated)
                          provider.loadLoans(); // Reload loans after update
                        },
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }
}
