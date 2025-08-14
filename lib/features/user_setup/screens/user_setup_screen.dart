import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../shared/widgets/modern_text_field.dart';
import '../../../shared/widgets/modern_button.dart';
import '../../../shared/widgets/loading_overlay.dart';

class UserSetupScreen extends StatefulWidget {
  const UserSetupScreen({super.key});

  @override
  State<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends State<UserSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _incomeController = TextEditingController();
  String _selectedCountry = 'United States';
  String _selectedCurrency = 'USD';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context);

    return LoadingOverlay(
      isLoading: userProvider.isLoading,
      message: 'Saving your profile...',
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F9FE),
          elevation: 0,
          title: Text('Complete Your Profile',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tell us about yourself 👋',
                      style: GoogleFonts.inter(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D3748))),
                  SizedBox(height: 32.h),
                  ModernTextField(
                    hintText:
                        'Enter your age', // Replaced 'labelText' with 'hintText'
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    icon: Icons
                        .cake_outlined, // Replaced 'prefixIcon' with 'icon' (based on widget definition)
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'Please enter your age';
                      final age = int.tryParse(value!);
                      if (age == null || age <= 0)
                        return 'Please enter a valid age';
                      return null;
                    },
                  ),
                  SizedBox(height: 24.h),
                  ModernTextField(
                    hintText:
                        'Enter your monthly income', // Replaced 'labelText' with 'hintText'
                    controller: _incomeController,
                    keyboardType: TextInputType.number,
                    icon: Icons
                        .attach_money_outlined, // Replaced 'prefixIcon' with 'icon'
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'Please enter your income';
                      final income = double.tryParse(value!);
                      if (income == null || income <= 0)
                        return 'Please enter a valid income';
                      return null;
                    },
                  ),
                  SizedBox(height: 32.h),
                  ModernButton(
                    text: 'Save & Continue',
                    isLoading: userProvider.isLoading,
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final success = await userProvider.saveUserSetup(
                          userId: authProvider.uid,
                          name: authProvider.displayName,
                          email: authProvider.email,
                          age: int.parse(_ageController.text),
                          monthlyIncome: double.parse(_incomeController.text),
                          country: _selectedCountry,
                          currency: _selectedCurrency,
                          emiLoans: [], // From your code; adjust as needed
                          budgetPercentages: {
                            'Food': 30.0,
                            'Transport': 20.0,
                            'Entertainment': 15.0,
                            'Bills': 25.0,
                            'Savings': 10.0
                          }, // From your code
                        );
                        if (success && mounted) {
                          context.go('/dashboard');
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
