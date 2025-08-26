// lib/features/loan/widgets/loan_list.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../shared/providers/loan_provider.dart'; // Import the kept LoanProvider (which defines Loan)
import 'add_loan_dialog.dart';
import 'loan_card.dart'; // Assuming this exists or use loan_card_widget.dart - update to use Loan

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
                builder: (_) => const AddLoanDialog(),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Color.fromRGBO(
                    255, 255, 255, 0.12), // FIXED: Deprecated withOpacity
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
          const Center(child: CircularProgressIndicator())
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
                      child: LoanCard(
                        loan:
                            l, // FIXED: l is now Loan, ensure LoanCard accepts Loan
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (_) => AddLoanDialog(
                                existing:
                                    l), // FIXED: existing now accepts Loan
                          );
                        },
                        onDelete: () async {
                          final ok = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete loan?'),
                                  content: Text('This cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              ) ??
                              false;
                          if (ok) {
                            if (context.mounted) {
                              // FIXED: Async context
                              await context
                                  .read<LoanProvider>()
                                  .deleteLoan(l.id);
                            }
                          }
                        },
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }
}
