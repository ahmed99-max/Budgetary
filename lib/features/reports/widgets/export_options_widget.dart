import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';

class ExportOptionsWidget extends StatelessWidget {
  final VoidCallback onExportPDF;
  final VoidCallback onExportCSV;
  final VoidCallback onShare;

  const ExportOptionsWidget({
    super.key,
    required this.onExportPDF,
    required this.onExportCSV,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export & Share',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildExportOption(
                  'PDF Report',
                  'Export detailed PDF report',
                  Icons.picture_as_pdf_rounded,
                  Colors.red,
                  onExportPDF,
                  0,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildExportOption(
                  'CSV Data',
                  'Export raw data as CSV',
                  Icons.table_chart_rounded,
                  Colors.green,
                  onExportCSV,
                  100,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          LiquidButton(
            text: 'Share Report',
            gradient: AppTheme.liquidBackground,
            onPressed: onShare,
            icon: Icons.share_rounded,
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildExportOption(String title, String subtitle, IconData icon,
      Color color, VoidCallback onTap, int delay) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 200 + delay), duration: 600.ms)
        .slideY(begin: 0.3, end: 0)
        .then()
        .shimmer(duration: 2000.ms, color: color.withOpacity(0.1));
  }
}
