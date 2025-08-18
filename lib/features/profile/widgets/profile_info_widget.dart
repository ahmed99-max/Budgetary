import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../shared/models/user_model.dart';

class ProfileInfoWidget extends StatelessWidget {
  final UserModel user;

  const ProfileInfoWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          user.name,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3, end: 0),

        SizedBox(height: 4.h),

        Text(
          user.email,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        )
            .animate()
            .fadeIn(delay: 100.ms, duration: 600.ms)
            .slideY(begin: -0.2, end: 0),

        SizedBox(height: 20.h),

        // User stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(
              'Monthly Income',
              '${user.currency} ${NumberFormat('#,##0').format(user.monthlyIncome)}',
              0,
            ),
            Container(
              width: 1.w,
              height: 30.h,
              color: Colors.white.withOpacity(0.3),
            ),
            _buildStatItem(
              'Country',
              user.country,
              100,
            ),
            Container(
              width: 1.w,
              height: 30.h,
              color: Colors.white.withOpacity(0.3),
            ),
            _buildStatItem(
              'Currency',
              user.currency,
              200,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, int delay) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 200 + delay), duration: 600.ms)
        .slideY(begin: 0.3, end: 0);
  }
}
