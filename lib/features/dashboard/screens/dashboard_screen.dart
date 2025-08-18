import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/providers/budget_provider.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../widgets/expense_chart_widget.dart';
import '../widgets/category_progress_widget.dart';
import '../widgets/recent_transactions_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    if (userProvider.hasUser) {
      await Future.wait([
        expenseProvider.loadExpenses(userProvider.user!.uid),
        budgetProvider.loadBudgets(userProvider.user!.uid),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, ExpenseProvider, BudgetProvider>(
      builder: (context, userProvider, expenseProvider, budgetProvider, _) {
        if (!userProvider.hasUser) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = userProvider.user!;
        final totalIncome = user.monthlyIncome;
        final totalExpenses = expenseProvider.monthlyTotal;
        final totalBudget = budgetProvider.totalAllocated;
        final remainingBalance = totalIncome - totalExpenses;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.liquidBackground,
            ),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with greeting
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                user.name,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 50.w,
                            height: 50.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: user.profileImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(25.r),
                                    child: Image.network(
                                      user.profileImageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 24.sp,
                                  ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: -0.3, end: 0),

                      SizedBox(height: 30.h),

                      // Balance Overview Card
                      LiquidCard(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.15),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Available Balance',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                Icon(
                                  Icons.visibility_outlined,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 20.sp,
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '${user.currency} ${NumberFormat('#,##0.00').format(remainingBalance)}',
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                Icon(
                                  remainingBalance >= 0
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                                  color: remainingBalance >= 0
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  remainingBalance >= 0
                                      ? 'You\'re doing great!'
                                      : 'Consider reducing expenses',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0)
                          .then()
                          .shimmer(
                            duration: 2000.ms,
                            color: Colors.white.withOpacity(0.2),
                          ),

                      SizedBox(height: 24.h),

                      // Quick Stats Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Income',
                              '${user.currency} ${NumberFormat('#,##0').format(totalIncome)}',
                              Icons.trending_up_rounded,
                              Colors.greenAccent,
                              0,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildStatCard(
                              'Expenses',
                              '${user.currency} ${NumberFormat('#,##0').format(totalExpenses)}',
                              Icons.trending_down_rounded,
                              Colors.orangeAccent,
                              100,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildStatCard(
                              'Budget',
                              '${user.currency} ${NumberFormat('#,##0').format(totalBudget)}',
                              Icons.pie_chart_rounded,
                              AppTheme.primaryPurple,
                              200,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 24.h),

                      // Expense Chart
                      LiquidCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Spending Overview',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.liquidBackground,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    'This Month',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20.h),
                            ExpenseChartWidget(
                                expenses: expenseProvider.expenses),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 24.h),

                      // Category Progress
                      LiquidCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget Progress',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            CategoryProgressWidget(
                              budgets: budgetProvider.activeBudgets,
                              expenses: expenseProvider.categoryTotals,
                              currency: user.currency,
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 24.h),

                      // Recent Transactions
                      LiquidCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Transactions',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _navigateToExpenses(),
                                  child: Text(
                                    'View All',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryPurple,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            RecentTransactionsWidget(
                              expenses:
                                  expenseProvider.expenses.take(5).toList(),
                              currency: user.currency,
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 1000.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 100.h), // Space for bottom nav
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning! 🌅';
    if (hour < 17) return 'Good Afternoon! ☀️';
    return 'Good Evening! 🌙';
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color, int delay) {
    return LiquidCard(
      gradient: AppTheme.cardGradient,
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 400 + delay), duration: 800.ms)
        .slideY(begin: 0.3, end: 0)
        .then()
        .shimmer(duration: 2000.ms, color: color.withOpacity(0.1));
  }

  void _navigateToExpenses() {
    // Navigation will be handled by the bottom nav
  }
}
