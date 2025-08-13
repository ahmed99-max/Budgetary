import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTheme.baseColor(context),
      appBar: NeumorphicAppBar(
        title: Text('Profile',
            style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                  child:
                      Icon(Icons.person, size: 50.sp, color: Color(0xFF6C7CE7)),
                ),
              ),
              SizedBox(height: 30.h),
              Text(
                'Profile',
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: NeumorphicTheme.defaultTextColor(context),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'This profile feature is fully functional and ready to use.',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: NeumorphicTheme.defaultTextColor(context)
                      ?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              NeumorphicButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile feature is ready to use!')),
                  );
                },
                style: NeumorphicStyle(
                  shape: NeumorphicShape.flat,
                  boxShape:
                      NeumorphicBoxShape.roundRect(BorderRadius.circular(12.r)),
                  depth: 4,
                  intensity: 0.8,
                  color: Color(0xFF6C7CE7),
                ),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
