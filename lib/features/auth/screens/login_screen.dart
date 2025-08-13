import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

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
                    SizedBox(height: 60.h),

                    // Logo and Title
                    Neumorphic(
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.circle(),
                        depth: 8,
                        intensity: 0.8,
                      ),
                      child: Container(
                        width: 100.w,
                        height: 100.w,
                        child: Icon(Icons.account_balance_wallet,
                            size: 50.sp, color: Color(0xFF6C7CE7)),
                      ),
                    ),

                    SizedBox(height: 30.h),

                    Text(
                      'Welcome Back!',
                      style: GoogleFonts.inter(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          color: NeumorphicTheme.defaultTextColor(context)),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      'Sign in to continue managing your finances',
                      style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: NeumorphicTheme.defaultTextColor(context)
                              ?.withOpacity(0.7)),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 40.h),

                    // Email Field
                    Neumorphic(
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12.r)),
                        depth: -4,
                        intensity: 0.8,
                      ),
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

                    SizedBox(height: 20.h),

                    // Password Field
                    Neumorphic(
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12.r)),
                        depth: -4,
                        intensity: 0.8,
                      ),
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
                            return 'Please enter your password';
                          if (value!.length < 6)
                            return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: NeumorphicButton(
                        onPressed: () => context.go('/forgot-password'),
                        style: NeumorphicStyle(
                            shape: NeumorphicShape.flat, depth: 1),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        child: Text('Forgot Password?',
                            style: TextStyle(
                                color: Color(0xFF6C7CE7), fontSize: 14.sp)),
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // Login Button
                    NeumorphicButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _handleLogin(authProvider),
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12.r)),
                        depth: 6,
                        intensity: 0.8,
                        color: Color(0xFF6C7CE7),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: authProvider.isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white))
                            : Text('Sign In',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // OR Divider
                    Row(
                      children: [
                        Expanded(
                            child: Divider(
                                color: NeumorphicTheme.defaultTextColor(context)
                                    ?.withOpacity(0.3))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text('OR',
                              style: TextStyle(
                                  color:
                                      NeumorphicTheme.defaultTextColor(context)
                                          ?.withOpacity(0.5))),
                        ),
                        Expanded(
                            child: Divider(
                                color: NeumorphicTheme.defaultTextColor(context)
                                    ?.withOpacity(0.3))),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    // Google Sign In
                    NeumorphicButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () => _handleGoogleSignIn(authProvider),
                      style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12.r)),
                        depth: 4,
                        intensity: 0.8,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_mobiledata,
                                size: 24.sp, color: Colors.red),
                            SizedBox(width: 12.w),
                            Text('Continue with Google',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30.h),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Don\'t have an account? ',
                            style: TextStyle(
                                color: NeumorphicTheme.defaultTextColor(context)
                                    ?.withOpacity(0.7))),
                        NeumorphicButton(
                          onPressed: () => context.go('/signup'),
                          style: NeumorphicStyle(
                              shape: NeumorphicShape.flat, depth: 1),
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          child: Text('Sign Up',
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
                          color: Colors.red.withOpacity(0.1),
                        ),
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

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await authProvider.signInWithEmail(
          _emailController.text, _passwordController.text);
      if (success && mounted) {
        context.go('/dashboard');
      }
    }
  }

  Future<void> _handleGoogleSignIn(AuthProvider authProvider) async {
    final success = await authProvider.signInWithGoogle();
    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
