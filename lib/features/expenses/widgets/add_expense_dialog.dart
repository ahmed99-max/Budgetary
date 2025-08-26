// lib/features/expenses/widgets/add_expense_dialog.dart
// Fixed version

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/providers/budget_provider.dart';
import '../../../shared/providers/loan_provider.dart';
import '../widgets/loan_selection_dropdown.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';

class AddExpenseDialog extends StatefulWidget {
  const AddExpenseDialog({super.key});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedLoanId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              // Added const
              primary: AppTheme.primaryPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _addExpense() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a category')), // Added const
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid amount')), // Added const
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')), // Added const
      );
      return;
    }
    final title = _titleController.text.trim();
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    final success = await expenseProvider.addExpense(
      title: title, // NEW: Pass title
      amount: amount,
      category: _selectedCategory!,
      subcategory:
          '', // Added missing subcategory (use empty or dynamic if needed)
      description: _descriptionController.text.trim(),
      date: _selectedDate,
    );

    if (success && _selectedCategory == 'Loan' && _selectedLoanId != null) {
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);
      final paymentSuccess =
          await loanProvider.makePayment(_selectedLoanId!, amount);
      if (paymentSuccess) {
        final budgetProvider =
            Provider.of<BudgetProvider>(context, listen: false);
        await budgetProvider.loadBudgets(expenseProvider);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                loanProvider.errorMessage ?? 'Failed to update loan payment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (success) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          // Added const
          content: Text('Expense added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(expenseProvider.errorMessage ?? 'Failed to add expense'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final categories = budgetProvider.getAllBudgetCategories();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: LiquidCard(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPurple
                  .withAlpha(242), // Fixed deprecated withOpacity
              AppTheme.primaryBlue.withAlpha(242),
            ],
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        // Added const
                        'Add Expense',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white
                              .withAlpha(204), // Fixed deprecated withOpacity
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.3, end: 0),
                  SizedBox(height: 24.h),
                  LiquidTextField(
                    labelText: 'Title',
                    hintText: 'Enter title',
                    controller: _titleController,
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                  SizedBox(height: 20.h),
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white
                          .withAlpha(229), // Fixed deprecated withOpacity
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withAlpha(26), // Fixed deprecated withOpacity
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white.withAlpha(51)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        hint: Text(
                          'Select category',
                          style: TextStyle(
                              color: Colors.white.withAlpha(
                                  178)), // Fixed deprecated withOpacity
                        ),
                        isExpanded: true,
                        dropdownColor: AppTheme.primaryPurple,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Colors.white), // Added const
                        items: categories.map((category) {
                          final defaultIcon =
                              AppConfig.defaultCategories[category] ?? '';
                          final isCustom = defaultIcon.isEmpty;
                          final iconText = isCustom ? '💼' : defaultIcon;
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Text(iconText,
                                    style: const TextStyle(
                                        fontSize: 18)), // Added const
                                SizedBox(width: 12.w),
                                Text(
                                  category,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16), // Added const
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                            _selectedLoanId = null;
                          });
                        },
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                  SizedBox(height: 20.h),
                  if (_selectedCategory == 'Loan')
                    LoanSelectionDropdown(
                      selectedLoanId: _selectedLoanId,
                      onLoanSelected: (loanId) {
                        setState(() {
                          _selectedLoanId = loanId;
                        });
                      },
                      currency: userProvider.currency,
                    ),
                  SizedBox(height: 20.h),
                  LiquidTextField(
                    labelText: 'Amount (${userProvider.currency})',
                    hintText: 'Enter amount',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money,
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value!.trim()) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms)
                      .slideX(begin: 0.3, end: 0),
                  SizedBox(height: 20.h),
                  LiquidTextField(
                    labelText: 'Description',
                    hintText: 'Enter description (optional)',
                    controller: _descriptionController,
                    maxLines: 2,
                    prefixIcon: Icons.notes,
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                  SizedBox(height: 20.h),
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white
                          .withAlpha(229), // Fixed deprecated withOpacity
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withAlpha(26), // Fixed deprecated withOpacity
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white.withAlpha(51)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Colors.white.withAlpha(
                                  204)), // Fixed deprecated withOpacity
                          SizedBox(width: 12.w),
                          Text(
                            DateFormat('EEEE, MMM dd, yyyy')
                                .format(_selectedDate),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16), // Added const
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 600.ms)
                      .slideX(begin: 0.3, end: 0),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    child: LiquidButton(
                      text: 'Add Expense',
                      onPressed: _addExpense,
                      icon: Icons.add,
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          Colors.white.withAlpha(204)
                        ], // Fixed deprecated withOpacity
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
