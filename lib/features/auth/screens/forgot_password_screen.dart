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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success =
          await authProvider.resetPassword(_emailController.text.trim());

      if (success && mounted) {
        setState(() {
          _emailSent = true;
        });
      } else if (mounted) {
        _showErrorSnackBar(
            authProvider.errorMessage ?? 'Failed to send reset email');
      }
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return LoadingOverlay(
          isLoading: authProvider.isLoading,
          message: 'Sending reset email...',
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
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),

                      // Back button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.go('/login'),
                          icon: Icon(
                            Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),

                      SizedBox(height: 60.h),

                      // Reset password icon
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white, Colors.white70],
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
                          _emailSent
                              ? Icons.mark_email_read_rounded
                              : Icons.lock_reset_rounded,
                          size: 50.sp,
                          color: AppTheme.primaryPurple,
                        ),
                      )
                          .animate()
                          .scale(duration: 800.ms, curve: Curves.elasticOut)
                          .then()
                          .shimmer(
                              duration: 2000.ms,
                              color: Colors.white.withOpacity(0.3)),

                      SizedBox(height: 40.h),

                      // Title and description
                      Text(
                        _emailSent
                            ? 'Check Your Email! 📧'
                            : 'Reset Password 🔒',
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

                      SizedBox(height: 16.h),

                      Text(
                        _emailSent
                            ? 'We\'ve sent a password reset link to ${_emailController.text}. Please check your email and follow the instructions.'
                            : 'Enter your email address and we\'ll send you a link to reset your password.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.4,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 800.ms)
                          .slideY(begin: -0.2, end: 0),

                      SizedBox(height: 50.h),

                      if (!_emailSent) ...[
                        // Email form
                        LiquidCard(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                LiquidTextField(
                                  labelText: 'Email Address',
                                  hintText: 'Enter your email',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icons.email_outlined,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(value!)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                )
                                    .animate()
                                    .fadeIn(delay: 600.ms, duration: 600.ms)
                                    .slideX(begin: -0.3, end: 0),
                                SizedBox(height: 30.h),
                                LiquidButton(
                                  text: 'Send Reset Link',
                                  gradient: const LinearGradient(
                                    colors: [Colors.white, Colors.white70],
                                  ),
                                  onPressed: _handleResetPassword,
                                  icon: Icons.send_rounded,
                                )
                                    .animate()
                                    .fadeIn(delay: 800.ms, duration: 600.ms)
                                    .slideY(begin: 0.3, end: 0),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 1000.ms)
                            .slideY(begin: 0.3, end: 0),
                      ] else ...[
                        // Success state
                        LiquidButton(
                          text: 'Back to Sign In',
                          gradient: const LinearGradient(
                            colors: [Colors.white, Colors.white70],
                          ),
                          onPressed: () => context.go('/login'),
                          icon: Icons.login_rounded,
                        )
                            .animate()
                            .fadeIn(delay: 600.ms, duration: 800.ms)
                            .slideY(begin: 0.3, end: 0),

                        SizedBox(height: 20.h),

                        LiquidButton(
                          text: 'Resend Email',
                          isOutlined: true,
                          onPressed: () => setState(() => _emailSent = false),
                        ).animate().fadeIn(delay: 800.ms, duration: 800.ms),
                      ],

                      SizedBox(height: 60.h),
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
