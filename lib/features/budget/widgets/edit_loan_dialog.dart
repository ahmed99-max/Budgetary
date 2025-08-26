// lib/features/budget/widgets/edit_loan_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/loan_provider.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';
import '../../../shared/widgets/liquid_card.dart';

class EditLoanDialog extends StatefulWidget {
  final Loan loan;
  final VoidCallback? onLoanUpdated;

  const EditLoanDialog({
    Key? key,
    required this.loan,
    this.onLoanUpdated,
  }) : super(key: key);

  @override
  State<EditLoanDialog> createState() => _EditLoanDialogState();
}

class _EditLoanDialogState extends State<EditLoanDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _monthlyInstallmentController;
  late TextEditingController _remainingMonthsController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.loan.title);
    _amountController = TextEditingController(text: widget.loan.amount.toStringAsFixed(0));
    _monthlyInstallmentController = TextEditingController(text: widget.loan.monthlyInstallment.toStringAsFixed(0));
    _remainingMonthsController = TextEditingController(text: widget.loan.remainingMonths.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _monthlyInstallmentController.dispose();
    _remainingMonthsController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return 'Loan title is required';
    }
    if (value!.trim().length < 2) {
      return 'Title must be at least 2 characters';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value!);
    if (amount == null || amount <= 0) {
      return 'Enter a valid amount';
    }
    return null;
  }

  String? _validateMonthlyInstallment(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return 'Monthly installment is required';
    }
    final installment = double.tryParse(value!);
    if (installment == null || installment <= 0) {
      return 'Enter a valid installment amount';
    }
    return null;
  }

  String? _validateRemainingMonths(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return 'Remaining months is required';
    }
    final months = int.tryParse(value!);
    if (months == null || months < 0) {
      return 'Enter a valid number of months';
    }
    return null;
  }

  Future<void> _saveLoan() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);
      
      final updatedLoan = widget.loan.copyWith(
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        monthlyInstallment: double.parse(_monthlyInstallmentController.text),
        remainingMonths: int.parse(_remainingMonthsController.text),
        updatedAt: DateTime.now(),
      );

      final success = await loanProvider.updateLoan(updatedLoan);

      if (success && mounted) {
        Navigator.of(context).pop();
        widget.onLoanUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loan updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loanProvider.errorMessage ?? 'Failed to update loan'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: LiquidCard(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
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

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Loan Title
                        LiquidTextField(
                          labelText: 'Loan Title',
                          hintText: 'Enter loan title',
                          controller: _titleController,
                          prefixIcon: Icons.title,
                          validator: _validateTitle,
                        ).animate()
                            .fadeIn(delay: 100.ms, duration: 600.ms)
                            .slideX(begin: -0.3, end: 0),
                        SizedBox(height: 16.h),

                        // Total Amount
                        LiquidTextField(
                          labelText: 'Total Loan Amount',
                          hintText: 'Enter total amount',
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.attach_money,
                          validator: _validateAmount,
                        ).animate()
                            .fadeIn(delay: 200.ms, duration: 600.ms)
                            .slideX(begin: -0.3, end: 0),
                        SizedBox(height: 16.h),

                        // Monthly Installment
                        LiquidTextField(
                          labelText: 'Monthly Installment',
                          hintText: 'Enter monthly EMI',
                          controller: _monthlyInstallmentController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.payment,
                          validator: _validateMonthlyInstallment,
                        ).animate()
                            .fadeIn(delay: 300.ms, duration: 600.ms)
                            .slideX(begin: -0.3, end: 0),
                        SizedBox(height: 16.h),

                        // Remaining Months
                        LiquidTextField(
                          labelText: 'Remaining Months',
                          hintText: 'Enter remaining months',
                          controller: _remainingMonthsController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.calendar_month,
                          validator: _validateRemainingMonths,
                        ).animate()
                            .fadeIn(delay: 400.ms, duration: 600.ms)
                            .slideX(begin: -0.3, end: 0),
                        SizedBox(height: 24.h),

                        // Loan Info Summary
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Original Loan Term:', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                                  Text('${widget.loan.totalMonths} months', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Progress:', style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                                  Text('${widget.loan.completionPercentage.toStringAsFixed(1)}% completed', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppTheme.primaryPurple)),
                                ],
                              ),
                            ],
                          ),
                        ).animate()
                            .fadeIn(delay: 500.ms, duration: 600.ms),
                        SizedBox(height: 24.h),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: LiquidButton(
                                text: 'Cancel',
                                isOutlined: true,
                                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: LiquidButton(
                                text: 'Update Loan',
                                gradient: AppTheme.liquidBackground,
                                onPressed: _isLoading ? null : _saveLoan,
                                isLoading: _isLoading,
                                icon: Icons.save_outlined,
                              ),
                            ),
                          ],
                        ).animate()
                            .fadeIn(delay: 600.ms, duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }
}