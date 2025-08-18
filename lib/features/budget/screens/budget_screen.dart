import 'package:budgetary/shared/models/budget_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/providers/budget_provider.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../widgets/budget_overview_widget.dart';
import '../widgets/budget_category_item.dart';
import '../widgets/add_budget_dialog.dart';
import '../../../core/utils/currency_utils.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);

    if (userProvider.hasUser) {
      // Load auto-generated budgets from profile
      budgetProvider.loadUserBudgets(userProvider.user!);

      await Future.wait([
        budgetProvider.loadBudgets(userProvider.user!.uid),
        expenseProvider.loadExpenses(userProvider.user!.uid),
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, BudgetProvider, ExpenseProvider>(
      builder: (context, userProvider, budgetProvider, expenseProvider, _) {
        if (!userProvider.hasUser) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = userProvider.user!;

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
                      // Header
                      Text(
                        'Budget Management 💰',
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
                      )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: -0.3, end: 0),

                      SizedBox(height: 8.h),

                      Text(
                        'Track and manage your spending limits',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 800.ms)
                          .slideY(begin: -0.2, end: 0),

                      SizedBox(height: 30.h),

                      // Budget Overview
                      BudgetOverviewWidget(
                        totalIncome: user.monthlyIncome,
                        totalBudget: budgetProvider.totalAllocated,
                        totalSpent: budgetProvider.totalSpent,
                        currency: user.currency,
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 24.h),

                      // Add Budget Button
                      LiquidButton(
                        text: 'Add New Budget',
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.9),
                            Colors.white.withOpacity(0.7),
                          ],
                        ),
                        onPressed: () => _showAddBudgetDialog(),
                        icon: Icons.add_circle_rounded,
                      )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 800.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 24.h),

                      // NEW: Auto-Generated Budgets Section
                      LiquidCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto-Generated Budgets',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            if (budgetProvider.autoBudgets.isEmpty)
                              Center(
                                child: Text(
                                  'No auto-generated budgets yet. Complete your profile setup.',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            else
                              Column(
                                children: budgetProvider.autoBudgets.entries
                                    .map((entry) {
                                  final spent = expenseProvider
                                          .categoryTotals[entry.key] ??
                                      0;
                                  return BudgetCategoryItem(
                                    budget: BudgetModel(
                                      id: '', // Placeholder for auto-budgets
                                      userId: user.uid,
                                      category: entry.key,
                                      allocatedAmount: entry.value,
                                      spentAmount: spent,
                                      period: 'monthly', // Default
                                      startDate: DateTime.now(),
                                      endDate: DateTime.now()
                                          .add(Duration(days: 30)),
                                      isActive: true,
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                    ),
                                    spent: spent,
                                    currency: user.currency,
                                    onEdit:
                                        () {}, // Optional: Disable edit for auto
                                    onDelete:
                                        () {}, // Optional: Disable delete for auto
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 24.h),

                      // Budget Categories (your existing manual budgets)
                      if (budgetProvider.activeBudgets.isNotEmpty) ...[
                        LiquidCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Budgets',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: 20.h),
                              Column(
                                children:
                                    budgetProvider.activeBudgets.map((budget) {
                                  final spent = expenseProvider
                                          .categoryTotals[budget.category] ??
                                      0;
                                  return BudgetCategoryItem(
                                    budget: budget,
                                    spent: spent,
                                    currency: user.currency,
                                    onEdit: () => _editBudget(budget),
                                    onDelete: () => _deleteBudget(budget),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 800.ms, duration: 1000.ms)
                            .slideY(begin: 0.3, end: 0),
                      ] else ...[
                        // Empty state
                        LiquidCard(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(40.w),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.pie_chart_outline_rounded,
                                  size: 80.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 20.h),
                                Text(
                                  'No Budgets Yet',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'Create your first budget to start tracking your spending limits and achieve your financial goals.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: 30.h),
                                LiquidButton(
                                  text: 'Create First Budget',
                                  gradient: AppTheme.liquidBackground,
                                  onPressed: () => _showAddBudgetDialog(),
                                  icon: Icons.add_circle_rounded,
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 800.ms, duration: 1000.ms)
                            .slideY(begin: 0.3, end: 0)
                            .then()
                            .shimmer(
                              duration: 2000.ms,
                              color: AppTheme.primaryPurple.withOpacity(0.1),
                            ),
                      ],

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

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(
        onBudgetCreated: () {
          _loadData();
        },
      ),
    );
  }

  void _editBudget(budget) {
    // Implementation for editing budget
  }

  void _deleteBudget(budget) async {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    await budgetProvider.deleteBudget(budget.id);
  }
}
