import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/budget_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../models/budget.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../shared/widgets/custom-app-bar.dart';
import '../../shared/widgets/loading-widget.dart';
import '../../shared/widgets/empty-state-widget.dart';
import '../../shared/widgets/budget_card.dart';
import '../../features/expenses/widgets/add_budget_bottom_sheet.dart';
import '../../features/expenses/widgets/budget_overview_chart.dart';
import '../../features/expenses/widgets/savings_goal_card.dart';
import '../../features/expenses/widgets/add_savings_bottom_sheet.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BudgetProvider>(context, listen: false).loadBudgets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddBudgetBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddBudgetBottomSheet(),
    );
  }

  void _showAddSavingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddSavingsBottomSheet(),
    );
  }

  void _editBudget(Budget budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddBudgetBottomSheet(budget: budget),
    );
  }

  void _deleteBudget(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
            'Are you sure you want to delete the "${budget.category}" budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<BudgetProvider>(context, listen: false)
                  .deleteBudget(budget.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budget deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<BudgetProvider, UserProvider>(
        builder: (context, budgetProvider, userProvider, child) {
          return CustomScrollView(
            slivers: [
              CustomAppBar(
                title: 'Budget & Savings',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddOptions(context),
                  ),
                ],
              ),

              // Budget Overview
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(AppConstants.mediumSpacing),
                  padding: const EdgeInsets.all(AppConstants.largeSpacing),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppConstants.largeRadius),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Budget',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                              ),
                              Text(
                                AppUtils.formatCurrency(
                                    budgetProvider.totalBudget),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.largeSpacing),
                      Row(
                        children: [
                          Expanded(
                            child: _buildOverviewItem(
                              'Spent',
                              AppUtils.formatCurrency(
                                  budgetProvider.totalSpent),
                              '${((budgetProvider.totalSpent / budgetProvider.totalBudget) * 100).toStringAsFixed(1)}%',
                              Colors.white,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildOverviewItem(
                              'Remaining',
                              AppUtils.formatCurrency(
                                  budgetProvider.totalBudget -
                                      budgetProvider.totalSpent),
                              '${(((budgetProvider.totalBudget - budgetProvider.totalSpent) / budgetProvider.totalBudget) * 100).toStringAsFixed(1)}%',
                              Colors.white,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Expanded(
                            child: _buildOverviewItem(
                              'Saved',
                              AppUtils.formatCurrency(
                                  budgetProvider.totalSavings),
                              '${((budgetProvider.totalSavings / userProvider.monthlyIncome) * 100).toStringAsFixed(1)}%',
                              Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Bar
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppConstants.mediumSpacing),
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
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    tabs: const [
                      Tab(text: 'Budgets'),
                      Tab(text: 'Savings'),
                      Tab(text: 'Overview'),
                    ],
                  ),
                ),
              ),

              // Tab Content
              SliverFillRemaining(
                child: budgetProvider.isLoading
                    ? const LoadingWidget()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildBudgetsTab(budgetProvider),
                          _buildSavingsTab(budgetProvider),
                          _buildOverviewTab(budgetProvider, userProvider),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildOverviewItem(
      String title, String amount, String percentage, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: color.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          percentage,
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetsTab(BudgetProvider budgetProvider) {
    if (budgetProvider.budgets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        child: Column(
          children: [
            const Expanded(
              child: EmptyStateWidget(
                icon: Icons.account_balance_wallet,
                title: 'No Budgets Yet',
                message:
                    'Create your first budget to start tracking your spending by category.',
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAddBudgetBottomSheet,
                icon: const Icon(Icons.add),
                label: const Text('Create Budget'),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      itemCount: budgetProvider.budgets.length,
      itemBuilder: (context, index) {
        final budget = budgetProvider.budgets[index];
        return BudgetCard(
          budget: budget,
          onEdit: () => _editBudget(budget),
          onDelete: () => _deleteBudget(budget),
          onAddExpense: () => _addExpenseToBudget(budget),
        );
      },
    );
  }

  Widget _buildSavingsTab(BudgetProvider budgetProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Savings Overview Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.largeSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.savings,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Savings',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                          ),
                          Text(
                            AppUtils.formatCurrency(
                                budgetProvider.totalSavings),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'This Month',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                            ),
                            Text(
                              AppUtils.formatCurrency(
                                  budgetProvider.monthlySavings),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Savings Rate',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                            ),
                            Text(
                              '${budgetProvider.savingsRate.toStringAsFixed(1)}%',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
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

          const SizedBox(height: AppConstants.mediumSpacing),

          // Savings Goals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Savings Goals',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton.icon(
                onPressed: _showAddSavingsBottomSheet,
                icon: const Icon(Icons.add),
                label: const Text('Add Goal'),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.smallSpacing),

          if (budgetProvider.savingsGoals.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.largeSpacing),
                child: Column(
                  children: [
                    const Icon(
                      Icons.flag,
                      size: 48,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Savings Goals Yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set savings goals to track your progress and stay motivated.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showAddSavingsBottomSheet,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Goal'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...budgetProvider.savingsGoals.map(
              (goal) => SavingsGoalCard(
                goal: goal,
                onEdit: () => _editSavingsGoal(goal),
                onDelete: () => _deleteSavingsGoal(goal),
                onAddSavings: () => _addSavingsToGoal(goal),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(
      BudgetProvider budgetProvider, UserProvider userProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      child: Column(
        children: [
          // Budget Chart
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget Distribution',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  SizedBox(
                    height: 200,
                    child: BudgetOverviewChart(
                      budgets: budgetProvider.budgets,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Monthly Summary
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  _buildSummaryRow(
                    'Total Income',
                    AppUtils.formatCurrency(userProvider.monthlyIncome),
                    Colors.green,
                  ),
                  _buildSummaryRow(
                    'Total Budget',
                    AppUtils.formatCurrency(budgetProvider.totalBudget),
                    AppColors.primary,
                  ),
                  _buildSummaryRow(
                    'Total Spent',
                    AppUtils.formatCurrency(budgetProvider.totalSpent),
                    AppColors.error,
                  ),
                  _buildSummaryRow(
                    'Remaining Budget',
                    AppUtils.formatCurrency(
                        budgetProvider.totalBudget - budgetProvider.totalSpent),
                    AppColors.secondary,
                  ),
                  const Divider(),
                  _buildSummaryRow(
                    'Available for Savings',
                    AppUtils.formatCurrency(
                        userProvider.monthlyIncome - budgetProvider.totalSpent),
                    AppColors.tertiary,
                    isHighlighted: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Budget Health
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        budgetProvider.budgetHealth == BudgetHealth.good
                            ? Icons.check_circle
                            : budgetProvider.budgetHealth ==
                                    BudgetHealth.warning
                                ? Icons.warning
                                : Icons.error,
                        color: budgetProvider.budgetHealth == BudgetHealth.good
                            ? Colors.green
                            : budgetProvider.budgetHealth ==
                                    BudgetHealth.warning
                                ? Colors.orange
                                : AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Budget Health',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.mediumSpacing),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (budgetProvider.budgetHealth == BudgetHealth.good
                              ? Colors.green
                              : budgetProvider.budgetHealth ==
                                      BudgetHealth.warning
                                  ? Colors.orange
                                  : AppColors.error)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      budgetProvider.getBudgetHealthMessage(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  if (budgetProvider.budgetRecommendations.isNotEmpty) ...[
                    const SizedBox(height: AppConstants.mediumSpacing),
                    Text(
                      'Recommendations',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...budgetProvider.budgetRecommendations.map(
                      (recommendation) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                recommendation,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, Color color,
      {bool isHighlighted = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: isHighlighted
          ? BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
            ),
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
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppConstants.largeSpacing),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Add Budget'),
              subtitle: const Text('Create a new category budget'),
              onTap: () {
                Navigator.pop(context);
                _showAddBudgetBottomSheet();
              },
            ),
            ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('Add Savings Goal'),
              subtitle: const Text('Set a new savings target'),
              onTap: () {
                Navigator.pop(context);
                _showAddSavingsBottomSheet();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addExpenseToBudget(Budget budget) {
    final amountController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Add Expense to ${budget.category}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                final description = descController.text.trim();

                if (amount != null && amount > 0) {
                  // Call your provider's method here
                  Provider.of<BudgetProvider>(context, listen: false)
                      .addExpenseToBudget(budget.id, amount,
                          description); // Implement in provider

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Expense added to ${budget.category}')),
                  );
                }
              },
              child: const Text('Add Expense'),
            ),
          ],
        );
      },
    );
  }

  void _editSavingsGoal(SavingsGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSavingsBottomSheet(goal: goal),
    );
  }

  void _deleteSavingsGoal(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Savings Goal'),
        content: Text(
            'Are you sure you want to delete the "${goal.name}" savings goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<BudgetProvider>(context, listen: false)
                  .deleteSavingsGoal(goal.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Savings goal deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addSavingsToGoal(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) {
        final amountController = TextEditingController();
        return AlertDialog(
          title: Text('Add to ${goal.name}'),
          content: TextField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\$',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (amount != null && amount > 0) {
                  Navigator.pop(context);
                  Provider.of<BudgetProvider>(context, listen: false)
                      .addSavingsToGoal(goal.id, amount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Added ${AppUtils.formatCurrency(amount)} to ${goal.name}'),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
