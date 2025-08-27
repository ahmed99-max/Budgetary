// lib/features/budget/screens/budget_screen.dart
// MINOR UPDATES - Better error handling and loading states

import 'package:budgetary/features/budget/widgets/minimal_loan_card.dart';
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
import '../widgets/enhanced_loan_card_widget.dart';
import '../widgets/add_category_expense_dialog.dart';
import '../widgets/loan_budget_category_item.dart';
import '../../../features/budget/widgets/add_loan_expense_dialog.dart';

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

  void _showAddCategoryExpenseDialog(BudgetModel budget) {
    showDialog(
      context: context,
      builder: (context) => AddCategoryExpenseDialog(
        budget: budget,
        onExpenseAdded: _loadData,
      ),
    );
  }

  void _showAddLoanExpenseDialog() {
    showDialog(
      context: context,
      builder: (context) => AddLoanExpenseDialog(
        onExpenseAdded: _loadData,
      ),
    );
  }

  Future<void> _loadData() async {
    print("🎯 BUDGET SCREEN: Starting _loadData()");
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);

      print("👤 User exists: ${userProvider.hasUser}");
      if (userProvider.hasUser) {
        print("👤 User ID: ${userProvider.user!.uid}");
        print("📧 User email: ${userProvider.user!.email}");
      }

      if (userProvider.hasUser) {
        // Load all data concurrently
        await Future.wait([
          expenseProvider.loadExpenses(),
          budgetProvider.loadBudgets(expenseProvider),
          loanProvider.loadLoans(), // This now uses LoanModel consistently
        ]);

        // Load user budgets after other data is loaded
        budgetProvider.loadUserBudgets(userProvider.user!);
        print("✅ BUDGET SCREEN: Load completed successfully");
      } else {
        print("❌ BUDGET SCREEN: No user found");
      }
    } catch (e, stackTrace) {
      print("❌ BUDGET SCREEN ERROR: $e");
      print("📍 STACK TRACE: $stackTrace");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content:
            const Text('Are you sure you want to delete this budget category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);
      final success = await budgetProvider.deleteBudget(budgetId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Budget category deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
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
        content: const Text('Edit feature coming soon!'),
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
                                  const Color.fromRGBO(255, 255, 255, 0.2),
                                  const Color.fromRGBO(255, 255, 255, 0.1),
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

                      // Loans Section - Enhanced with better error handling
                      _buildLoansSection(loans, user.currency, loanProvider),
                      SizedBox(height: 24.h),

                      // Add Budget Button
                      LiquidButton(
                        text: 'Add Budget Category',
                        gradient: const LinearGradient(
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
                      if (isLoading)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.h),
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                        )
                      else if (budgets.isEmpty)
                        _buildEmptyState()
                      else
                        _buildBudgetsList(
                            budgets, expenseProvider, user.currency),

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

  Widget _buildLoansSection(
      List loans, String currency, LoanProvider loanProvider) {
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

        // Enhanced error handling for loans
        if (loanProvider.errorMessage != null)
          Container(
            padding: EdgeInsets.all(16.w),
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Error loading loans: ${loanProvider.errorMessage}',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _loadData,
                  child:
                      const Text('Retry', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),

        // Inside _buildLoansSection (replace the else if (loans.isEmpty) ... else Column(...) part with this)

        if (loanProvider.isLoading)
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
          // Inside the Column for loans (in _buildLoansSection's else block):
          Column(
            children: loans.asMap().entries.map((entry) {
              final index = entry.key;
              final loan = entry.value;
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                child: MinimalLoanCard(
                  loan: loan,
                  currency: currency,
                  onViewDetails: () {
                    // UPDATED DIALOG: Fits content size
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: EdgeInsets.symmetric(
                            horizontal: 40.w,
                            vertical: 100.h), // Adds margin around dialog
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 320
                                .w, // Max width to fit content (adjust as needed)
                            maxHeight: 400
                                .h, // Max height to fit content (adjust as needed)
                          ),
                          child: IntrinsicHeight(
                            // Makes height wrap content
                            child: EnhancedLoanCardWidget(
                              loan: loan,
                              currency: currency,
                              onUpdated: _loadData,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
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
                'Add loans to track them here',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 8.h),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AddLoanDialog(
                      onLoanUpdated: _loadData,
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Loan'),
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
              child: budget.isLoanCategory
                  ? LoanBudgetCategoryItem(
                      budget: budget,
                      spent: spent,
                      currency: currency,
                      onAddExpense: () => _showAddLoanExpenseDialog(),
                    )
                  : BudgetCategoryItem(
                      budget: budget,
                      spent: spent,
                      currency: currency,
                      onDelete: () => _deleteBudget(budget.id),
                      onEdit: () => _editBudget(budget.id),
                      onAddExpense: () => _showAddCategoryExpenseDialog(budget),
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
