import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/expense_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/widgets/neumorphic_container.dart';

class BudgetGoalsScreen extends StatefulWidget {
  const BudgetGoalsScreen({super.key});

  @override
  State<BudgetGoalsScreen> createState() => _BudgetGoalsScreenState();
}

class _BudgetGoalsScreenState extends State<BudgetGoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Budget & Goals'),
        actions: [IconButton(onPressed: () => AppUtils.showSnackBar(context, 'Settings coming soon!'), icon: const Icon(Icons.settings))],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Budget', icon: Icon(Icons.account_balance_wallet)),
            Tab(text: 'Goals', icon: Icon(Icons.flag)),
            Tab(text: 'Plans', icon: Icon(Icons.timeline)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildBudgetTab(), _buildGoalsTab(), _buildPlansTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppUtils.showSnackBar(context, 'Add feature coming soon!'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBudgetTab() {
    return Consumer2<UserProvider, ExpenseProvider>(
      builder: (context, userProvider, expenseProvider, child) {
        final monthlyBudget = userProvider.userProfile?.monthlyBudget ?? 0.0;
        final monthlyExpenses = expenseProvider.monthlyExpenses;
        final remaining = monthlyBudget - monthlyExpenses;
        final percentage = monthlyBudget > 0 ? (monthlyExpenses / monthlyBudget) : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              NeumorphicContainer(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Monthly Budget', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getProgressColor(percentage).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('${(percentage * 100).toInt()}%', style: TextStyle(color: _getProgressColor(percentage), fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: percentage.clamp(0.0, 1.0),
                      backgroundColor: AppColors.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor(percentage)),
                      minHeight: 8,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Spent: ${AppUtils.formatCurrency(monthlyExpenses)}'),
                        Text('Remaining: ${AppUtils.formatCurrency(remaining)}', 
                             style: TextStyle(color: remaining >= 0 ? Colors.green : Colors.red)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildCategoryBudgets(expenseProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildGoalCard('Emergency Fund', 25000, 100000, Icons.security, Colors.blue),
          const SizedBox(height: 16),
          _buildGoalCard('Vacation Fund', 15000, 50000, Icons.flight, Colors.orange),
          const SizedBox(height: 16),
          _buildGoalCard('New Laptop', 30000, 80000, Icons.laptop, Colors.purple),
          const SizedBox(height: 16),
          _buildGoalCard('Home Down Payment', 200000, 1000000, Icons.home, Colors.green),
        ],
      ),
    );
  }

  Widget _buildPlansTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildPlanCard('Retirement Savings', 5000, '25 years', 12.0, 2500000, Icons.elderly),
          const SizedBox(height: 16),
          _buildPlanCard('Child Education', 3000, '15 years', 10.0, 950000, Icons.school),
          const SizedBox(height: 16),
          _buildPlanCard('Emergency Fund SIP', 2000, '3 years', 8.0, 85000, Icons.emergency),
        ],
      ),
    );
  }

  Widget _buildCategoryBudgets(ExpenseProvider expenseProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category Budgets', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildCategoryBudgetCard('Food & Dining', 15000, 12000, Colors.orange),
        const SizedBox(height: 12),
        _buildCategoryBudgetCard('Transportation', 8000, 6500, Colors.blue),
        const SizedBox(height: 12),
        _buildCategoryBudgetCard('Shopping', 10000, 11500, Colors.red),
        const SizedBox(height: 12),
        _buildCategoryBudgetCard('Entertainment', 5000, 3200, Colors.purple),
      ],
    );
  }

  Widget _buildCategoryBudgetCard(String category, double budget, double spent, Color color) {
    final percentage = budget > 0 ? (spent / budget) : 0.0;

    return NeumorphicContainer(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.category, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: percentage.clamp(0.0, 1.0), valueColor: AlwaysStoppedAnimation(color)),
                const SizedBox(height: 4),
                Text('${AppUtils.formatCurrency(spent)} / ${AppUtils.formatCurrency(budget)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String title, double current, double target, IconData icon, Color color) {
    final percentage = target > 0 ? (current / target) : 0.0;

    return NeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: percentage.clamp(0.0, 1.0), valueColor: AlwaysStoppedAnimation(color)),
          const SizedBox(height: 8),
          Text('${AppUtils.formatCurrency(current)} of ${AppUtils.formatCurrency(target)}'),
          Text('${(percentage * 100).toInt()}% Complete', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String title, double monthly, String duration, double returns, double maturity, IconData icon) {
    return NeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 16),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          Text('Monthly: ${AppUtils.formatCurrency(monthly)}'),
          Text('Duration: $duration'),
          Text('Expected Return: ${returns}%'),
          Text('Maturity: ${AppUtils.formatCurrency(maturity)}', 
               style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 0.7) return Colors.green;
    if (percentage < 0.9) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
