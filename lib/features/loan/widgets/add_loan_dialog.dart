import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/loan_provider.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';
import '../../../shared/widgets/liquid_card.dart';

class AddLoanDialog extends StatefulWidget {
  final Loan? existing;
  final VoidCallback? onLoanUpdated;

  const AddLoanDialog({
    Key? key,
    this.existing,
    this.onLoanUpdated,
  }) : super(key: key);

  @override
  State<AddLoanDialog> createState() => _AddLoanDialogState();
}

class _AddLoanDialogState extends State<AddLoanDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _totalAmountController;
  late TextEditingController _monthlyEMIController;
  late TextEditingController _interestRateController;
  late TextEditingController _tenureController;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 365));
  String _selectedLoanType = 'Personal Loan';
  bool _isLoading = false;

  final List<String> _loanTypes = [
    'Personal Loan',
    'Home Loan',
    'Car Loan',
    'Education Loan',
    'Business Loan',
    'Credit Card',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(
      text: widget.existing?.title ?? '',
    );
    _totalAmountController = TextEditingController(
      text: widget.existing?.amount.toString() ?? '',
    );
    _monthlyEMIController = TextEditingController(
      text: widget.existing?.monthlyInstallment.toString() ?? '',
    );
    _interestRateController = TextEditingController();
    _tenureController = TextEditingController(
      text: widget.existing?.totalMonths.toString() ?? '',
    );

    if (widget.existing != null) {
      _startDate = widget.existing!.createdAt;
      _calculateEndDate();
    }
  }

  void _calculateEndDate() {
    final tenure = int.tryParse(_tenureController.text) ?? 12;
    _endDate =
        DateTime(_startDate.year, _startDate.month + tenure, _startDate.day);
  }

  void _calculateEMI() {
    final principal = double.tryParse(_totalAmountController.text) ?? 0;
    final rate = double.tryParse(_interestRateController.text) ?? 0;
    final tenure = int.tryParse(_tenureController.text) ?? 0;

    if (principal > 0 && rate > 0 && tenure > 0) {
      final monthlyRate = rate / (12 * 100);
      final emi = (principal * monthlyRate * pow(1 + monthlyRate, tenure)) /
          (pow(1 + monthlyRate, tenure) - 1);
      _monthlyEMIController.text = emi.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: LiquidCard(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                          isEdit ? 'Edit Loan' : 'Add New Loan',
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

                    // Loan Type Dropdown
                    Text(
                      'Loan Type',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: _selectedLoanType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      items: _loanTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLoanType = value!;
                          if (_titleController.text.isEmpty) {
                            _titleController.text = value;
                          }
                        });
                      },
                    ).animate().fadeIn(delay: 100.ms),
                    SizedBox(height: 16.h),

                    // Loan Title
                    LiquidTextField(
                      labelText: 'Loan Title *',
                      hintText: 'Enter loan title',
                      controller: _titleController,
                      prefixIcon: Icons.title,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Loan title is required';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 150.ms),
                    SizedBox(height: 16.h),

                    // Total Loan Amount
                    LiquidTextField(
                      labelText: 'Total Loan Amount *',
                      hintText: 'Enter total amount',
                      controller: _totalAmountController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      onChanged: (value) => _calculateEMI(),
                      validator: (value) {
                        final amount = double.tryParse(value ?? '');
                        if (amount == null || amount <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 200.ms),
                    SizedBox(height: 16.h),

                    // Interest Rate and Tenure Row
                    Row(
                      children: [
                        Expanded(
                          child: LiquidTextField(
                            labelText: 'Interest Rate (% p.a.)',
                            hintText: 'e.g. 12.5',
                            controller: _interestRateController,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            prefixIcon: Icons.percent,
                            onChanged: (value) => _calculateEMI(),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: LiquidTextField(
                            labelText: 'Tenure (months) *',
                            hintText: 'e.g. 36',
                            controller: _tenureController,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.calendar_month,
                            onChanged: (value) {
                              _calculateEMI();
                              _calculateEndDate();
                              setState(() {});
                            },
                            validator: (value) {
                              final months = int.tryParse(value ?? '');
                              if (months == null || months <= 0) {
                                return 'Enter valid months';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 250.ms),
                    SizedBox(height: 16.h),

                    // Monthly EMI
                    LiquidTextField(
                      labelText: 'Monthly EMI *',
                      hintText: 'Enter or calculate EMI',
                      controller: _monthlyEMIController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.payment,
                      validator: (value) {
                        final emi = double.tryParse(value ?? '');
                        if (emi == null || emi <= 0) {
                          return 'Enter a valid EMI amount';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 300.ms),
                    SizedBox(height: 4.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _calculateEMI,
                        child: Text(
                          'Calculate EMI',
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Date Selection Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateSelector(
                            'Start Date *',
                            _startDate,
                            (date) {
                              setState(() {
                                _startDate = date;
                                _calculateEndDate();
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildDateSelector(
                            'End Date',
                            _endDate,
                            (date) {
                              setState(() {
                                _endDate = date;
                              });
                            },
                            enabled: false,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 350.ms),
                    SizedBox(height: 20.h),

                    // Loan Summary Card
                    if (_totalAmountController.text.isNotEmpty &&
                        _monthlyEMIController.text.isNotEmpty)
                      _buildLoanSummary().animate().fadeIn(delay: 400.ms),
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
                            text: isEdit ? 'Update Loan' : 'Add Loan',
                            gradient: AppTheme.liquidBackground,
                            onPressed: _isLoading ? null : _saveLoan,
                            isLoading: _isLoading,
                            icon: isEdit ? Icons.update : Icons.add,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 450.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: Offset(0.8, 0.8));
  }

  Widget _buildDateSelector(
      String label, DateTime date, Function(DateTime) onDateChanged,
      {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap:
              enabled ? () => _selectDate(context, date, onDateChanged) : null,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.r),
              color: enabled ? Colors.white : Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16.sp,
                  color: enabled ? AppTheme.primaryPurple : Colors.grey,
                ),
                SizedBox(width: 8.w),
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: enabled ? Colors.grey.shade800 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoanSummary() {
    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0;
    final monthlyEMI = double.tryParse(_monthlyEMIController.text) ?? 0;
    final tenure = int.tryParse(_tenureController.text) ?? 0;
    final totalPayable = monthlyEMI * tenure;
    final totalInterest = totalPayable - totalAmount;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryPurple.withOpacity(0.1),
            AppTheme.primaryBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loan Summary',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12.h),
          _buildSummaryRow('Principal Amount', totalAmount),
          _buildSummaryRow('Total Interest', totalInterest),
          _buildSummaryRow('Total Payable', totalPayable),
          Divider(),
          _buildSummaryRow('Monthly EMI', monthlyEMI, isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isHighlight = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color:
                  isHighlight ? AppTheme.primaryPurple : Colors.grey.shade600,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            '₹ ${NumberFormat('#,##0').format(amount)}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color:
                  isHighlight ? AppTheme.primaryPurple : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      Function(DateTime) onDateChanged) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onDateChanged(picked);
    }
  }

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);

      if (widget.existing != null) {
        // Update existing loan
        final updatedLoan = widget.existing!.copyWith(
          title: _titleController.text.trim(),
          amount: double.parse(_totalAmountController.text),
          monthlyInstallment: double.parse(_monthlyEMIController.text),
          remainingMonths: int.parse(_tenureController.text),
          updatedAt: DateTime.now(),
        );

        final success = await loanProvider.updateLoan(updatedLoan);
        if (success && mounted) {
          Navigator.of(context).pop();
          widget.onLoanUpdated?.call();
          _showSuccessMessage('Loan updated successfully');
        } else {
          _showErrorMessage(
              loanProvider.errorMessage ?? 'Failed to update loan');
        }
      } else {
        // Create new loan
        final success = await loanProvider.addLoan(
          title: _titleController.text.trim(),
          amount: double.parse(_totalAmountController.text),
          monthlyInstallment: double.parse(_monthlyEMIController.text),
          remainingMonths: int.parse(_tenureController.text),
        );

        if (success && mounted) {
          Navigator.of(context).pop();
          widget.onLoanUpdated?.call();
          _showSuccessMessage('Loan added successfully');
        } else {
          _showErrorMessage(loanProvider.errorMessage ?? 'Failed to add loan');
        }
      }
    } catch (e) {
      _showErrorMessage('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalAmountController.dispose();
    _monthlyEMIController.dispose();
    _interestRateController.dispose();
    _tenureController.dispose();
    super.dispose();
  }
}
