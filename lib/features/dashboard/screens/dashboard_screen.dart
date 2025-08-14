import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/user_provider.dart';
import '../../../core/providers/expense_provider.dart';
import '../../../core/providers/budget_provider.dart';
import '../../../shared/widgets/modern_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, ExpenseProvider, BudgetProvider>(
      builder: (context, userProvider, expenseProvider, budgetProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FE),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good Morning! 👋',
                              style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF718096))),
                          Text(userProvider.userName,
                              style: GoogleFonts.inter(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2D3748))),
                        ],
                      ),
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: Color.fromRGBO(108, 99, 255,
                            0.1), // Replaced deprecated withOpacity
                        child: Text(
                          userProvider.userName.isNotEmpty
                              ? userProvider.userName[0].toUpperCase()
                              : 'U',
                          style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6C63FF)),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Balance Card (Wrapped in Container for gradient)
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF6C63FF), Color(0xFF8B80F9)],
                      ),
                      borderRadius: BorderRadius.circular(
                          12.r), // Assuming ModernCard's radius
                    ),
                    child: ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Balance',
                              style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  color: Colors.white
                                      .withAlpha(204))), // Replaced withOpacity
                          SizedBox(height: 8.h),
                          Text(
                              '₹${(userProvider.monthlyIncome - expenseProvider.monthlyTotal).toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Icon(Icons.trending_up,
                                  color: const Color(0xFF10B981), size: 16.sp),
                              SizedBox(width: 4.w),
                              Text('+2.5% from last month',
                                  style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      color: Colors.white.withAlpha(
                                          229))), // Replaced withOpacity
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Quick Stats
                  Row(
                    children: [
                      Expanded(
                          child: _buildStatCard(
                              'Income',
                              '₹${userProvider.monthlyIncome.toStringAsFixed(0)}',
                              Icons.trending_up,
                              const Color(0xFF10B981))),
                      SizedBox(width: 12.w),
                      Expanded(
                          child: _buildStatCard(
                              'Expenses',
                              '₹${expenseProvider.monthlyTotal.toStringAsFixed(0)}',
                              Icons.trending_down,
                              const Color(0xFFEF4444))),
                      SizedBox(width: 12.w),
                      Expanded(
                          child: _buildStatCard(
                              'Saved',
                              '₹${(userProvider.monthlyIncome * 0.2).toStringAsFixed(0)}',
                              Icons.savings,
                              const Color(0xFF6C63FF))),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Quick Actions
                  Text('Quick Actions',
                      style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2D3748))),
                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(
                          child: _buildActionCard(
                              'Add Expense',
                              Icons.add_circle_outline,
                              const Color(0xFF6C63FF),
                              () => context.go('/add-expense'))),
                      SizedBox(width: 12.w),
                      Expanded(
                          child: _buildActionCard(
                              'View Budget',
                              Icons.pie_chart_outline,
                              const Color(0xFF10B981),
                              () => context.go('/budget'))),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Recent Transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Transactions',
                          style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2D3748))),
                      TextButton(
                        onPressed: () => context.go('/expenses'),
                        child: Text('View All',
                            style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6C63FF))),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  ...expenseProvider.expenses.take(5).map(
                        (expense) => Container(
                          margin: EdgeInsets.only(
                              bottom: 8.h), // Wrapped in Container for margin
                          child: ModernCard(
                            padding: EdgeInsets.all(16.w),
                            child: Row(
                              children: [
                                Container(
                                  width: 48.w,
                                  height: 48.w,
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(108, 99, 255,
                                        0.1), // Replaced deprecated withOpacity
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.receipt,
                                      color: const Color(0xFF6C63FF),
                                      size: 24.sp),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(expense.title,
                                          style: GoogleFonts.inter(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF2D3748))),
                                      Text(expense.categoryName,
                                          style: GoogleFonts.inter(
                                              fontSize: 14.sp,
                                              color: const Color(0xFF718096))),
                                    ],
                                  ),
                                ),
                                Text('-₹${expense.amount.toStringAsFixed(0)}',
                                    style: GoogleFonts.inter(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFEF4444))),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return ModernCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Icon(icon, size: 24.sp, color: color),
          SizedBox(height: 8.h),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D3748))),
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 12.sp, color: const Color(0xFF718096))),
        ],
      ),
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      // Wrapped in GestureDetector for onTap
      onTap: onTap,
      child: ModernCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(icon, size: 32.sp, color: color),
            SizedBox(height: 8.h),
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748))),
          ],
        ),
      ),
    );
  }
}
