// lib/features/auth/screens/login_screen.dart
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return 'Email is required';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.trim().isEmpty ?? true) {
      return 'Password is required';
    }
    if (value!.trim().length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _login() async {
    // Always allow login attempt, but validate first
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // Show validation errors
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      if (authProvider.hasCompletedProfileSetup) {
        context.go('/dashboard');
      } else {
        context.go('/profile-setup');
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return LoadingOverlay(
          isLoading: authProvider.isLoading,
          message: 'Signing you in...',
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration:
                  const BoxDecoration(gradient: AppTheme.liquidBackground),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 60.h),

                      // Logo/Icon
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withOpacity(0.8)
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 50.sp,
                          color: AppTheme.primaryPurple,
                        ),
                      )
                          .animate()
                          .scale(duration: 1000.ms, curve: Curves.elasticOut)
                          .then()
                          .shimmer(
                              duration: 2000.ms,
                              color: Colors.white.withOpacity(0.5)),

                      SizedBox(height: 40.h),

                      // Welcome Text
                      Text(
                        'Welcome Back! 👋',
                        style: TextStyle(
                          fontSize: 28.sp,
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
                          .fadeIn(delay: 200.ms, duration: 800.ms)
                          .slideY(begin: -0.3, end: 0),

                      SizedBox(height: 8.h),

                      Text(
                        'Sign in to continue managing your finances',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 800.ms)
                          .slideY(begin: -0.2, end: 0),

                      SizedBox(height: 50.h),

                      // Login Form
                      LiquidCard(
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade800,
                                ),
                              ),

                              SizedBox(height: 24.h),

                              LiquidTextField(
                                labelText: 'Email Address',
                                hintText: 'Enter your email',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_outlined,
                                validator: _validateEmail,
                              )
                                  .animate()
                                  .fadeIn(delay: 600.ms, duration: 600.ms)
                                  .slideX(begin: -0.3, end: 0),

                              SizedBox(height: 20.h),

                              LiquidTextField(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                prefixIcon: Icons.lock_outlined,
                                suffixIcon: _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                onSuffixTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                validator: _validatePassword,
                              )
                                  .animate()
                                  .fadeIn(delay: 700.ms, duration: 600.ms)
                                  .slideX(begin: -0.3, end: 0),

                              SizedBox(height: 12.h),

                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Implement forgot password
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.primaryPurple,
                                    ),
                                  ),
                                ),
                              )
                                  .animate()
                                  .fadeIn(delay: 800.ms, duration: 600.ms),

                              SizedBox(height: 24.h),

                              // Button is ALWAYS active now
                              LiquidButton(
                                text: 'Sign In',
                                gradient: AppTheme
                                    .liquidBackground, // Always same gradient
                                onPressed: _login, // Always callable
                                icon: Icons.login_rounded,
                              )
                                  .animate()
                                  .fadeIn(delay: 900.ms, duration: 600.ms)
                                  .slideY(begin: 0.3, end: 0),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 30.h),

                      // Sign Up Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/signup'),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),

                      SizedBox(height: 40.h),
                    ],
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
