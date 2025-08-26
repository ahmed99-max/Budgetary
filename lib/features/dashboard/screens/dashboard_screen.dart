// lib/features/dashboard/screens/dashboard_screen.dart

import 'package:budgetary/features/dashboard/widgets/loan_overview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FIXED: Added for UID

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/providers/budget_provider.dart';
import '../../../shared/providers/loan_provider.dart'; // FIXED: Added for LoanProvider
import '../../../shared/widgets/liquid_card.dart';
import '../widgets/balance_overview_card.dart';
import '../widgets/quick_actions_widget.dart';
import '../widgets/recent_transactions_widget.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/spending_insights_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isInitialLoading = true;
  String? _loadingError;

  @override
  void initState() {
    super.initState();
    _preloadDashboardData();
  }

  Future<void> _preloadDashboardData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);
      final loanProvider = Provider.of<LoanProvider>(context,
          listen: false); // FIXED: Added LoanProvider

      // FIXED: Get current UID and pass to loadUserData
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('No authenticated user found. Please log in again.');
      }
      await userProvider
          .loadUserData(uid); // FIXED: Pass the required UID argument

      if (userProvider.hasUser) {
        // FIXED: Ensure all are Futures for Future.wait
        await Future.wait([
          expenseProvider.loadExpenses(),
          budgetProvider.loadBudgets(expenseProvider),
          loanProvider.loadLoans(),
        ]);
        budgetProvider.loadUserBudgets(userProvider.user!);
      }
    } catch (e) {
      setState(() {
        _loadingError = 'Failed to load dashboard data: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _loadingError = null;
    });
    await _preloadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, ExpenseProvider, BudgetProvider>(
      builder: (context, userProvider, expenseProvider, budgetProvider, _) {
        if (!userProvider.hasUser) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_isInitialLoading) {
          return Scaffold(
            body: Container(
              decoration:
                  const BoxDecoration(gradient: AppTheme.liquidBackground),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.white.withOpacity(0.8)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(AppTheme.primaryPurple),
                        strokeWidth: 3,
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .rotate(duration: 2000.ms)
                        .then()
                        .shimmer(
                            duration: 1500.ms,
                            color: Colors.white.withOpacity(0.3)),
                    SizedBox(height: 24.h),
                    Text(
                      'Loading your dashboard...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 500.ms)
                        .slideY(begin: 0.3, end: 0),
                  ],
                ),
              ),
            ),
          );
        }

        if (_loadingError != null) {
          return Scaffold(
            body: Container(
              decoration:
                  const BoxDecoration(gradient: AppTheme.liquidBackground),
              child: Center(
                child: LiquidCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48.sp,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Oops! Something went wrong',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _loadingError!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: _refreshDashboard,
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Container(
            decoration:
                const BoxDecoration(gradient: AppTheme.liquidBackground),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _refreshDashboard,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back! 👋',
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: const Offset(0, 2),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                userProvider.user!.name.split(' ').first,
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              DateFormat('MMM d, yyyy').format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: -0.3, end: 0),
                      SizedBox(height: 30.h),

                      // Balance Overview
                      BalanceOverviewCard(
                        user: userProvider.user!,
                        totalExpenses: expenseProvider.monthlyTotal,
                        budgetProvider: budgetProvider,
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),
                      SizedBox(height: 24.h),

                      LoanOverviewCard(
                        onViewDetails: () {
                          // Navigate to budget and scroll to loans if you have a scroll controller
                          context.go('/budget'); // or your route
                        },
                      ),

                      // Quick Actions
                      QuickActionsWidget()
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 800.ms)
                          .slideY(begin: 0.3, end: 0),
                      SizedBox(height: 24.h),

                      // Budget Overview with sorted categories
                      BudgetOverviewCard(
                        budgetProvider: budgetProvider,
                        expenseProvider: expenseProvider,
                        currency: userProvider.user!.currency,
                      )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),
                      SizedBox(height: 24.h),

                      // Spending Insights
                      SpendingInsightsWidget(
                        expenseProvider: expenseProvider,
                        currency: userProvider.user!.currency,
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),
                      SizedBox(height: 24.h),

                      // Recent Transactions
                      RecentTransactionsWidget(
                        expenses: expenseProvider.expenses.take(5).toList(),
                        currency: userProvider.user!.currency,
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
}
