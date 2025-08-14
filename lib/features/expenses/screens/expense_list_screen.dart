import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FE),
        title: Text('Expenses', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80.sp, color: const Color(0xFF6C63FF)),
            SizedBox(height: 20.h),
            Text('Expense List', style: GoogleFonts.inter(fontSize: 24.sp, fontWeight: FontWeight.w700)),
            Text('Feature coming soon!', style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
