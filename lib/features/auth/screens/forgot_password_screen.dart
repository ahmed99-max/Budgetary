import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  Widget build(BuildContext context) {
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

                SizedBox(height: 40.h),

                // Icon
                Neumorphic(
                  style: NeumorphicStyle(
                      shape: NeumorphicShape.flat,
                      boxShape: NeumorphicBoxShape.circle(),
                      depth: 8,
                      intensity: 0.8),
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    child: Icon(Icons.lock_reset,
                        size: 50.sp, color: Color(0xFF6C7CE7)),
                  ),
                ),

                SizedBox(height: 30.h),

                Text('Forgot Password?',
                    style: GoogleFonts.inter(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: NeumorphicTheme.defaultTextColor(context))),
                SizedBox(height: 12.h),

                if (!_emailSent) ...[
                  Text(
                      'Enter your email address and we\'ll send you a link to reset your password',
                      style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: NeumorphicTheme.defaultTextColor(context)
                              ?.withOpacity(0.7)),
                      textAlign: TextAlign.center),

                  SizedBox(height: 40.h),

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

                  SizedBox(height: 30.h),

                  // Send Reset Link Button
                  NeumorphicButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
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
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white))
                          : Text('Send Reset Link',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                    ),
                  ),
                ] else ...[
                  // Email sent confirmation
                  Neumorphic(
                    style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12.r)),
                        depth: -2,
                        intensity: 0.8,
                        color: Colors.green.withOpacity(0.1)),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle,
                              size: 60.sp, color: Colors.green),
                          SizedBox(height: 16.h),
                          Text('Email Sent!',
                              style: GoogleFonts.inter(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green)),
                          SizedBox(height: 8.h),
                          Text('Check your email for a password reset link',
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color:
                                      NeumorphicTheme.defaultTextColor(context)
                                          ?.withOpacity(0.7)),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  NeumorphicButton(
                    onPressed: () => context.go('/login'),
                    style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12.r)),
                        depth: 4,
                        intensity: 0.8),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Text('Back to Login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],

                SizedBox(height: 40.h),

                // Remember password
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Remember your password? ',
                        style: TextStyle(
                            color: NeumorphicTheme.defaultTextColor(context)
                                ?.withOpacity(0.7))),
                    NeumorphicButton(
                      onPressed: () => context.go('/login'),
                      style: NeumorphicStyle(
                          shape: NeumorphicShape.flat, depth: 1),
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      child: Text('Sign In',
                          style: TextStyle(
                              color: Color(0xFF6C7CE7),
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
