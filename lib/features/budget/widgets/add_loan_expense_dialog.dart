// lib/features/expenses/widgets/add_loan_expense_dialog.dart
// BATCH 3: CREATE THIS NEW FILE

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/providers/loan_provider.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';

class AddLoanExpenseDialog extends StatefulWidget {
  final VoidCallback? onExpenseAdded;

  const AddLoanExpenseDialog({
    Key? key,
    this.onExpenseAdded,
  }) : super(key: key);

  @override
  State<AddLoanExpenseDialog> createState() => _AddLoanExpenseDialogState();
}

class _AddLoanExpenseDialogState extends State<AddLoanExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedLoanId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '💳 Add Loan Payment',
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

                    // Loan Selection
                    Text(
                      'Select Loan *',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Consumer<LoanProvider>(
                      builder: (context, loanProvider, _) {
                        final activeLoans = loanProvider.activeLoans;

                        if (activeLoans.isEmpty) {
                          return Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Text(
                              'No active loans found. Please add a loan first.',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          );
                        }

                        return DropdownButtonFormField<String>(
                          value: _selectedLoanId,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                          ),
                          hint: Text('Choose a loan'),
                          items: activeLoans.map((loan) {
                            return DropdownMenuItem<String>(
                              value: loan.id,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    loan.title,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'EMI: ₹${NumberFormat('#,##0').format(loan.monthlyInstallment)}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedLoanId = value;
                              // Auto-fill EMI amount
                              if (value != null) {
                                final loan = activeLoans
                                    .firstWhere((l) => l.id == value);
                                _amountController.text =
                                    loan.monthlyInstallment.toStringAsFixed(0);
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a loan';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Amount
                    LiquidTextField(
                      labelText: 'Payment Amount *',
                      hintText: 'Enter payment amount',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.currency_rupee,
                      validator: (value) {
                        final amount = double.tryParse(value ?? '');
                        if (amount == null || amount <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Description
                    LiquidTextField(
                      labelText: 'Description (Optional)',
                      hintText: 'Payment description',
                      controller: _descriptionController,
                      prefixIcon: Icons.notes,
                      maxLines: 2,
                    ),
                    SizedBox(height: 16.h),

                    // Date Selection
                    Text(
                      'Payment Date *',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16.sp,
                              color: AppTheme.primaryPurple,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: LiquidButton(
                            text: 'Cancel',
                            isOutlined: true,
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.of(context).pop(),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: LiquidButton(
                            text: 'Add Payment',
                            gradient: AppTheme.liquidBackground,
                            onPressed: _isLoading ? null : _addLoanPayment,
                            isLoading: _isLoading,
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
      ),
    );
  }

  Future<void> _addLoanPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();

      final success = await expenseProvider.addLoanPayment(
        loanId: _selectedLoanId!,
        amount: amount,
        description: description,
        date: _selectedDate,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        widget.onExpenseAdded?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loan payment recorded successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                expenseProvider.errorMessage ?? 'Failed to record payment'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
