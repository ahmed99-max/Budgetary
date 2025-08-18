import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/providers/budget_provider.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';
import '../../../shared/widgets/liquid_card.dart';

class AddBudgetDialog extends StatefulWidget {
  final VoidCallback onBudgetCreated;

  const AddBudgetDialog({
    super.key,
    required this.onBudgetCreated,
  });

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String _selectedCategory = AppConfig.defaultCategories.keys.first;
  String _selectedPeriod = 'monthly';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _createBudget() async {
    if (_formKey.currentState?.validate() ?? false) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);

      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      final success = await budgetProvider.createBudget(
        userId: userProvider.user!.uid,
        category: _selectedCategory,
        allocatedAmount: double.parse(_amountController.text),
        period: _selectedPeriod,
        startDate: startDate,
        endDate: endDate,
      );

      if (success && mounted) {
        widget.onBudgetCreated();
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: LiquidCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Budget',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
            SizedBox(height: 20.h),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Category Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          gradient: AppTheme.cardGradient,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: Colors.grey.shade600),
                            items: AppConfig.defaultCategories.entries
                                .map((entry) {
                              return DropdownMenuItem(
                                value: entry.key,
                                child: Row(
                                  children: [
                                    Text(entry.value,
                                        style: TextStyle(fontSize: 16.sp)),
                                    SizedBox(width: 8.w),
                                    Text(entry.key,
                                        style: TextStyle(fontSize: 14.sp)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),

                  SizedBox(height: 20.h),

                  // Amount Input
                  LiquidTextField(
                    labelText: 'Budget Amount',
                    hintText: 'Enter budget amount',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value!);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),

                  SizedBox(height: 30.h),

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
                          text: 'Create Budget',
                          gradient: AppTheme.liquidBackground,
                          onPressed: _createBudget,
                          icon: Icons.add_circle_rounded,
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                ],
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.8, 0.8))
          .then()
          .shimmer(
              duration: 1500.ms,
              color: AppTheme.primaryPurple.withOpacity(0.1)),
    );
  }
}
