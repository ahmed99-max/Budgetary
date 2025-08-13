import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/expense_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../shared/widgets/custom-app-bar.dart';
import '../../shared/widgets/loading-widget.dart';
import '../../shared/widgets/report_summary_card.dart';
import '../../features/reports/widgets/spending_pattern_chart.dart';
import '../../features/reports/widgets/category_breakdown_chart.dart';
import '../../features/reports/widgets/monthly_trend_chart.dart';
import '../../features/reports/widgets/budget_vs_actual_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'This Month';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  final List<String> _periods = [
    'This Week',
    'This Month',
    'Last 3 Months',
    'This Year',
    'Custom Range'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReportData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadReportData() {
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    expenseProvider.loadExpensesForPeriod(_startDate, _endDate);
    expenseProvider.generateReportData(_startDate, _endDate);
  }

  void _changePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
    });

    final now = DateTime.now();
    switch (period) {
      case 'This Week':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate = now;
        break;
      case 'This Month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      case 'Last 3 Months':
        _startDate = DateTime(now.year, now.month - 3, 1);
        _endDate = now;
        break;
      case 'This Year':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = now;
        break;
      case 'Custom Range':
        _selectCustomDateRange();
        return;
    }

    _loadReportData();
  }

  Future<void> _selectCustomDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 730)),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadReportData();
    } else {
      setState(() {
        _selectedPeriod = 'This Month';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<ExpenseProvider, UserProvider>(
        builder: (context, expenseProvider, userProvider, child) {
          return CustomScrollView(
            slivers: [
              CustomAppBar(
                title: 'Reports & Analytics',
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.calendar_month),
                    onSelected: _changePeriod,
                    itemBuilder: (context) => _periods
                        .map((period) => PopupMenuItem(
                              value: period,
                              child: Row(
                                children: [
                                  Icon(
                                    period == _selectedPeriod
                                        ? Icons.check
                                        : Icons.calendar_today,
                                    color: period == _selectedPeriod
                                        ? AppColors.primary
                                        : AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(period),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),

              // Period Header
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(AppConstants.mediumSpacing),
                  padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius:
                        BorderRadius.circular(AppConstants.mediumRadius),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _selectedPeriod,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                      ),
                      if (_selectedPeriod == 'Custom Range')
                        Text(
                          '${DateFormat('MMM d, yyyy').format(_startDate)} - ${DateFormat('MMM d, yyyy').format(_endDate)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onPrimaryContainer,
                                  ),
                        ),
                    ],
                  ),
                ),
              ),

              // Summary Cards
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.mediumSpacing),
                    children: [
                      ReportSummaryCard(
                        title: 'Total Expenses',
                        value: AppUtils.formatCurrency(
                            expenseProvider.totalExpensesForPeriod),
                        icon: Icons.trending_up,
                        color: AppColors.error,
                        trend: expenseProvider.expenseTrend,
                      ),
                      ReportSummaryCard(
                        title: 'Avg Daily',
                        value: AppUtils.formatCurrency(
                            expenseProvider.averageDailyExpensesReport),
                        icon: Icons.calendar_today,
                        color: AppColors.secondary,
                      ),
                      ReportSummaryCard(
                        title: 'Categories',
                        value: expenseProvider.activeCategoriesCount.toString(),
                        icon: Icons.category,
                        color: AppColors.tertiary,
                      ),
                      ReportSummaryCard(
                        title: 'Transactions',
                        value: expenseProvider.totalTransactionsForPeriod
                            .toString(),
                        icon: Icons.receipt,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Bar
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(AppConstants.mediumSpacing),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius:
                        BorderRadius.circular(AppConstants.mediumRadius),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppConstants.mediumRadius),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.onSurfaceVariant,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Categories'),
                      Tab(text: 'Trends'),
                      Tab(text: 'Budget'),
                    ],
                  ),
                ),
              ),

              // Tab Content
              SliverFillRemaining(
                child: expenseProvider.isLoading
                    ? const LoadingWidget()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(expenseProvider, userProvider),
                          _buildCategoriesTab(expenseProvider),
                          _buildTrendsTab(expenseProvider),
                          _buildBudgetTab(expenseProvider, userProvider),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(
      ExpenseProvider expenseProvider, UserProvider userProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Spending Pattern Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Spending Pattern',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  SizedBox(
                    height: 200,
                    child: SpendingPatternChart(
                      data: expenseProvider.dailySpendingData,
                      startDate: _startDate,
                      endDate: _endDate,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Top Categories
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Top Spending Categories',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  ...expenseProvider.topCategories.take(5).map(
                        (categoryData) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppUtils.getCategoryColor(
                                      categoryData.category)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              AppUtils.getCategoryIcon(categoryData.category),
                              color: AppUtils.getCategoryColor(
                                  categoryData.category),
                            ),
                          ),
                          title: Text(categoryData.category),
                          subtitle: Text('${categoryData.count} transactions'),
                          trailing: Text(
                            AppUtils.formatCurrency(categoryData.amount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Insights Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: AppColors.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'Insights',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  ...expenseProvider
                      .generateInsights(
                          _startDate, _endDate, userProvider.monthlyIncome)
                      .map((insight) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  insight.type == InsightType.warning
                                      ? Icons.warning_amber
                                      : insight.type == InsightType.positive
                                          ? Icons.check_circle
                                          : Icons.info,
                                  color: insight.type == InsightType.warning
                                      ? Colors.orange
                                      : insight.type == InsightType.positive
                                          ? Colors.green
                                          : AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    insight.message,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(ExpenseProvider expenseProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        children: [
          // Category Breakdown Pie Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Breakdown',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  SizedBox(
                    height: 250,
                    child: CategoryBreakdownChart(
                      data: expenseProvider.categoryBreakdownData,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Category Details
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Analysis',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  ...expenseProvider.categoryAnalysisData.map(
                    (categoryData) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppUtils.getCategoryColor(
                                          categoryData.category)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  AppUtils.getCategoryIcon(
                                      categoryData.category),
                                  color: AppUtils.getCategoryColor(
                                      categoryData.category),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  categoryData.category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                AppUtils.formatCurrency(categoryData.amount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transactions',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                    ),
                                    Text(
                                      categoryData.count.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Average',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                    ),
                                    Text(
                                      AppUtils.formatCurrency(
                                          categoryData.average),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Percentage',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                    ),
                                    Text(
                                      '${categoryData.percentage.toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab(ExpenseProvider expenseProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        children: [
          // Monthly Trend Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Spending Trend',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  SizedBox(
                    height: 200,
                    child: MonthlyTrendChart(
                      data: expenseProvider.monthlyTrendData,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Weekly Pattern
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Spending Pattern',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  SizedBox(
                    height: 150,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceEvenly,
                        maxY: expenseProvider.weeklyPatternData.isNotEmpty
                            ? expenseProvider.weeklyPatternData.values
                                    .reduce((a, b) => a > b ? a : b) *
                                1.2
                            : 100,
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                const days = [
                                  'Mon',
                                  'Tue',
                                  'Wed',
                                  'Thu',
                                  'Fri',
                                  'Sat',
                                  'Sun'
                                ];
                                return Text(
                                  days[value.toInt()],
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: expenseProvider.weeklyPatternData.entries
                            .map((entry) {
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value,
                                color: AppColors.primary,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetTab(
      ExpenseProvider expenseProvider, UserProvider userProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        children: [
          // Budget vs Actual Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget vs Actual Spending',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  SizedBox(
                    height: 200,
                    child: BudgetVsActualChart(
                      budgetData: expenseProvider.budgetVsActualData,
                      monthlyIncome: userProvider.monthlyIncome,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Budget Health Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget Health',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  _buildBudgetHealthItem(
                    'Income',
                    AppUtils.formatCurrency(userProvider.monthlyIncome),
                    Colors.green,
                    1.0,
                  ),
                  _buildBudgetHealthItem(
                    'Expenses',
                    AppUtils.formatCurrency(
                        expenseProvider.totalExpensesForPeriod),
                    AppColors.error,
                    expenseProvider.totalExpensesForPeriod /
                        userProvider.monthlyIncome,
                  ),
                  _buildBudgetHealthItem(
                    'Savings',
                    AppUtils.formatCurrency(userProvider.monthlyIncome -
                        expenseProvider.totalExpensesForPeriod),
                    AppColors.secondary,
                    (userProvider.monthlyIncome -
                            expenseProvider.totalExpensesForPeriod) /
                        userProvider.monthlyIncome,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetHealthItem(
      String title, String amount, Color color, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage.clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const SizedBox(height: 4),
          Text(
            '${(percentage * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
