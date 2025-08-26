// lib/features/auth/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../../../shared/widgets/liquid_text_field.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/loading_overlay.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v?.trim().isEmpty ?? true) return 'Full name is required';
    if (v!.trim().length < 2) return 'Name must be at least 2 characters';
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(v.trim()))
      return 'Letters and spaces only';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v?.trim().isEmpty ?? true) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v!.trim()))
      return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v?.isEmpty ?? true) return 'Password is required';
    if (v!.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(v)) return 'One uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(v)) return 'One lowercase letter';
    if (!RegExp(r'\d').hasMatch(v)) return 'One number';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v?.isEmpty ?? true) return 'Confirm your password';
    if (v != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _signup() async {
    // Always allow signup attempt, but validate first
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Show validation errors
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.signUpWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );

    if (success && mounted) {
      context.go('/profile-setup');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(auth.errorMessage ?? 'Registration failed'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, auth, _) {
      return LoadingOverlay(
          isLoading: auth.isLoading,
          message: 'Creating account...',
          child: Scaffold(
            body: Container(
              decoration:
                  const BoxDecoration(gradient: AppTheme.liquidBackground),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.arrow_back_ios,
                              color: Colors.white, size: 24.sp),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),
                      SizedBox(height: 20.h),
                      Text(
                        'Create Account 🚀',
                        style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 800.ms)
                          .slideY(begin: -0.3, end: 0),
                      SizedBox(height: 8.h),
                      Text(
                        'Join us and start managing your finances',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white.withOpacity(0.9)),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 800.ms)
                          .slideY(begin: -0.2, end: 0),
                      SizedBox(height: 40.h),
                      LiquidCard(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sign Up',
                                  style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w700)),
                              SizedBox(height: 24.h),
                              LiquidTextField(
                                labelText: 'Full Name',
                                controller: _nameController,
                                prefixIcon: Icons.person_outline,
                                validator: _validateName,
                              )
                                  .animate()
                                  .fadeIn(delay: 600.ms, duration: 600.ms)
                                  .slideX(begin: -0.3, end: 0),
                              SizedBox(height: 20.h),
                              LiquidTextField(
                                labelText: 'Email Address',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                validator: _validateEmail,
                              )
                                  .animate()
                                  .fadeIn(delay: 700.ms, duration: 600.ms)
                                  .slideX(begin: -0.3, end: 0),
                              SizedBox(height: 20.h),
                              LiquidTextField(
                                labelText: 'Password',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                prefixIcon: Icons.lock_outline,
                                suffixIcon: _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                onSuffixTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                validator: _validatePassword,
                              )
                                  .animate()
                                  .fadeIn(delay: 800.ms, duration: 600.ms)
                                  .slideX(begin: -0.3, end: 0),
                              SizedBox(height: 20.h),
                              LiquidTextField(
                                labelText: 'Confirm Password',
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                prefixIcon: Icons.lock_outline,
                                suffixIcon: _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                onSuffixTap: () => setState(() =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword),
                                validator: _validateConfirm,
                              )
                                  .animate()
                                  .fadeIn(delay: 900.ms, duration: 600.ms)
                                  .slideX(begin: -0.3, end: 0),
                              SizedBox(height: 30.h),
                              // Button is ALWAYS active now
                              LiquidButton(
                                text: 'Create Account',
                                gradient: AppTheme
                                    .liquidBackground, // Always same gradient
                                onPressed: _signup, // Always callable
                                icon: Icons.person_add_rounded,
                              )
                                  .animate()
                                  .fadeIn(delay: 1000.ms, duration: 600.ms)
                                  .slideY(begin: 0.3, end: 0),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),
                      SizedBox(height: 30.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have an account? ",
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white.withOpacity(0.8))),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text('Sign In',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                          ),
                        ],
                      ).animate().fadeIn(delay: 1100.ms, duration: 600.ms),
                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ),
            ),
          ));
    });
  }
}
