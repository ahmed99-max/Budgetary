import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: NeumorphicTheme.baseColor(context),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 40.h),

                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: NeumorphicButton(
                        onPressed: () => context.go('/login'),
                        style: NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.circle(),
                            depth: 4),
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.arrow_back, size: 20.sp),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Logo and Title
                    Neumorphic(
                      style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.circle(),
                          depth: 8,
                          intensity: 0.8),
                      child: Container(
                        width: 80.w,
                        height: 80.w,
                        child: Icon(Icons.person_add,
                            size: 40.sp, color: Color(0xFF6C7CE7)),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    Text('Create Account',
                        style: GoogleFonts.inter(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: NeumorphicTheme.defaultTextColor(context))),
                    SizedBox(height: 8.h),
                    Text('Join us and start managing your finances better',
                        style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: NeumorphicTheme.defaultTextColor(context)
                                ?.withOpacity(0.7)),
                        textAlign: TextAlign.center),

                    SizedBox(height: 30.h),

                    // Name Field
                    Neumorphic(
                      style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(12.r)),
                          depth: -4,
                          intensity: 0.8),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline,
                              color: Color(0xFF6C7CE7)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 16.h),
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Please enter your full name'
                            : null,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Email Field
                    Neumorphic(
                      style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(12.r)),
                          depth: -4,
                          intensity: 0.8),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: Color(0xFF6C7CE7)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 16.h),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Please enter your email';
                          if (!value!.contains('@'))
                            return 'Please enter a valid email';
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Password Field
                    Neumorphic(
                      style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(12.r)),
                          depth: -4,
                          intensity: 0.8),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Color(0xFF6C7CE7)),
                          suffixIcon: NeumorphicButton(
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            style: NeumorphicStyle(
                                shape: NeumorphicShape.flat,
                                boxShape: NeumorphicBoxShape.circle(),
                                depth: 2),
                            padding: EdgeInsets.all(8),
                            child: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 20.sp),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 16.h),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Please enter a password';
                          if (value!.length < 6)
                            return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Confirm Password Field
                    Neumorphic(
                      style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(12.r)),
                          depth: -4,
                          intensity: 0.8),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Color(0xFF6C7CE7)),
                          suffixIcon: NeumorphicButton(
                            onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                            style: NeumorphicStyle(
                                shape: NeumorphicShape.flat,
                                boxShape: NeumorphicBoxShape.circle(),
                                depth: 2),
                            padding: EdgeInsets.all(8),
                            child: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 20.sp),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w, vertical: 16.h),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true)
                            return 'Please confirm your password';
                          if (value != _passwordController.text)
                            return 'Passwords do not match';
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Terms and Conditions
                    Row(
                      children: [
                        NeumorphicCheckbox(
                          value: _agreeToTerms,
                          onChanged: (value) =>
                              setState(() => _agreeToTerms = value ?? false),
                          style: NeumorphicCheckboxStyle(
                              selectedDepth: -4, unselectedDepth: 4),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                              'I agree to the Terms & Conditions and Privacy Policy',
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color:
                                      NeumorphicTheme.defaultTextColor(context)
                                          ?.withOpacity(0.7))),
                        ),
                      ],
                    ),

                    SizedBox(height: 30.h),

                    // Sign Up Button
                    NeumorphicButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _handleSignUp(authProvider),
                      style: NeumorphicStyle(
                          shape: NeumorphicShape.flat,
                          boxShape: NeumorphicBoxShape.roundRect(
                              BorderRadius.circular(12.r)),
                          depth: 6,
                          intensity: 0.8,
                          color: Color(0xFF6C7CE7)),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: authProvider.isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white))
                            : Text('Create Account',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account? ',
                            style: TextStyle(
                                color: NeumorphicTheme.defaultTextColor(context)
                                    ?.withOpacity(0.7))),
                        NeumorphicButton(
                          onPressed: () => context.go('/login'),
                          style: NeumorphicStyle(
                              shape: NeumorphicShape.flat, depth: 1),
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          child: Text('Sign In',
                              style: TextStyle(
                                  color: Color(0xFF6C7CE7),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),

                    if (authProvider.errorMessage != null) ...[
                      SizedBox(height: 20.h),
                      Neumorphic(
                        style: NeumorphicStyle(
                            shape: NeumorphicShape.flat,
                            boxShape: NeumorphicBoxShape.roundRect(
                                BorderRadius.circular(8.r)),
                            depth: -2,
                            intensity: 0.8,
                            color: Colors.red.withOpacity(0.1)),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          child: Text(authProvider.errorMessage!,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 14.sp),
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSignUp(AuthProvider authProvider) async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please agree to Terms & Conditions')),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final success = await authProvider.signUpWithEmail(_emailController.text,
          _passwordController.text, _nameController.text);
      if (success && mounted) {
        context.go('/dashboard');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
