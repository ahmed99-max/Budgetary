import 'package:budgetary/features/loan/widgets/add_loan_dialog.dart';
import 'package:budgetary/shared/providers/loan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class LoanEMI {
  final String id;
  final String name;
  final double amount;
  final double monthlyPayment;
  final int remainingMonths;

  LoanEMI({
    required this.id,
    required this.name,
    required this.amount,
    required this.monthlyPayment,
    required this.remainingMonths,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'monthlyPayment': monthlyPayment,
      'remainingMonths': remainingMonths,
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
  final _loanNameController = TextEditingController();
  final _loanAmountController = TextEditingController();
  final _monthlyPaymentController = TextEditingController();
  final _remainingMonthsController = TextEditingController();

  String _selectedCountry = 'United States';
  String _selectedCity = 'New York';
  String _selectedCurrency = 'USD';

  List<BudgetCategory> _availableCategories = [];
  Map<String, double> _budgetPercentages = {};
  List<LoanEMI> _loans = [];
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

  void _addLoan() {
    final name = _loanNameController.text.trim();
    final amount = double.tryParse(_loanAmountController.text);
    final monthlyPayment = double.tryParse(_monthlyPaymentController.text);
    final remainingMonths = int.tryParse(_remainingMonthsController.text);

    if (name.isEmpty ||
        amount == null ||
        monthlyPayment == null ||
        remainingMonths == null) {
      _showErrorSnackBar('Please fill all loan details correctly');
      return;
    }

    setState(() {
      _loans.add(LoanEMI(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        amount: amount,
        monthlyPayment: monthlyPayment,
        remainingMonths: remainingMonths,
      ));
      _loanNameController.clear();
      _loanAmountController.clear();
      _monthlyPaymentController.clear();
      _remainingMonthsController.clear();
    });

    Navigator.of(context).pop();
    _showSuccessSnackBar('Loan added successfully');
  }

  void _removeLoan(String id) {
    setState(() {
      _loans.removeWhere((loan) => loan.id == id);
    });
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
        loanProvider: LoanProvider(), // FIXED: Pass the provider here
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
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch
          .commit(); // FIXED: Ensure no extra positional arguments here (expects 0)

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

  void _showAddLoanDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AddLoanDialog(
        // This is the enhanced dialog from add_loan_dialog.dart
        onLoanUpdated: () {
          // Optional: Refresh any UI after adding (e.g., reload loans list)
          setState(() {
            // Assuming you have _loans as List<LoanEMI> in your state
            // Add the new loan to local list (customize based on your LoanEMI model)
            _loans.add(LoanEMI(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: _loanNameController.text
                  .trim(), // If you still have these controllers
              amount: double.tryParse(_loanAmountController.text) ?? 0,
              monthlyPayment:
                  double.tryParse(_monthlyPaymentController.text) ?? 0,
              remainingMonths:
                  int.tryParse(_remainingMonthsController.text) ?? 0,
            ));
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Loan added successfully'),
                backgroundColor: Colors.green),
          );
        },
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

  @override
  void dispose() {
    _phoneController.dispose();
    _incomeController.dispose();
    _categoryNameController.dispose();
    _loanNameController.dispose();
    _loanAmountController.dispose();
    _monthlyPaymentController.dispose();
    _remainingMonthsController.dispose();
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

                        // Loans & EMIs Section
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
                                Column(
                                  children: _loans.map((loan) {
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 12.h),
                                      padding: EdgeInsets.all(12.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadius.circular(8.r),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  loan.name,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  'EMI: $_selectedCurrency ${loan.monthlyPayment.toStringAsFixed(0)} | ${loan.remainingMonths} months left',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.white
                                                        .withOpacity(0.8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _removeLoan(loan.id),
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: Colors.redAccent,
                                              size: 20.sp,
                                            ),
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
