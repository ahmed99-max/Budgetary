// lib/features/budget/widgets/loan_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/loan_provider.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';

class LoanCardWidget extends StatelessWidget {
  final Loan loan;
  final String currency;
  final VoidCallback? onUpdated;

  const LoanCardWidget({
    Key? key,
    required this.loan,
    required this.currency,
    this.onUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final completionPercentage = loan.completionPercentage;
    final isNearCompletion = completionPercentage >= 80;
    final isCompleted = loan.isCompleted;

    Color progressColor;
    if (isCompleted) {
      progressColor = Colors.green;
    } else if (isNearCompletion) {
      progressColor = Colors.orange;
    } else {
      progressColor = AppTheme.primaryPurple;
    }

    return LiquidCard(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      gradient: LinearGradient(
        colors: [
          AppTheme.primaryPurple.withOpacity(0.80),
          AppTheme.primaryBlue.withOpacity(0.70)
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.10)),
              ),
              child:
                  Icon(Icons.account_balance, size: 28.sp, color: Colors.white),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        loan.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${completionPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${loan.remainingMonths} months left',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13.sp,
                        fontStyle: FontStyle.italic),
                  ),
                  SizedBox(height: 10.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: LinearProgressIndicator(
                      value: (loan.totalPaid / loan.amount).clamp(0.0, 1.0),
                      minHeight: 8.h,
                      backgroundColor: Colors.white.withOpacity(0.07),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        loan.isCompleted
                            ? Colors.green
                            : (loan.completionPercentage >= 80
                                ? Colors.orange
                                : Colors.blueAccent),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      _amountPill(
                          'Paid', loan.totalPaid, Colors.greenAccent, context),
                      SizedBox(width: 12.w),
                      _amountPill('Remaining', loan.totalRemaining,
                          Colors.orange, context),
                    ],
                  ),
                ],
              ),
            ),
            // KEEP: Action button (PopupMenuButton)
            PopupMenuButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white
                    .withOpacity(0.8), // Updated color to match new UI
                size: 18.sp,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text('Edit'),
                    ],
                  ),
                ),
                if (!isCompleted)
                  PopupMenuItem(
                    value: 'payment',
                    child: Row(
                      children: [
                        Icon(Icons.payment, size: 16.sp),
                        SizedBox(width: 8.w),
                        Text('Make Payment'),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 16.sp),
                      SizedBox(width: 8.w),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditDialog(context);
                    break;
                  case 'payment':
                    _showPaymentDialog(context);
                    break;
                  case 'delete':
                    _showDeleteDialog(context);
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // UPDATED HELPER: _amountPill (replaced _buildAmountChip, kept compact formatting)
  Widget _amountPill(
      String label, double amount, Color color, BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            '$label: ${NumberFormat.compact().format(amount)}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  // KEEP: All original dialog functions (_showEditDialog, _showPaymentDialog, _showDeleteDialog)
  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: loan.title);
    final amountController =
        TextEditingController(text: loan.amount.toString());
    final emiController =
        TextEditingController(text: loan.monthlyInstallment.toString());
    final monthsController =
        TextEditingController(text: loan.remainingMonths.toString());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: LiquidCard(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Edit Loan',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close, size: 24.sp),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Form fields
                    LiquidTextField(
                      labelText: 'Loan Title',
                      controller: titleController,
                      prefixIcon: Icons.title,
                    ),
                    SizedBox(height: 16.h),

                    LiquidTextField(
                      labelText: 'Total Amount',
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                    ),
                    SizedBox(height: 16.h),

                    LiquidTextField(
                      labelText: 'Monthly EMI',
                      controller: emiController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.payment,
                    ),
                    SizedBox(height: 16.h),

                    LiquidTextField(
                      labelText: 'Remaining Months',
                      controller: monthsController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.calendar_month,
                    ),
                    SizedBox(height: 24.h),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: LiquidButton(
                            text: 'Cancel',
                            isOutlined: true,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: LiquidButton(
                            text: 'Update',
                            gradient: AppTheme.liquidBackground,
                            onPressed: () async {
                              final loanProvider = Provider.of<LoanProvider>(
                                  context,
                                  listen: false);
                              final updatedLoan = loan.copyWith(
                                title: titleController.text.trim(),
                                amount:
                                    double.tryParse(amountController.text) ??
                                        loan.amount,
                                monthlyInstallment:
                                    double.tryParse(emiController.text) ??
                                        loan.monthlyInstallment,
                                remainingMonths:
                                    int.tryParse(monthsController.text) ??
                                        loan.remainingMonths,
                                updatedAt: DateTime.now(),
                              );
                              final success =
                                  await loanProvider.updateLoan(updatedLoan);
                              if (success && context.mounted) {
                                Navigator.of(context).pop();
                                onUpdated?.call();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Loan updated successfully'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(loanProvider.errorMessage ??
                                        'Failed to update loan'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: Icons.update,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    final paymentController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: LiquidCard(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Make Payment',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, size: 20.sp),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Loan details
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: AppTheme.primaryPurple.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loan.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remaining Amount:',
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey.shade600),
                            ),
                            Text(
                              '$currency ${NumberFormat('#,##0').format(loan.totalRemaining)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Monthly EMI:',
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey.shade600),
                            ),
                            Text(
                              '$currency ${NumberFormat('#,##0').format(loan.monthlyInstallment)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Payment amount input
                  LiquidTextField(
                    labelText: 'Payment Amount',
                    hintText: 'Enter payment amount',
                    controller: paymentController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.payment,
                  ),
                  SizedBox(height: 20.h),

                  // Quick payment options
                  Text(
                    'Quick Options:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    children: [
                      _buildQuickPaymentChip(
                        'Monthly EMI',
                        loan.monthlyInstallment,
                        paymentController,
                      ),
                      _buildQuickPaymentChip(
                        'Half EMI',
                        loan.monthlyInstallment / 2,
                        paymentController,
                      ),
                      _buildQuickPaymentChip(
                        'Double EMI',
                        loan.monthlyInstallment * 2,
                        paymentController,
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: LiquidButton(
                          text: 'Cancel',
                          isOutlined: true,
                          onPressed: isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: LiquidButton(
                          text: 'Record Payment',
                          gradient: AppTheme.liquidBackground,
                          isLoading: isLoading,
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final amount =
                                      double.tryParse(paymentController.text);
                                  if (amount == null || amount <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Please enter a valid payment amount'),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => isLoading = true);
                                  final loanProvider =
                                      Provider.of<LoanProvider>(context,
                                          listen: false);
                                  final success = await loanProvider
                                      .makePayment(loan.id, amount);
                                  setState(() => isLoading = false);
                                  if (success && context.mounted) {
                                    Navigator.of(context).pop();
                                    onUpdated?.call();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Payment of $currency ${amount.toStringAsFixed(2)} recorded successfully'),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  } else if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            loanProvider.errorMessage ??
                                                'Failed to record payment'),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          icon: Icons.payment,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPaymentChip(
      String label, double amount, TextEditingController controller) {
    return InkWell(
      onTap: () {
        controller.text = amount.toStringAsFixed(0);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.primaryPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (outerCtx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('Delete Loan?'),
        content: Text('This will permanently delete "${loan.title}".'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(outerCtx), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // 1) Dismiss the confirmation dialog
              Navigator.pop(outerCtx);

              // 2) Show loading on top
              showDialog(
                context: outerCtx,
                barrierDismissible: false,
                builder: (loadingCtx) => Center(
                  child: Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16.h),
                      Text('Deleting loan...'),
                    ]),
                  ),
                ),
              );

              // 3) Perform deletion
              final provider =
                  Provider.of<LoanProvider>(context, listen: false);
              final success = await provider.deleteLoan(loan.id);

              // 4) Dismiss the loading dialog using the same loadingCtx
              Navigator.pop(outerCtx);

              // 5) Refresh UI/toast
              if (success && context.mounted) {
                onUpdated?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Deleted successfully'),
                      backgroundColor: Colors.green),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(provider.errorMessage ?? 'Delete failed'),
                      backgroundColor: Colors.red),
                );
              }
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
