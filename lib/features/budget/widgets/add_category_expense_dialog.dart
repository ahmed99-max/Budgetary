// lib/features/expenses/widgets/add_category_expense_dialog.dart
// Fixed: Added title input and passed to addExpense

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/models/budget_model.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';

class AddCategoryExpenseDialog extends StatefulWidget {
  final BudgetModel budget;
  final VoidCallback? onExpenseAdded;

  const AddCategoryExpenseDialog({
    Key? key,
    required this.budget,
    this.onExpenseAdded,
  }) : super(key: key);

  @override
  State<AddCategoryExpenseDialog> createState() =>
      _AddCategoryExpenseDialogState();
}

class _AddCategoryExpenseDialogState extends State<AddCategoryExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleController = TextEditingController(); // NEW: Added for title

  DateTime _selectedDate = DateTime.now();
  String _selectedSubcategory = '';
  bool _isLoading = false;

  final Map<String, List<String>> _commonSubcategories = {
    'Food & Dining': [
      'Restaurant',
      'Groceries',
      'Fast Food',
      'Coffee',
      'Snacks'
    ],
    'Transportation': [
      'Fuel',
      'Public Transport',
      'Taxi/Uber',
      'Parking',
      'Maintenance'
    ],
    'Shopping': ['Clothing', 'Electronics', 'Books', 'Gifts', 'Home Decor'],
    'Entertainment': ['Movies', 'Games', 'Concerts', 'Sports', 'Subscriptions'],
    'Health': ['Doctor Visit', 'Medicines', 'Gym', 'Insurance', 'Dental'],
    'Utilities': ['Electricity', 'Water', 'Internet', 'Phone', 'Gas'],
    'Education': ['Courses', 'Books', 'Training', 'Certification', 'Workshop'],
  };

  @override
  void initState() {
    super.initState();
    _selectedSubcategory =
        _commonSubcategories[widget.budget.category]?.first ?? 'General';
  }

  @override
  Widget build(BuildContext context) {
    final subcategories =
        _commonSubcategories[widget.budget.category] ?? ['General'];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: LiquidCard(
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
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
                    // Header with Category Info
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryPurple.withOpacity(0.1),
                            AppTheme.primaryBlue.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppTheme.primaryPurple.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Add Expense',
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
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(
                                Icons.category,
                                color: AppTheme.primaryPurple,
                                size: 16.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'Category: ${widget.budget.category}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Budget: ₹${NumberFormat('#,##0').format(widget.budget.allocatedAmount)}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Consumer<ExpenseProvider>(
                                builder: (context, expenseProvider, _) {
                                  final spent = expenseProvider.categoryTotals[
                                          widget.budget.category] ??
                                      0.0;
                                  final remaining =
                                      widget.budget.allocatedAmount - spent;

                                  return Text(
                                    'Remaining: ₹${NumberFormat('#,##0').format(remaining)}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: remaining >= 0
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // NEW: Title Input
                    LiquidTextField(
                      labelText: 'Title *',
                      hintText: 'Enter expense title',
                      controller: _titleController,
                      prefixIcon: Icons.label,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Amount Input
                    LiquidTextField(
                      labelText: 'Amount *',
                      hintText: 'Enter expense amount',
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

                    // Subcategory Selection
                    Text(
                      'Subcategory',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: _selectedSubcategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                      ),
                      items: subcategories.map((subcategory) {
                        return DropdownMenuItem<String>(
                          value: subcategory,
                          child: Text(subcategory),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubcategory = value!;
                        });
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Description
                    LiquidTextField(
                      labelText: 'Description *',
                      hintText: 'What did you spend on?',
                      controller: _descriptionController,
                      prefixIcon: Icons.notes,
                      maxLines: 2,
                      validator: (value) {
                        if (value?.trim().isEmpty ?? true) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Date Selection
                    Text(
                      'Date *',
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
                              DateFormat('dd/MM/yyyy - EEEE')
                                  .format(_selectedDate),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Quick Amount Suggestions
                    Text(
                      'Quick Amount:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      children: [100, 200, 500, 1000, 2000].map((amount) {
                        return InkWell(
                          onTap: () {
                            _amountController.text = amount.toString();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: AppTheme.primaryPurple.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '₹$amount',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppTheme.primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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
                            text: 'Add Expense',
                            gradient: AppTheme.liquidBackground,
                            onPressed: _isLoading ? null : _addExpense,
                            isLoading: _isLoading,
                            icon: Icons.add_shopping_cart,
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

  Future<void> _addExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();
      final title = _titleController.text.trim(); // NEW: Get title

      final success = await expenseProvider.addExpense(
        title: title, // NEW: Pass title
        amount: amount,
        category: widget.budget.category,
        subcategory: _selectedSubcategory,
        description: description,
        date: _selectedDate,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        widget.onExpenseAdded?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(expenseProvider.errorMessage ?? 'Failed to add expense'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
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
    _titleController.dispose(); // NEW: Dispose title controller
    super.dispose();
  }
}
