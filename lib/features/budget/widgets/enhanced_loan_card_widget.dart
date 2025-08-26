// lib/features/budget/widgets/enhanced_loan_card_widget.dart
// Fixed: Replaced invalid copyWith on Color with Color.fromARGB for alpha modification.
// Fixed type mismatch by ensuring LoanModel consistency.
// Added mounted checks for async context usage.
// Added const where possible for performance.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../features/loan/models/loan_model.dart';
import '../../../shared/providers/loan_provider.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';

class EnhancedLoanCardWidget extends StatelessWidget {
  final LoanModel loan;
  final String currency;
  final VoidCallback? onUpdated;

  const EnhancedLoanCardWidget({
    super.key,
    required this.loan,
    required this.currency,
    this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      gradient: LinearGradient(
        colors: [
          Color.fromARGB(217, AppTheme.primaryPurple.red,
              AppTheme.primaryPurple.green, AppTheme.primaryPurple.blue),
          Color.fromARGB(191, AppTheme.primaryBlue.red,
              AppTheme.primaryBlue.green, AppTheme.primaryBlue.blue),
          Color.fromARGB(77, loan.statusColor.red, loan.statusColor.green,
              loan.statusColor.blue),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 16.h),
            _buildProgressSection(),
            SizedBox(height: 16.h),
            _buildStatsGrid(),
            SizedBox(height: 16.h),
            _buildActionButtons(context),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Color.fromARGB(38, 255, 255, 255),
            shape: BoxShape.circle,
            border:
                Border.all(color: Color.fromARGB(51, 255, 255, 255), width: 2),
          ),
          child: Stack(
            children: [
              Icon(
                Icons.account_balance,
                size: 28.sp,
                color: Colors.white,
              ),
              if (loan.isCompleted)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loan.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Color.fromARGB(77, loan.statusColor.red,
                      loan.statusColor.green, loan.statusColor.blue),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: Color.fromARGB(128, loan.statusColor.red,
                          loan.statusColor.green, loan.statusColor.blue)),
                ),
                child: Text(
                  loan.status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Color.fromARGB(204, 255, 255, 255),
            size: 20.sp,
          ),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit Loan'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'payment',
              child: Row(
                children: [
                  Icon(Icons.payment, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Make Payment'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleMenuAction(context, value),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Text(
              '${loan.progressPercentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          height: 12.h,
          decoration: BoxDecoration(
            color: Color.fromARGB(51, 255, 255, 255),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Stack(
            children: [
              Container(
                height: 12.h,
                decoration: BoxDecoration(
                  color: Color.fromARGB(26, 255, 255, 255),
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: loan.progress,
                child: Container(
                  height: 12.h,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: loan.isCompleted
                          ? [Colors.greenAccent, Colors.green]
                          : [Colors.white, Color.fromARGB(204, 255, 255, 255)],
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${loan.monthsElapsed} months completed',
              style: TextStyle(
                fontSize: 12.sp,
                color: Color.fromARGB(204, 255, 255, 255),
              ),
            ),
            Text(
              '${loan.remainingMonths} months left',
              style: TextStyle(
                fontSize: 12.sp,
                color: Color.fromARGB(204, 255, 255, 255),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Color.fromARGB(26, 255, 255, 255),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Color.fromARGB(51, 255, 255, 255)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total Amount',
                  '$currency ${NumberFormat('#,##0').format(loan.totalAmount)}',
                  Icons.account_balance_wallet,
                  Colors.cyanAccent,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Monthly EMI',
                  '$currency ${NumberFormat('#,##0').format(loan.emiAmount)}',
                  Icons.payment,
                  Colors.lightGreenAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Paid Amount',
                  '$currency ${NumberFormat('#,##0').format(loan.paidAmount)}',
                  Icons.trending_up,
                  Colors.greenAccent,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Remaining',
                  '$currency ${NumberFormat('#,##0').format(loan.remainingAmount)}',
                  Icons.pending_actions,
                  Colors.orangeAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Start Date',
                  DateFormat('MMM yyyy').format(loan.startDate),
                  Icons.calendar_today,
                  Colors.lightBlueAccent,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatItem(
                  'Total Tenure',
                  '${loan.tenureMonths} months',
                  Icons.schedule,
                  Colors.purpleAccent,
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
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14.sp,
              color: accentColor,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (!loan.isCompleted) ...[
          Expanded(
            child: SizedBox(
              height: 36.h,
              child: ElevatedButton.icon(
                onPressed: () => _handleMenuAction(context, 'payment'),
                icon: const Icon(Icons.payment, size: 14),
                label: const Text(
                  'Make Payment',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(229, Colors.greenAccent.red,
                      Colors.greenAccent.green, Colors.greenAccent.blue),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        Expanded(
          child: SizedBox(
            height: 36.h,
            child: OutlinedButton.icon(
              onPressed: () => _handleMenuAction(context, 'edit'),
              icon: const Icon(Icons.edit, size: 14),
              label: const Text(
                'Edit',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Color.fromARGB(128, 255, 255, 255)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
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
  }

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: loan.name);
    final amountController =
        TextEditingController(text: loan.totalAmount.toString());
    final emiController =
        TextEditingController(text: loan.emiAmount.toString());
    final monthsController =
        TextEditingController(text: loan.tenureMonths.toString());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: LiquidCard(
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Edit Loan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, size: 24),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
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
                      labelText: 'Total Tenure (Months)',
                      controller: monthsController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.calendar_month,
                    ),
                    SizedBox(height: 24.h),
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
                                name: titleController.text.trim(),
                                totalAmount:
                                    double.tryParse(amountController.text) ??
                                        loan.totalAmount,
                                emiAmount:
                                    double.tryParse(emiController.text) ??
                                        loan.emiAmount,
                                tenureMonths:
                                    int.tryParse(monthsController.text) ??
                                        loan.tenureMonths,
                                updatedAt: DateTime.now(),
                              );
                              final success =
                                  await loanProvider.updateLoan(updatedLoan as Loan);
                              if (success) {
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                onUpdated?.call();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Loan updated successfully'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } else {
                                if (!context.mounted) return;
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Make Payment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(
                          26,
                          AppTheme.primaryPurple.red,
                          AppTheme.primaryPurple.green,
                          AppTheme.primaryPurple.blue),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                          color: Color.fromARGB(
                              51,
                              AppTheme.primaryPurple.red,
                              AppTheme.primaryPurple.green,
                              AppTheme.primaryPurple.blue)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loan.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remaining Amount:',
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.grey),
                            ),
                            Text(
                              '$currency ${NumberFormat('#,##0').format(loan.remainingAmount)}',
                              style: const TextStyle(
                                fontSize: 14,
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
                                  fontSize: 12.sp, color: Colors.grey),
                            ),
                            Text(
                              '$currency ${NumberFormat('#,##0').format(loan.emiAmount)}',
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
                  LiquidTextField(
                    labelText: 'Payment Amount',
                    hintText: 'Enter payment amount',
                    controller: paymentController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.payment,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Quick Options:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    children: [
                      _buildQuickPaymentChip(
                        'Monthly EMI',
                        loan.emiAmount,
                        paymentController,
                      ),
                      _buildQuickPaymentChip(
                        'Half EMI',
                        loan.emiAmount / 2,
                        paymentController,
                      ),
                      _buildQuickPaymentChip(
                        'Double EMI',
                        loan.emiAmount * 2,
                        paymentController,
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
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
                                      const SnackBar(
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
                                  if (success) {
                                    if (!context.mounted) return;
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
                                  } else {
                                    if (!context.mounted) return;
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
    String label,
    double amount,
    TextEditingController controller,
  ) {
    return InkWell(
      onTap: () {
        controller.text = amount.toStringAsFixed(0);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Color.fromARGB(26, AppTheme.primaryPurple.red,
              AppTheme.primaryPurple.green, AppTheme.primaryPurple.blue),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: Color.fromARGB(77, AppTheme.primaryPurple.red,
                  AppTheme.primaryPurple.green, AppTheme.primaryPurple.blue)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
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
        title: const Text('Delete Loan?'),
        content: Text('This will permanently delete "${loan.name}".'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(outerCtx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(outerCtx);
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
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Deleting loan...'),
                      ],
                    ),
                  ),
                ),
              );
              final provider =
                  Provider.of<LoanProvider>(context, listen: false);
              final success = await provider.deleteLoan(loan.id);
              if (!outerCtx.mounted)
                return; // Mounted check for loading context
              Navigator.pop(outerCtx); // Dismiss loading
              if (success) {
                if (!context.mounted) return;
                onUpdated?.call();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.errorMessage ?? 'Delete failed'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
