import 'package:budgetary/features/reports/widgets/export_options_widget.dart';
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
import '../../../features/reports/widgets/expense_trend_chart.dart';
import '../../../features/reports/widgets/category_breakdown_chart.dart';
import '../../../features/reports/widgets/monthly_summary_widget.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAll();
    });
  }

  Future<void> _loadAll() async {
    final up = Provider.of<UserProvider>(context, listen: false);
    final ep = Provider.of<ExpenseProvider>(context, listen: false);
    final bp = Provider.of<BudgetProvider>(context, listen: false);
    if (up.user != null) {
      await Future.wait(
          [ep.loadExpenses(), bp.loadBudgets(ep)]); // Pass ep to loadBudgets
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UserProvider, ExpenseProvider, BudgetProvider>(
      builder: (context, up, ep, bp, _) {
        if (up.user == null)
          return const Center(child: CircularProgressIndicator());

        final user = up.user!;
        final width = MediaQuery.of(context).size.width;
        final isTablet = width > 600;
        final chartHeight = isTablet ? 300.h : 200.h;

        return Scaffold(
          body: Container(
            decoration:
                const BoxDecoration(gradient: AppTheme.liquidBackground),
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadAll,
                child: SingleChildScrollView(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
                                Text('Financial Reports 📊',
                                    style: TextStyle(
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white)),
                                SizedBox(height: 4.h),
                                Text('Analyze your spending patterns',
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white70)),
                              ]),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedPeriod,
                              dropdownColor: AppTheme.primaryPurple,
                              style: TextStyle(
                                  fontSize: 14.sp, color: Colors.white),
                              items: _periods
                                  .map((p) => DropdownMenuItem(
                                      value: p, child: Text(p)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedPeriod = v!),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: -0.3, end: 0),
                      SizedBox(height: 24.h),

                      // Monthly Summary
                      MonthlySummaryWidget(
                        totalIncome: user.monthlyIncome,
                        totalExpenses: ep.monthlyTotal,
                        totalBudget: bp.totalAllocated,
                        currency: user.currency,
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),
                      SizedBox(height: 24.h),

                      // Expense Trends
                      LiquidCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Expense Trends',
                                style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(height: 12.h),
                            SizedBox(
                                height: chartHeight,
                                child:
                                    ExpenseTrendChart(expenses: ep.expenses)),
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
                            Text('Category Breakdown',
                                style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700)),
                            SizedBox(height: 12.h),
                            SizedBox(
                                height: chartHeight,
                                child: CategoryBreakdownChart(
                                  expenses: ep.categoryTotals,
                                  currency: user.currency,
                                )),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),
                      SizedBox(height: 24.h),

                      // Export
                      ExportOptionsWidget(
                        onExportPDF: () {},
                        onExportCSV: () {},
                        onShare: () {},
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 1000.ms)
                          .slideY(begin: 0.3, end: 0),
                      SizedBox(height: 80.h),
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
