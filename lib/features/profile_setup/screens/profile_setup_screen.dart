// lib/features/profile_setup/screens/profile_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _incomeController = TextEditingController();

  String _selectedCountry = 'United States';
  String _selectedCity = 'New York';
  String _selectedCurrency = 'USD';

  final List<String> _emiLoans = <String>[];
  final List<String> _investments = <String>[];

  late Map<String, double> _budgetCategories;

  List<String> get _availableCities => countryCityMap[_selectedCountry] ?? [];
  List<String> get _availableCurrencies =>
      countryCurrencyMap[_selectedCountry] ?? ['USD'];

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<UserProvider>(context, listen: false).loadUserData(uid);
      });
    }
    _initializeBudgetCategories();
  }

  void _initializeBudgetCategories() {
    final categories = AppConfig.defaultCategories.keys.toList();
    final equalPercentage = 100.0 / categories.length;
    _budgetCategories = {
      for (var category in categories) category: equalPercentage
    };
  }

  void _loadCityDefaults() {
    if (cityPercentages.containsKey(_selectedCity)) {
      setState(() {
        _budgetCategories =
            Map<String, double>.from(cityPercentages[_selectedCity]!);
      });
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
        _loadCityDefaults();
      });
    }
  }

  void _onCityChanged(String? city) {
    if (city != null) {
      setState(() {
        _selectedCity = city;
        _loadCityDefaults();
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  double get _totalBudgetPercentage =>
      _budgetCategories.values.fold(0.0, (sum, value) => sum + value);

  void _distributeBudgetEqually() {
    setState(() {
      _initializeBudgetCategories();
    });
  }

  void _updateBudgetCategory(String category, double newValue) {
    setState(() {
      final oldValue = _budgetCategories[category]!;
      final delta = newValue - oldValue;

      // Update the changed category
      _budgetCategories[category] = newValue;

      // Redistribute the difference among other categories
      final otherCategories =
          _budgetCategories.keys.where((k) => k != category).toList();
      if (otherCategories.isNotEmpty && delta != 0) {
        final totalOther = otherCategories.fold<double>(
            0, (sum, k) => sum + _budgetCategories[k]!);

        if (totalOther > 0) {
          for (var k in otherCategories) {
            final ratio = _budgetCategories[k]! / totalOther;
            _budgetCategories[k] =
                (_budgetCategories[k]! - (delta * ratio)).clamp(0, 50);
          }
        }
      }

      // Ensure total is exactly 100%
      final currentTotal =
          _budgetCategories.values.fold<double>(0, (sum, val) => sum + val);
      if (currentTotal != 100.0) {
        final adjustment = (100.0 - currentTotal) / otherCategories.length;
        for (var k in otherCategories) {
          _budgetCategories[k] =
              (_budgetCategories[k]! + adjustment).clamp(0, 50);
        }
      }
    });
  }

  Future<void> _completeSetup() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

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

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider =
        Provider.of<local_auth.AuthProvider>(context, listen: false);

    final success = await userProvider.completeProfileSetup(
      phoneNumber: _phoneController.text.trim(),
      country: _selectedCountry,
      city: _selectedCity,
      currency: _selectedCurrency,
      monthlyIncome: incomeValue,
      budgetCategories: _budgetCategories,
      emiLoans: _emiLoans,
      investments: _investments,
    );

    if (success && mounted) {
      await authProvider.completeProfileSetup();
      context.go('/dashboard');
    } else if (mounted) {
      _showErrorSnackBar(userProvider.errorMessage ?? 'Setup failed');
    }
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, local_auth.AuthProvider>(
      builder: (context, userProvider, authProvider, _) {
        if (userProvider.isLoading || !userProvider.hasUser) {
          return const Center(child: CircularProgressIndicator());
        }
        return LoadingOverlay(
          isLoading: userProvider.isLoading,
          message: 'Setting up your profile...',
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTheme.liquidBackground,
              ),
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
                                gradient: const LinearGradient(
                                  colors: [Colors.white, Colors.white70],
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

                              // Full-width Country dropdown
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

                              // Full-width Currency dropdown
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
                                  if (val != null)
                                    setState(() => _selectedCurrency = val);
                                },
                              ),
                              SizedBox(height: 20.h),

                              // Full-width City dropdown
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

                        // Budget Categories with new PercentageInput widget
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
                                    'Budget Categories',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _distributeBudgetEqually,
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

                              // Total percentage display
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
                                // child: Row(
                                //   mainAxisAlignment:
                                //       MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     Text(
                                //       'Total Allocation:',
                                //       style: TextStyle(
                                //         fontSize: 14.sp,
                                //         fontWeight: FontWeight.w600,
                                //         color: Colors.white.withOpacity(0.9),
                                //       ),
                                //     ),
                                //     Text(
                                //       '${_totalBudgetPercentage.toStringAsFixed(1)}%',
                                //       style: TextStyle(
                                //         fontSize: 16.sp,
                                //         fontWeight: FontWeight.w700,
                                //         color: (_totalBudgetPercentage - 100.0)
                                //                     .abs() <
                                //                 0.1
                                //             ? Colors.green
                                //             : Colors.orange,
                                //       ),
                                //     ),
                                //   ],
                                // ),
                              ),

                              SizedBox(height: 20.h),

                              // Category inputs with new PercentageInput widget
                              Column(
                                children:
                                    _budgetCategories.entries.map((entry) {
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 20.h),
                                    child: PercentageInput(
                                      initialValue: entry.value,
                                      label:
                                          '${AppConfig.defaultCategories[entry.key] ?? '💰'} ${entry.key}',
                                      onChanged: (value) =>
                                          _updateBudgetCategory(
                                              entry.key, value),
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

                        SizedBox(height: 40.h),

                        // Complete setup button
                        LiquidButton(
                          text: 'Complete Setup',
                          gradient: LinearGradient(
                            colors: [
                              (_totalBudgetPercentage - 100.0).abs() < 0.1
                                  ? Colors.greenAccent
                                  : Colors.grey.withOpacity(0.5),
                              (_totalBudgetPercentage - 100.0).abs() < 0.1
                                  ? Colors.greenAccent.withOpacity(0.7)
                                  : Colors.grey.withOpacity(0.3),
                            ],
                          ),
                          onPressed:
                              (_totalBudgetPercentage - 100.0).abs() < 0.1
                                  ? _completeSetup
                                  : null,
                          icon: Icons.check_circle_rounded,
                        )
                            .animate()
                            .fadeIn(delay: 800.ms, duration: 800.ms)
                            .slideY(begin: 0.3, end: 0),

                        if ((_totalBudgetPercentage - 100.0).abs() >= 0.1)
                          Padding(
                            padding: EdgeInsets.only(top: 16.h),
                            child: Text(
                              'Please ensure your budget categories add up to exactly 100%',
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
