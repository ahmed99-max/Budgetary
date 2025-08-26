// lib/features/budget/widgets/add_budget_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/providers/budget_provider.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/models/budget_model.dart';

class AddBudgetDialog extends StatefulWidget {
  final VoidCallback onBudgetCreated;
  final BudgetModel? initialBudget;

  const AddBudgetDialog({
    super.key,
    required this.onBudgetCreated,
    this.initialBudget,
  });

  @override
  State<AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();
  String? _selectedCategory;
  String _selectedPeriod = 'Monthly';
  bool _showCustomCategory = false;
  String? _warningMessage;
  String? _budgetStatusMessage;
  bool _isEditMode = false;
  double _availableBudget = 0.0;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.initialBudget != null;
    if (_isEditMode) {
      final b = widget.initialBudget!;
      _selectedCategory = b.category;
      _selectedPeriod = b.period;
      _amountController.text = b.allocatedAmount.toStringAsFixed(0);
      _showCustomCategory =
          !AppConfig.defaultCategories.containsKey(b.category);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBudgetStatus();
      if (!_isEditMode) _prefillAmount();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  void _prefillAmount() {
    if (_selectedCategory != null && !_isEditMode) {
      final bp = Provider.of<BudgetProvider>(context, listen: false);
      final existing = bp.getBudgetByCategory(_selectedCategory!);
      if (existing != null) {
        _amountController.text = existing.allocatedAmount.toStringAsFixed(0);
        _updateBudgetStatus();
      }
    }
  }

  void _onCategoryChanged(String? v) {
    setState(() {
      _selectedCategory = v;
      _showCustomCategory = v == 'Other';
      _warningMessage = null;
      if (!_isEditMode && v != null && v != 'Other') {
        final bp = Provider.of<BudgetProvider>(context, listen: false);
        final existing = bp.getBudgetByCategory(v);
        _amountController.text =
            existing?.allocatedAmount.toStringAsFixed(0) ?? '';
      }
      if (_showCustomCategory) {
        _customCategoryController.clear();
        _amountController.clear();
      }
    });
    _updateBudgetStatus();
  }

  void _updateBudgetStatus() {
    final up = Provider.of<UserProvider>(context, listen: false);
    final bp = Provider.of<BudgetProvider>(context, listen: false);
    final income = up.user?.monthlyIncome ?? 0.0;
    final amt = double.tryParse(_amountController.text) ?? 0.0;
    final exclude =
        _isEditMode ? widget.initialBudget!.category : _selectedCategory;
    _availableBudget = bp.getAvailableBudgetAmount(income, exclude);
    setState(() {
      if (amt > _availableBudget && _availableBudget > 0) {
        final over = amt - _availableBudget;
        _warningMessage =
            'Over budget by ${up.user!.currency} ${over.toStringAsFixed(0)}!';
        _budgetStatusMessage =
            'Budget exceeded! Available: ${up.user!.currency} ${_availableBudget.toStringAsFixed(0)}';
      } else if (amt > 0) {
        final rem = _availableBudget - amt;
        _warningMessage = null;
        _budgetStatusMessage =
            'Remaining budget: ${up.user!.currency} ${rem.toStringAsFixed(0)}';
      } else {
        _warningMessage = null;
        _budgetStatusMessage =
            'Available budget: ${up.user!.currency} ${_availableBudget.toStringAsFixed(0)}';
      }
    });
  }

  bool _canSave() {
    final amt = double.tryParse(_amountController.text) ?? 0.0;
    return amt > 0 && amt <= _availableBudget;
  }

  Future<void> _saveBudget() async {
    if (_formKey.currentState?.validate() ?? false) {
      final bp = Provider.of<BudgetProvider>(context, listen: false);
      final up = Provider.of<UserProvider>(context, listen: false);
      final amt = double.tryParse(_amountController.text) ?? 0.0;
      if (!_canSave()) {
        setState(() => _warningMessage = 'Cannot save: exceeds limit');
        return;
      }
      final cat = (_selectedCategory == 'Other'
              ? _customCategoryController.text.trim()
              : _selectedCategory) ??
          '';
      if (cat.isEmpty) {
        setState(() => _warningMessage = 'Category required');
        return;
      }
      bool success;
      if (_isEditMode) {
        final u = widget.initialBudget!.copyWith(
          allocatedAmount: amt,
          period: _selectedPeriod,
          updatedAt: DateTime.now(),
        );
        success = await bp.updateBudget(u);
      } else {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        success = await bp.createBudget(
          category: cat,
          allocatedAmount: amt,
          period: _selectedPeriod,
          startDate: start,
          endDate: end,
        );
      }
      if (success && mounted) {
        Navigator.of(context).pop();
        widget.onBudgetCreated();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Budget saved!'),
          backgroundColor: Colors.green,
        ));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(bp.errorMessage ?? 'Save failed'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // categories list
    final defaults = AppConfig.defaultCategories.keys.toList();
    final bp = Provider.of<BudgetProvider>(context, listen: false);
    final customs = bp
        .getAllBudgetCategories()
        .where((c) => !AppConfig.defaultCategories.containsKey(c))
        .toList();
    final cats = [...defaults, ...customs, 'Other'];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: LiquidCard(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditMode ? 'Edit Budget' : 'Add New Budget',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),
              SizedBox(height: 16.h),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Category
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Category',
                          style: TextStyle(
                              fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(height: 8.h),
                    if (_isEditMode)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          gradient: AppTheme.cardGradient,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(_selectedCategory ?? ''),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          gradient: AppTheme.cardGradient,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedCategory,
                            hint: Text('Select category'),
                            items: cats
                                .map((c) =>
                                    DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: _onCategoryChanged,
                          ),
                        ),
                      ),
                    if (_showCustomCategory) ...[
                      SizedBox(height: 16.h),
                      LiquidTextField(
                        labelText: 'Custom Category',
                        controller: _customCategoryController,
                        validator: (v) =>
                            v?.trim().isEmpty ?? true ? 'Required' : null,
                      ),
                    ],
                    SizedBox(height: 16.h),
                    LiquidTextField(
                      labelText: 'Amount',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      onChanged: (_) => _updateBudgetStatus(),
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Required';
                        final num = double.tryParse(v!);
                        if (num == null || num <= 0) return 'Invalid';
                        return null;
                      },
                    ),
                    if (_budgetStatusMessage != null) ...[
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(8.h),
                        decoration: BoxDecoration(
                          color: _warningMessage != null
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _warningMessage != null
                                  ? Icons.warning
                                  : Icons.check_circle,
                              color: _warningMessage != null
                                  ? Colors.red
                                  : Colors.green,
                              size: 16.sp,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                _budgetStatusMessage!,
                                style: TextStyle(
                                  color: _warningMessage != null
                                      ? Colors.red
                                      : Colors.green,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_warningMessage != null) ...[
                      SizedBox(height: 8.h),
                      Text(_warningMessage!,
                          style: TextStyle(color: Colors.red)),
                    ],
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
                            text: _isEditMode ? 'Update' : 'Create',
                            gradient: _canSave()
                                ? AppTheme.liquidBackground
                                : LinearGradient(
                                    colors: [Colors.grey, Colors.grey]),
                            onPressed: _canSave() ? _saveBudget : null,
                            icon: Icons.check_circle_outline,
                          ),
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideY(begin: 0.3, end: 0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8));
  }
}
