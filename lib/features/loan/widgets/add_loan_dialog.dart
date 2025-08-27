// lib/features/loan/widgets/add_loan_dialog.dart
// FIXED VERSION

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../features/loan/models/loan_model.dart'; // Changed from Loan to LoanModel
import '../../../shared/providers/loan_provider.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';

class AddLoanDialog extends StatefulWidget {
  final VoidCallback? onLoanUpdated;

  const AddLoanDialog({
    super.key, // Fixed: use super parameter
    this.onLoanUpdated,
  });

  @override
  State<AddLoanDialog> createState() => _AddLoanDialogState();
}

class _AddLoanDialogState extends State<AddLoanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _emiAmountController = TextEditingController();
  final _tenureController = TextEditingController();
  DateTime _startDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _totalAmountController.dispose();
    _emiAmountController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: LiquidCard(
        // Fixed: removed const (LiquidCard isn't const)
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add New Loan',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 24),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        LiquidTextField(
                          labelText: 'Loan Name',
                          controller: _nameController,
                          prefixIcon: Icons.title,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter loan name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        LiquidTextField(
                          labelText: 'Total Amount',
                          controller: _totalAmountController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.attach_money,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter total amount';
                            }
                            if (double.tryParse(value) == null ||
                                double.parse(value) <= 0) {
                              return 'Please enter valid amount';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        LiquidTextField(
                          labelText: 'Monthly EMI',
                          controller: _emiAmountController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.payment,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter EMI amount';
                            }
                            if (double.tryParse(value) == null ||
                                double.parse(value) <= 0) {
                              return 'Please enter valid EMI amount';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        LiquidTextField(
                          labelText: 'Tenure (Months)',
                          controller: _tenureController,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.calendar_month,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter tenure';
                            }
                            if (int.tryParse(value) == null ||
                                int.parse(value) <= 0) {
                              return 'Please enter valid tenure';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        _buildDatePicker(),
                        SizedBox(height: 24.h),
                        _buildButtons(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectStartDate,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppTheme.primaryPurple),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Start Date',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(_startDate),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
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
            text: 'Add Loan',
            gradient: AppTheme.liquidBackground,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _addLoan,
            icon: Icons.add,
          ),
        ),
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _addLoan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);

      // Fixed: Use correct parameter names
      final success = await loanProvider.addLoan(
        title: _nameController.text.trim(),
        amount: double.parse(_totalAmountController.text),
        monthlyInstallment: double.parse(_emiAmountController.text),
        totalMonths:
            int.parse(_tenureController.text), // Fixed: added totalMonths
        startDate: _startDate,
      );

      if (!mounted) return;

      if (success) {
        Navigator.of(context).pop();
        widget.onLoanUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            // Fixed: added const
            content: Text('Loan added successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loanProvider.errorMessage ?? 'Failed to add loan'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
