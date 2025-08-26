// lib/features/budget/screens/budget_screen.dart

import 'package:budgetary/features/loan/widgets/add_loan_dialog.dart';
import 'package:budgetary/shared/models/budget_model.dart';
import 'package:budgetary/shared/providers/loan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/providers/budget_provider.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/budget_category_item.dart';
import '../widgets/add_budget_dialog.dart';
import '../widgets/loan_card_widget.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    print("🎯 BUDGET SCREEN: Starting _loadData()");
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final loanProvider = Provider.of<LoanProvider>(context, listen: false);

    print("👤 User exists: ${userProvider.hasUser}");
    if (userProvider.hasUser) {
      print("👤 User ID: ${userProvider.user!.uid}");
      print("📧 User email: ${userProvider.user!.email}");
    }

    if (userProvider.hasUser) {
      await Future.wait([
        expenseProvider.loadExpenses(),
        budgetProvider.loadBudgets(expenseProvider),
        loanProvider.loadLoans(), // 👈 LOAD LOANS
      ]);
      budgetProvider.loadUserBudgets(userProvider.user!);
      print("✅ BUDGET SCREEN: Load completed");
    } else {
      print("❌ BUDGET SCREEN: No user found");
    }
  }

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(
        onBudgetCreated: _loadData,
      ),
    );
  }

  Future<void> _deleteBudget(String budgetId) async {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Budget'),
        content: Text('Are you sure you want to delete this budget category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await budgetProvider.deleteBudget(budgetId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget category deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(budgetProvider.errorMessage ?? 'Failed to delete budget'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _editBudget(String budgetId) {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit feature coming soon!'),
        backgroundColor: AppTheme.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer4<UserProvider, ExpenseProvider, BudgetProvider,
        LoanProvider>(
      builder: (context, userProvider, expenseProvider, budgetProvider,
          loanProvider, _) {
        if (!userProvider.hasUser) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = userProvider.user!;
        final budgets = budgetProvider.budgets;
        final loans = loanProvider.loans;
        final isLoading = budgetProvider.isLoading || loanProvider.isLoading;

        return Scaffold(
          body: Container(
            decoration:
                const BoxDecoration(gradient: AppTheme.liquidBackground),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  physics: const AlwaysScrollableScrollPhysics(),
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
                              Text(
                                'Budget Manager 💰',
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
                                'Track and manage your spending',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
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
                              DateFormat('MMM yyyy').format(DateTime.now()),
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

                      // Budget Summary Card
                      BudgetSummaryCard(
                        user: user,
                        budgetProvider: budgetProvider,
                        expenseProvider: expenseProvider,
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),
                      SizedBox(height: 24.h),

                      // Loans Section - NEW!
                      _buildLoansSection(
                          loans, user.currency, loanProvider.isLoading),
                      SizedBox(height: 24.h),

                      // Add Budget Button
                      LiquidButton(
                        text: 'Add Budget Category',
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryPurple,
                            AppTheme.primaryBlue,
                          ],
                        ),
                        onPressed: _showAddBudgetDialog,
                        icon: Icons.add_rounded,
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(begin: 0.3, end: 0),
                      SizedBox(height: 24.h),

                      // Budget Categories
                      isLoading
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(40.h),
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              ),
                            )
                          : (budgets.isEmpty
                              ? _buildEmptyState()
                              : _buildBudgetsList(
                                  budgets, expenseProvider, user.currency)),

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

  // In your budget_screen.dart, update the _buildLoansSection method:

  Widget _buildLoansSection(List<Loan> loans, String currency, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Loans 🏦',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AddLoanDialog(
                    onLoanUpdated: _loadData,
                  ),
                );
              },
              icon: Icon(Icons.add, color: Colors.white, size: 16.sp),
              label: Text(
                'Add Loan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        if (isLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.all(40.h),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          )
        else if (loans.isEmpty)
          _buildNoLoansCard()
        else
          Column(
            children: loans.asMap().entries.map((entry) {
              final index = entry.key;
              final loan = entry.value;
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                child: LoanCardWidget(
                  // This now uses the enhanced version
                  loan: loan,
                  currency: currency,
                  onUpdated: _loadData,
                ),
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 600 + (index * 100)))
                  .slideX(begin: 0.3, end: 0);
            }).toList(),
          ),
      ],
    )
        .animate()
        .fadeIn(delay: 300.ms, duration: 1000.ms)
        .slideY(begin: 0.3, end: 0);
  }

  // In budget_screen.dart
  Widget _buildNoLoansCard() {
    return LiquidCard(
      child: Container(
        height: 120.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance,
                size: 48.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 12.h),
              Text(
                'No loans yet',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Add loans from your profile to track here',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 8.h),
              ElevatedButton.icon(
                // ADDED: Add Loan button
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AddLoanDialog(),
                  ).then((_) => _loadData()); // Reload after add
                },
                icon: Icon(Icons.add),
                label: Text('Add Loan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBudgetsList(List<BudgetModel> budgets,
      ExpenseProvider expenseProvider, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Categories',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        Column(
          children: budgets.asMap().entries.map((entry) {
            final index = entry.key;
            final budget = entry.value;
            final spent =
                expenseProvider.categoryTotals[budget.category] ?? 0.0;
            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: BudgetCategoryItem(
                budget: budget,
                spent: spent,
                currency: currency,
                onDelete: () => _deleteBudget(budget.id),
                onEdit: () => _editBudget(budget.id),
              ),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 600 + (index * 100)))
                .slideX(begin: 0.3, end: 0);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return LiquidCard(
      child: Container(
        height: 200.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 64.sp,
                color: Colors.grey.shade400,
              ),
              SizedBox(height: 16.h),
              Text(
                'No budgets yet',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Create your first budget category\nto start tracking your spending',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }
}
