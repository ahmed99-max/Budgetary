// lib/features/profile_setup/screens/profile_setup_screen.dart
// BATCH 1: UPDATE THIS EXISTING FILE

import 'package:budgetary/features/loan/widgets/add_loan_dialog.dart';
import 'package:budgetary/shared/providers/loan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/city_percentages.dart';
import '../../../shared/providers/auth_provider.dart' as local_auth;
import '../../../shared/providers/user_provider.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/percentage_input.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';

class BudgetCategory {
  final String id;
  final String name;
  final String icon;
  final bool isDefault;
  bool isSelected;
  final bool isUserCustom;

  BudgetCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.isDefault,
    this.isSelected = false,
    this.isUserCustom = false,
  });

  factory BudgetCategory.fromFirestore(DocumentSnapshot doc,
      {required bool isUserCustom}) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetCategory(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? '💰',
      isDefault: data['isDefault'] ?? false,
      isSelected: false,
      isUserCustom: isUserCustom,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'isDefault': isDefault,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

// ENHANCED LOAN MODEL for Profile Setup
class ProfileLoanItem {
  final String id;
  final String name;
  final double totalAmount;
  final double monthlyPayment;
  final DateTime startDate;
  final int totalMonths;

  ProfileLoanItem({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.monthlyPayment,
    required this.startDate,
    required this.totalMonths,
  });

  // Calculate months elapsed from start date
  int get monthsElapsed {
    final now = DateTime.now();
    int diff = (now.year - startDate.year) * 12 + (now.month - startDate.month);
    if (now.day < startDate.day) diff -= 1;
    return diff < 0 ? 0 : diff;
  }

  int get remainingMonths {
    final rem = totalMonths - monthsElapsed;
    return rem < 0 ? 0 : rem;
  }

  double get remainingAmount => remainingMonths * monthlyPayment;

  double get paidAmount => monthsElapsed * monthlyPayment;

  double get progressPercentage =>
      totalMonths > 0 ? (monthsElapsed / totalMonths) * 100 : 0;

  bool get isCompleted => remainingMonths <= 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'totalAmount': totalAmount,
      'monthlyPayment': monthlyPayment,
      'startDate': startDate.toIso8601String(),
      'totalMonths': totalMonths,
    };
  }
}

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _incomeController = TextEditingController();
  final _categoryNameController = TextEditingController();

  String _selectedCountry = 'United States';
  String _selectedCity = 'New York';
  String _selectedCurrency = 'USD';

  List<BudgetCategory> _availableCategories = [];
  Map<String, double> _budgetPercentages = {};
  List<ProfileLoanItem> _loans = []; // UPDATED: Use ProfileLoanItem
  bool _dataLoading = true;
  String? _loadError;

  List<String> get _availableCities => countryCityMap[_selectedCountry] ?? [];
  List<String> get _availableCurrencies =>
      countryCurrencyMap[_selectedCountry] ?? ['USD'];
  List<BudgetCategory> get _selectedCategories =>
      _availableCategories.where((cat) => cat.isSelected).toList();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAllCategories();
  }

  Future<void> _loadAllCategories() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _loadError = 'User not authenticated';
          _dataLoading = false;
        });
        return;
      }

      final globalSnapshot = await FirebaseFirestore.instance
          .collection('budget_categories')
          .orderBy('name')
          .get();

      final globalCategories = globalSnapshot.docs
          .map((doc) => BudgetCategory.fromFirestore(doc, isUserCustom: false))
          .toList();

      final userCustomSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('customCategories')
          .orderBy('name')
          .get();

      final userCustomCategories = userCustomSnapshot.docs
          .map((doc) => BudgetCategory.fromFirestore(doc, isUserCustom: true))
          .toList();

      final merged = [...globalCategories, ...userCustomCategories];
      setState(() {
        _availableCategories = merged;
        for (int i = 0; i < merged.length && i < 6; i++) {
          merged[i].isSelected = true;
        }
        _initializeBudgetPercentages();
        _dataLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = 'Failed to load categories: $e';
        _dataLoading = false;
      });
    }
  }

  void _initializeBudgetPercentages() {
    final selectedCats = _selectedCategories;
    if (selectedCats.isNotEmpty) {
      final equalPercentage = 100.0 / selectedCats.length;
      _budgetPercentages = {
        for (var category in selectedCats) category.name: equalPercentage
      };
    }
  }

  void _redistributePercentages() {
    final selectedCats = _selectedCategories;
    if (selectedCats.isNotEmpty) {
      final equalPercentage = 100.0 / selectedCats.length;
      setState(() {
        _budgetPercentages = {
          for (var category in selectedCats) category.name: equalPercentage
        };
      });
    }
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      setState(() {
        _dataLoading = false;
        _loadError = 'No user ID found. Please log in again.';
      });
      return;
    }

    try {
      await userProvider.loadUserData(uid).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Loading timed out. Please check your connection.');
        },
      );
    } catch (e) {
      setState(() {
        _loadError = 'Failed to load data: $e';
      });
    }
  }

  void _loadCityDefaults() {
    if (cityPercentages.containsKey(_selectedCity)) {
      final cityDefaults = cityPercentages[_selectedCity]!;
      final selectedCats = _selectedCategories;

      setState(() {
        for (var category in selectedCats) {
          if (cityDefaults.containsKey(category.name)) {
            _budgetPercentages[category.name] = cityDefaults[category.name]!;
          }
        }

        final total =
            _budgetPercentages.values.fold(0.0, (sum, val) => sum + val);
        if ((total - 100.0).abs() > 0.1) {
          _redistributePercentages();
        }
      });
    } else {
      _redistributePercentages();
    }
  }

  void _onCountryChanged(String? country) {
    if (country != null) {
      setState(() {
        _selectedCountry = country;
        _selectedCity =
            _availableCities.isNotEmpty ? _availableCities.first : '';
        _selectedCurrency = _availableCurrencies.isNotEmpty
            ? _availableCurrencies.first
            : 'USD';
      });
      _loadCityDefaults();
    }
  }

  void _onCityChanged(String? city) {
    if (city != null) {
      setState(() {
        _selectedCity = city;
      });
      _loadCityDefaults();
    }
  }

  void _onCategorySelectionChanged(BudgetCategory category, bool selected) {
    setState(() {
      category.isSelected = selected;
      if (selected) {
        _budgetPercentages[category.name] = 0.0;
      } else {
        _budgetPercentages.remove(category.name);
      }
      _redistributePercentages();
    });
  }

  double get _totalBudgetPercentage =>
      _budgetPercentages.values.fold(0.0, (sum, value) => sum + value);

  void _updateBudgetPercentage(String categoryName, double newValue) {
    setState(() {
      final oldValue = _budgetPercentages[categoryName] ?? 0.0;
      final delta = newValue - oldValue;
      _budgetPercentages[categoryName] = newValue.clamp(0, 100);

      final otherCategories =
          _budgetPercentages.keys.where((k) => k != categoryName).toList();
      if (otherCategories.isNotEmpty && delta != 0) {
        final totalOther =
            otherCategories.fold(0.0, (sum, k) => sum + _budgetPercentages[k]!);
        if (totalOther > 0) {
          for (var k in otherCategories) {
            final ratio = _budgetPercentages[k]! / totalOther;
            _budgetPercentages[k] =
                (_budgetPercentages[k]! - (delta * ratio)).clamp(0, 100);
          }
        }
        final currentTotal =
            _budgetPercentages.values.fold(0.0, (sum, val) => sum + val);
        if (currentTotal != 100.0) {
          final adjustment = (100.0 - currentTotal) / otherCategories.length;
          for (var k in otherCategories) {
            _budgetPercentages[k] =
                (_budgetPercentages[k]! + adjustment).clamp(0, 100);
          }
        }
      }
    });
  }

  Future<void> _addCustomCategory() async {
    final categoryName = _categoryNameController.text.trim();
    if (categoryName.isEmpty) {
      _showErrorSnackBar('Please enter a category name');
      return;
    }

    if (_availableCategories
        .any((cat) => cat.name.toLowerCase() == categoryName.toLowerCase())) {
      _showErrorSnackBar('Category already exists');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('customCategories')
          .doc();

      final newCategory = BudgetCategory(
        id: docRef.id,
        name: categoryName,
        icon: '💰',
        isDefault: false,
        isSelected: true,
        isUserCustom: true,
      );

      await docRef.set(newCategory.toMap());

      setState(() {
        _availableCategories.add(newCategory);
        _budgetPercentages[categoryName] = 0.0;
        _categoryNameController.clear();
        _redistributePercentages();
      });

      Navigator.of(context).pop();
      _showSuccessSnackBar('Category added successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to add category: $e');
    }
  }

  Future<void> _removeCategory(BudgetCategory category) async {
    if (!category.isUserCustom) {
      _showErrorSnackBar('Cannot remove default categories');
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('customCategories')
          .doc(category.id)
          .delete();

      setState(() {
        _availableCategories.remove(category);
        _budgetPercentages.remove(category.name);
        _redistributePercentages();
      });

      _showSuccessSnackBar('Category removed successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to remove category: $e');
    }
  }

  // ENHANCED ADD LOAN DIALOG
  void _showAddLoanDialog() {
    final _loanNameController = TextEditingController();
    final _loanAmountController = TextEditingController();
    final _monthlyPaymentController = TextEditingController();
    final _tenureController = TextEditingController();
    DateTime _startDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Loan EMI',
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

                      // Loan Name
                      LiquidTextField(
                        labelText: 'Loan Name *',
                        hintText: 'e.g., Home Loan, Car Loan',
                        controller: _loanNameController,
                        prefixIcon: Icons.title,
                      ),
                      SizedBox(height: 16.h),

                      // Total Amount
                      LiquidTextField(
                        labelText: 'Total Loan Amount *',
                        hintText: 'Enter total loan amount',
                        controller: _loanAmountController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.attach_money,
                      ),
                      SizedBox(height: 16.h),

                      // Monthly Payment
                      LiquidTextField(
                        labelText: 'Monthly EMI *',
                        hintText: 'Enter monthly payment',
                        controller: _monthlyPaymentController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.payment,
                      ),
                      SizedBox(height: 16.h),

                      // Tenure in months
                      LiquidTextField(
                        labelText: 'Total Tenure (Months) *',
                        hintText: 'e.g., 240 for 20 years',
                        controller: _tenureController,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.calendar_month,
                      ),
                      SizedBox(height: 16.h),

                      // Start Date Selector
                      Text(
                        'Loan Start Date *',
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
                            initialDate: _startDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              _startDate = picked;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
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
                                DateFormat('dd/MM/yyyy').format(_startDate),
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
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: LiquidButton(
                              text: 'Add Loan',
                              gradient: AppTheme.liquidBackground,
                              onPressed: () => _addLoanFromDialog(
                                _loanNameController,
                                _loanAmountController,
                                _monthlyPaymentController,
                                _tenureController,
                                _startDate,
                              ),
                              icon: Icons.add,
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
      ),
    );
  }

  // ENHANCED LOAN ADDITION WITH PROPER VALIDATION
  void _addLoanFromDialog(
    TextEditingController nameController,
    TextEditingController amountController,
    TextEditingController paymentController,
    TextEditingController tenureController,
    DateTime startDate,
  ) {
    final name = nameController.text.trim();
    final amount = double.tryParse(amountController.text.trim());
    final monthlyPayment = double.tryParse(paymentController.text.trim());
    final tenure = int.tryParse(tenureController.text.trim());

    if (name.isEmpty) {
      _showErrorSnackBar('Please enter loan name');
      return;
    }

    if (amount == null || amount <= 0) {
      _showErrorSnackBar('Please enter valid loan amount');
      return;
    }

    if (monthlyPayment == null || monthlyPayment <= 0) {
      _showErrorSnackBar('Please enter valid monthly payment');
      return;
    }

    if (tenure == null || tenure <= 0) {
      _showErrorSnackBar('Please enter valid tenure in months');
      return;
    }

    setState(() {
      _loans.add(ProfileLoanItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        totalAmount: amount,
        monthlyPayment: monthlyPayment,
        startDate: startDate,
        totalMonths: tenure,
      ));
    });

    Navigator.of(context).pop();
    _showSuccessSnackBar('Loan added successfully');
  }

  void _removeLoan(String id) {
    setState(() {
      _loans.removeWhere((loan) => loan.id == id);
    });
    _showSuccessSnackBar('Loan removed successfully');
  }

  Future<void> _completeSetup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedCategories.isEmpty) {
      _showErrorSnackBar('Please select at least one budget category');
      return;
    }

    final incomeText = _incomeController.text.trim();
    final incomeValue = double.tryParse(incomeText);
    if (incomeValue == null) {
      _showErrorSnackBar('Please enter a valid number for income');
      return;
    }

    final totalPercentage = _totalBudgetPercentage;
    if ((totalPercentage - 100.0).abs() > 0.1) {
      _showErrorSnackBar('Budget percentages must add up to 100%');
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authProvider =
          Provider.of<local_auth.AuthProvider>(context, listen: false);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _showErrorSnackBar('User not authenticated');
        return;
      }

      // Calculate total loan EMI
      double totalLoanEMI = 0.0;
      for (var loan in _loans) {
        totalLoanEMI += loan.monthlyPayment;
      }

      // Available income after loan deduction
      final availableIncome = incomeValue - totalLoanEMI;

      // Prepare user categories
      final userCategories = _selectedCategories
          .map((cat) => {
                'id': cat.id,
                'name': cat.name,
                'icon': cat.icon,
                'percentage': _budgetPercentages[cat.name] ?? 0.0,
                'isCustom': cat.isUserCustom,
              })
          .toList();

      // Update user profile
      final success = await userProvider.completeProfileSetup(
        phoneNumber: _phoneController.text.trim(),
        country: _selectedCountry,
        city: _selectedCity,
        currency: _selectedCurrency,
        monthlyIncome: incomeValue,
        budgetCategories: _budgetPercentages,
        emiLoans: _loans.map((loan) => loan.toMap()).toList(),
        investments: [],
        loanProvider: LoanProvider(),
      );

      if (!success) {
        _showErrorSnackBar(
            userProvider.errorMessage ?? 'Failed to update profile');
        return;
      }

      // Store user's selected categories
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'selectedCategories': userCategories,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Auto-create budgets for selected categories and aggregated loan
      final batch = FirebaseFirestore.instance.batch();
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);

      // Create budgets for categories (using availableIncome)
      for (final category in _selectedCategories) {
        final budgetDoc =
            FirebaseFirestore.instance.collection('budgets').doc();
        final percentage = _budgetPercentages[category.name] ?? 0.0;
        final allocatedAmount = (percentage / 100) * availableIncome;

        batch.set(budgetDoc, {
          'id': budgetDoc.id,
          'userId': uid,
          'category': category.name,
          'categoryId': category.id,
          'allocatedAmount': allocatedAmount,
          'spentAmount': 0.0,
          'period': 'Monthly',
          'startDate': Timestamp.fromDate(startDate),
          'endDate': Timestamp.fromDate(endDate),
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Create single aggregated "Loan EMIs" budget if loans exist
      if (totalLoanEMI > 0) {
        final loanBudgetDoc =
            FirebaseFirestore.instance.collection('budgets').doc();
        batch.set(loanBudgetDoc, {
          'id': loanBudgetDoc.id,
          'userId': uid,
          'category': 'Loan EMIs',
          'categoryId': 'loan_aggregated',
          'allocatedAmount': totalLoanEMI,
          'spentAmount': 0.0,
          'period': 'Monthly',
          'startDate': Timestamp.fromDate(startDate),
          'endDate': Timestamp.fromDate(endDate),
          'isActive': true,
          'isLoan': true,
          'isLoanCategory': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      print("✅ BATCH COMMITTED SUCCESSFULLY");
      print("📝 Created budgets for user: $uid");
      print(
          "📊 Selected categories: ${_selectedCategories.map((c) => c.name).toList()}");
      print("💰 Total loan EMI: $totalLoanEMI");

      // Complete auth setup
      await authProvider.completeProfileSetup();
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        context.go('/dashboard'); // Navigate to dashboard
      }
    } catch (e) {
      _showErrorSnackBar('Setup failed: $e');
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Custom Category'),
        content: LiquidTextField(
          controller: _categoryNameController,
          labelText: 'Category Name',
          hintText: 'Enter category name',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: _addCustomCategory,
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ENHANCED LOAN DETAIL ITEM HELPER
  Widget _buildLoanDetailItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: color ?? Colors.white70,
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _incomeController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, local_auth.AuthProvider, LoanProvider>(
      builder: (context, userProvider, authProvider, loanProvider, _) {
        if (_dataLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  if (_loadError != null) ...[
                    SizedBox(height: 20.h),
                    Text(_loadError!,
                        style: const TextStyle(color: Colors.red)),
                    SizedBox(height: 10.h),
                    ElevatedButton(
                      onPressed: () {
                        _loadUserData();
                        _loadAllCategories();
                      },
                      child: const Text('Retry'),
                    ),
                  ]
                ],
              ),
            ),
          );
        }

        if (!userProvider.hasUser) {
          return Scaffold(
            body:
                Center(child: Text('No user data found. Please log in again.')),
          );
        }

        return LoadingOverlay(
          isLoading: userProvider.isLoading,
          message: 'Setting up your profile...',
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration:
                  const BoxDecoration(gradient: AppTheme.liquidBackground),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 40.h),

                        // Progress indicator
                        Container(
                          width: double.infinity,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3.r),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.8,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.8)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .slideX(begin: -1, end: 0),
                        SizedBox(height: 40.h),

                        // Welcome text
                        Text(
                          'Almost There! 🎯',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .slideY(begin: -0.3, end: 0),

                        SizedBox(height: 12.h),

                        Text(
                          'Let\'s personalize your financial dashboard',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 800.ms)
                            .slideY(begin: -0.2, end: 0),

                        SizedBox(height: 40.h),

                        // Basic Information
                        LiquidCard(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Basic Information',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 20.h),

                              LiquidTextField(
                                labelText: 'Phone Number',
                                hintText: 'Enter your phone number',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                prefixIcon: Icons.phone_outlined,
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 20.h),

                              // Country dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedCountry,
                                decoration: InputDecoration(
                                  labelText: 'Country',
                                  filled: true,
                                  fillColor: AppTheme.cardGradient.colors.first
                                      .withOpacity(0.2),
                                ),
                                items: countryCityMap.keys
                                    .map((country) => DropdownMenuItem(
                                          value: country,
                                          child: Text(country),
                                        ))
                                    .toList(),
                                onChanged: _onCountryChanged,
                              ),
                              SizedBox(height: 20.h),

                              // Currency dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedCurrency,
                                decoration: InputDecoration(
                                  labelText: 'Currency',
                                  filled: true,
                                  fillColor: AppTheme.cardGradient.colors.first
                                      .withOpacity(0.2),
                                ),
                                items: _availableCurrencies
                                    .map((currency) => DropdownMenuItem(
                                          value: currency,
                                          child: Text(currency),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedCurrency = val);
                                  }
                                },
                              ),
                              SizedBox(height: 20.h),

                              // City dropdown
                              DropdownButtonFormField<String>(
                                value: _selectedCity,
                                decoration: InputDecoration(
                                  labelText: 'City',
                                  filled: true,
                                  fillColor: AppTheme.cardGradient.colors.first
                                      .withOpacity(0.2),
                                ),
                                items: _availableCities
                                    .map((city) => DropdownMenuItem(
                                          value: city,
                                          child: Text(city),
                                        ))
                                    .toList(),
                                onChanged: _onCityChanged,
                              ),
                              SizedBox(height: 20.h),
                              LiquidTextField(
                                labelText: 'Monthly Income',
                                hintText: 'Enter your monthly income',
                                controller: _incomeController,
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.attach_money_outlined,
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Please enter your monthly income';
                                  }
                                  if (double.tryParse(value!.trim()) == null) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 400.ms, duration: 1000.ms)
                            .slideY(begin: 0.3, end: 0),

                        SizedBox(height: 30.h),

                        // Budget Categories Selection
                        LiquidCard(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Select Budget Categories',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _showAddCategoryDialog,
                                    child: Text(
                                      'Add Custom',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),

                              Text(
                                'Choose categories that match your spending habits',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              SizedBox(height: 20.h),

                              // Categories grid
                              Wrap(
                                spacing: 12.w,
                                runSpacing: 12.h,
                                children: _availableCategories.map((category) {
                                  return GestureDetector(
                                    onTap: () => _onCategorySelectionChanged(
                                        category, !category.isSelected),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 8.h),
                                      decoration: BoxDecoration(
                                        gradient: category.isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  AppTheme.primaryBlue,
                                                  AppTheme.primaryPurple,
                                                ],
                                              )
                                            : LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.1),
                                                  Colors.white
                                                      .withOpacity(0.05),
                                                ],
                                              ),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                        border: Border.all(
                                          color: category.isSelected
                                              ? Colors.transparent
                                              : Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(category.icon,
                                              style:
                                                  TextStyle(fontSize: 16.sp)),
                                          SizedBox(width: 6.w),
                                          Text(
                                            category.name,
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          if (category.isUserCustom) ...[
                                            SizedBox(width: 6.w),
                                            GestureDetector(
                                              onTap: () =>
                                                  _removeCategory(category),
                                              child: Icon(
                                                Icons.close,
                                                size: 14.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 1000.ms)
                            .slideY(begin: 0.3, end: 0),

                        SizedBox(height: 30.h),

                        // Budget Percentages
                        if (_selectedCategories.isNotEmpty) ...[
                          LiquidCard(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Budget Distribution',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _redistributePercentages,
                                      child: Text(
                                        'Reset',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    color:
                                        (_totalBudgetPercentage - 100.0).abs() <
                                                0.1
                                            ? Colors.green
                                            : Colors.orange,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    'Total: ${_totalBudgetPercentage.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Column(
                                  children: _selectedCategories.map((category) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 20.h),
                                      child: PercentageInput(
                                        initialValue:
                                            _budgetPercentages[category.name] ??
                                                0.0,
                                        label:
                                            '${category.icon} ${category.name}',
                                        onChanged: (value) =>
                                            _updateBudgetPercentage(
                                                category.name, value),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 600.ms, duration: 1000.ms)
                              .slideY(begin: 0.3, end: 0),
                          SizedBox(height: 30.h),
                        ],

                        // ENHANCED LOANS & EMIs SECTION
                        LiquidCard(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Loans & EMIs',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _showAddLoanDialog,
                                    child: Text(
                                      'Add Loan',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.greenAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              if (_loans.isEmpty)
                                Container(
                                  padding: EdgeInsets.all(20.h),
                                  child: Center(
                                    child: Text(
                                      'No loans added yet',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                // ENHANCED LOAN DISPLAY CARDS
                                Column(
                                  children: _loans.map((loan) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12.h),
                                      padding: EdgeInsets.all(16.w),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.primaryPurple
                                                .withOpacity(0.8),
                                            AppTheme.primaryBlue
                                                .withOpacity(0.6),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryPurple
                                                .withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  loan.name,
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 8.w,
                                                      vertical: 4.h,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.r),
                                                    ),
                                                    child: Text(
                                                      '${loan.progressPercentage.toStringAsFixed(1)}%',
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  IconButton(
                                                    onPressed: () =>
                                                        _removeLoan(loan.id),
                                                    icon: Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.white70,
                                                      size: 20.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12.h),

                                          // Progress Bar
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6.r),
                                            child: LinearProgressIndicator(
                                              value: (loan.progressPercentage /
                                                      100)
                                                  .clamp(0.0, 1.0),
                                              minHeight: 6.h,
                                              backgroundColor:
                                                  Colors.white.withOpacity(0.3),
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                loan.isCompleted
                                                    ? Colors.greenAccent
                                                    : Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 12.h),

                                          // Loan Details Grid
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildLoanDetailItem(
                                                  'Total Amount',
                                                  '$_selectedCurrency ${NumberFormat('#,##0').format(loan.totalAmount)}',
                                                  Icons.account_balance_wallet,
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: _buildLoanDetailItem(
                                                  'Monthly EMI',
                                                  '$_selectedCurrency ${NumberFormat('#,##0').format(loan.monthlyPayment)}',
                                                  Icons.payment,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8.h),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildLoanDetailItem(
                                                  'Paid So Far',
                                                  '$_selectedCurrency ${NumberFormat('#,##0').format(loan.paidAmount)}',
                                                  Icons.trending_up,
                                                  color: Colors.greenAccent,
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: _buildLoanDetailItem(
                                                  'Remaining',
                                                  '$_selectedCurrency ${NumberFormat('#,##0').format(loan.remainingAmount)}',
                                                  Icons.pending_actions,
                                                  color: Colors.orangeAccent,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8.h),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildLoanDetailItem(
                                                  'Months Elapsed',
                                                  '${loan.monthsElapsed} months',
                                                  Icons.calendar_today,
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: _buildLoanDetailItem(
                                                  'Remaining Months',
                                                  '${loan.remainingMonths} months',
                                                  Icons.schedule,
                                                  color: loan.isCompleted
                                                      ? Colors.greenAccent
                                                      : Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 700.ms, duration: 1000.ms)
                            .slideY(begin: 0.3, end: 0),

                        SizedBox(height: 40.h),
                        LiquidButton(
                          text: 'Complete Setup',
                          gradient: LinearGradient(
                            colors: (_selectedCategories.isNotEmpty &&
                                    (_totalBudgetPercentage - 100.0).abs() <
                                        0.1)
                                ? [
                                    Colors.greenAccent,
                                    Colors.greenAccent.withOpacity(0.7)
                                  ]
                                : [
                                    Colors.grey.withOpacity(0.5),
                                    Colors.grey.withOpacity(0.3)
                                  ],
                          ),
                          onPressed: (_selectedCategories.isNotEmpty &&
                                  (_totalBudgetPercentage - 100.0).abs() < 0.1)
                              ? _completeSetup
                              : null,
                          icon: Icons.check_circle_rounded,
                        )
                            .animate()
                            .fadeIn(delay: 800.ms, duration: 800.ms)
                            .slideY(begin: 0.3, end: 0),

                        if (_selectedCategories.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 16.h),
                            child: Text(
                              'Please select at least one budget category',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange,
                              ),
                            ),
                          )
                        else if ((_totalBudgetPercentage - 100.0).abs() >= 0.1)
                          Padding(
                            padding: EdgeInsets.only(top: 16.h),
                            child: Text(
                              'Budget percentages must add up to exactly 100%',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.orange,
                              ),
                            ),
                          ),

                        SizedBox(height: 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
