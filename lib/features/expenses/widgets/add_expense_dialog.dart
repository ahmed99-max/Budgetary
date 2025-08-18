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
  final _titleController = TextEditingController(); // NEW: Controller for title
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
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
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final userId =
        FirebaseAuth.instance.currentUser?.uid ?? ''; // NEW: Get userId
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    final success = await expenseProvider.addExpense(
      userId: userId, // NEW: Pass userId
      title: _titleController.text.trim(), // NEW: Pass title
      description: _descriptionController.text.trim(),
      amount: amount,
      category: _selectedCategory!,
      date: _selectedDate,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
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
    final categories = AppConfig.defaultCategories.keys.toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: LiquidCard(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryPurple.withOpacity(0.95),
              AppTheme.primaryBlue.withOpacity(0.95),
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
                      Text(
                        'Add Expense',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.3, end: 0),

                  SizedBox(height: 24.h),

                  // NEW: Title field
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

                  // Category Selection
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        hint: Text(
                          'Select category',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                        isExpanded: true,
                        dropdownColor: AppTheme.primaryPurple,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: Colors.white),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Text(
                                  AppConfig.defaultCategories[category] ?? '',
                                  style: TextStyle(fontSize: 18.sp),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  category,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),

                  SizedBox(height: 20.h),

                  // Amount
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

                  // Description
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

                  // Date Selection
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Colors.white.withOpacity(0.8)),
                          SizedBox(width: 12.w),
                          Text(
                            DateFormat('EEEE, MMM dd, yyyy')
                                .format(_selectedDate),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 600.ms)
                      .slideX(begin: 0.3, end: 0),

                  SizedBox(height: 32.h),

                  // Add Button
                  SizedBox(
                    width: double.infinity,
                    child: LiquidButton(
                      text: 'Add Expense',
                      onPressed: _addExpense,
                      icon: Icons.add,
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.white.withOpacity(0.8)],
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
