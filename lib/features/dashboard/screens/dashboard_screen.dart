import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/expense_provider.dart';
import '../../../core/providers/budget_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, ExpenseProvider, BudgetProvider>(
      builder: (context, userProvider, expenseProvider, budgetProvider, child) {
        return Scaffold(
          backgroundColor: NeumorphicTheme.baseColor(context),
          appBar: NeumorphicAppBar(
            title: Text('Dashboard',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            actions: [
              NeumorphicButton(
                onPressed: () => context.go('/settings'),
                style: NeumorphicStyle(
                    shape: NeumorphicShape.flat,
                    boxShape: NeumorphicBoxShape.circle(),
                    depth: 2),
                padding: EdgeInsets.all(8),
                child: Icon(Icons.settings, size: 20.sp),
              ),
              SizedBox(width: 16.w),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // Simulate refresh
              await Future.delayed(Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Neumorphic(
                    style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(16.r)),
                        depth: 4,
                        intensity: 0.8),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: LinearGradient(
                            colors: [Color(0xFF6C7CE7), Color(0xFF8E2DE2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome back,',
                              style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  color: Colors.white.withOpacity(0.8))),
                          Text(userProvider.userName,
                              style: GoogleFonts.inter(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          SizedBox(height: 12.h),
                          Text('Total Balance',
                              style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: Colors.white.withOpacity(0.8))),
                          Text(
                              '₹${(userProvider.totalIncome - userProvider.totalExpenses).toStringAsFixed(0)}',
                              style: GoogleFonts.inter(
                                  fontSize: 32.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
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
                              '₹${userProvider.totalIncome.toStringAsFixed(0)}',
                              Icons.trending_up,
                              Colors.green)),
                      SizedBox(width: 12.w),
                      Expanded(
                          child: _buildStatCard(
                              'Expenses',
                              '₹${expenseProvider.monthlyTotal.toStringAsFixed(0)}',
                              Icons.trending_down,
                              Colors.red)),
                      SizedBox(width: 12.w),
                      Expanded(
                          child: _buildStatCard(
                              'Saved',
                              '₹${userProvider.totalSavings.toStringAsFixed(0)}',
                              Icons.savings,
                              Colors.blue)),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Quick Actions
                  Text('Quick Actions',
                      style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: NeumorphicTheme.defaultTextColor(context))),
                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: () => context.go('/add-expense'),
                          style: NeumorphicStyle(
                              shape: NeumorphicShape.flat,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(12.r)),
                              depth: 4,
                              intensity: 0.8),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Column(
                              children: [
                                Icon(Icons.add,
                                    size: 24.sp, color: Color(0xFF6C7CE7)),
                                SizedBox(height: 8.h),
                                Text('Add Expense',
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: () => context.go('/budget'),
                          style: NeumorphicStyle(
                              shape: NeumorphicShape.flat,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(12.r)),
                              depth: 4,
                              intensity: 0.8),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Column(
                              children: [
                                Icon(Icons.account_balance_wallet,
                                    size: 24.sp, color: Color(0xFF6C7CE7)),
                                SizedBox(height: 8.h),
                                Text('View Budget',
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: NeumorphicButton(
                          onPressed: () => context.go('/reports'),
                          style: NeumorphicStyle(
                              shape: NeumorphicShape.flat,
                              boxShape: NeumorphicBoxShape.roundRect(
                                  BorderRadius.circular(12.r)),
                              depth: 4,
                              intensity: 0.8),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Column(
                              children: [
                                Icon(Icons.analytics,
                                    size: 24.sp, color: Color(0xFF6C7CE7)),
                                SizedBox(height: 8.h),
                                Text('View Reports',
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Recent Expenses
                  Text('Recent Expenses',
                      style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: NeumorphicTheme.defaultTextColor(context))),
                  SizedBox(height: 12.h),

                  ...expenseProvider.expenses
                      .take(5)
                      .map((expense) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Neumorphic(
                              style: NeumorphicStyle(
                                  shape: NeumorphicShape.flat,
                                  boxShape: NeumorphicBoxShape.roundRect(
                                      BorderRadius.circular(12.r)),
                                  depth: 2,
                                  intensity: 0.8),
                              child: ListTile(
                                leading: CircleAvatar(
                                    backgroundColor:
                                        Color(0xFF6C7CE7).withOpacity(0.1),
                                    child: Text(expense.category[0],
                                        style: TextStyle(
                                            color: Color(0xFF6C7CE7),
                                            fontWeight: FontWeight.w600))),
                                title: Text(expense.title,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(expense.category),
                                trailing: Text(
                                    '-₹${expense.amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red)),
                              ),
                            ),
                          ))
                      .toList(),

                  SizedBox(height: 12.h),

                  // View All Expenses Button
                  NeumorphicButton(
                    onPressed: () => context.go('/expenses'),
                    style: NeumorphicStyle(
                        shape: NeumorphicShape.flat,
                        boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12.r)),
                        depth: 4,
                        intensity: 0.8),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Text('View All Expenses',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6C7CE7))),
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
    return Neumorphic(
      style: NeumorphicStyle(
          shape: NeumorphicShape.flat,
          boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12.r)),
          depth: 4,
          intensity: 0.8),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Icon(icon, size: 24.sp, color: color),
            SizedBox(height: 8.h),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 16.sp, fontWeight: FontWeight.w700)),
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 12.sp, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
