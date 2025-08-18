import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/user_provider.dart';
import '../../../shared/providers/expense_provider.dart';
import '../../../shared/providers/budget_provider.dart';
import '../../../shared/widgets/liquid_card.dart';
import '../../../shared/widgets/liquid_button.dart';
import '../widgets/expense_trend_chart.dart';
import '../widgets/category_breakdown_chart.dart';
import '../widgets/monthly_summary_widget.dart';
import '../widgets/export_options_widget.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = [
    'This Week',
    'This Month',
    'Last 3 Months',
    'This Year'
  ];

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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Financial Reports 📊',
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
                                'Analyze your spending patterns',
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
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPeriod,
                                icon: Icon(Icons.keyboard_arrow_down,
                                    color: Colors.white),
                                dropdownColor: AppTheme.primaryPurple,
                                items: _periods.map((period) {
                                  return DropdownMenuItem(
                                    value: period,
                                    child: Text(
                                      period,
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPeriod = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: -0.3, end: 0),

                      SizedBox(height: 30.h),

                      // Monthly Summary
                      MonthlySummaryWidget(
                        totalIncome: user.monthlyIncome,
                        totalExpenses: expenseProvider.monthlyTotal,
                        totalBudget: budgetProvider.totalAllocated,
                        currency: user.currency,
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 24.h),

                      // Expense Trend Chart
                      LiquidCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expense Trends',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            ExpenseTrendChart(
                                expenses: expenseProvider.expenses),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 24.h),

                      // Category Breakdown
                      LiquidCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Category Breakdown',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            CategoryBreakdownChart(
                              expenses: expenseProvider.categoryTotals,
                              currency: user.currency,
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),

                      SizedBox(height: 24.h),

                      // Export Options
                      ExportOptionsWidget(
                        onExportPDF: () => _exportPDF(),
                        onExportCSV: () => _exportCSV(),
                        onShare: () => _shareReport(),
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 1000.ms)
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

  void _exportPDF() {
    // Implementation for PDF export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('PDF export feature coming soon!'),
        backgroundColor: AppTheme.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _exportCSV() {
    // Implementation for CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV export feature coming soon!'),
        backgroundColor: AppTheme.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _shareReport() {
    // Implementation for sharing report
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share feature coming soon!'),
        backgroundColor: AppTheme.primaryPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
