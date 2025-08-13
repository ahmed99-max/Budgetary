import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/expense_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/widgets/neumorphic_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    await Future.wait([userProvider.loadUserProfile(), expenseProvider.loadExpenses()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildQuickStats(),
                  const SizedBox(height: 20),
                  _buildBudgetProgress(),
                  const SizedBox(height: 20),
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  _buildRecentTransactions(),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-expense'),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.userProfile;
        return SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.background,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good ${_getGreeting()},', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant)),
                Text(user?.firstName ?? 'User', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: [
            IconButton(onPressed: () => AppUtils.showSnackBar(context, 'No notifications'), icon: const Icon(Icons.notifications_outlined)),
            const SizedBox(width: 16),
          ],
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Consumer2<ExpenseProvider, UserProvider>(
      builder: (context, expenseProvider, userProvider, child) {
        final todayExpenses = expenseProvider.todayExpenses;
        final monthlyExpenses = expenseProvider.monthlyExpenses;
        final monthlyIncome = userProvider.userProfile?.totalIncome ?? 0.0;
        final balance = monthlyIncome - monthlyExpenses;

        return Row(
          children: [
            Expanded(child: _buildStatCard('Today', AppUtils.formatCurrency(todayExpenses), Icons.today, AppColors.primary)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Month', AppUtils.formatCurrency(monthlyExpenses), Icons.calendar_month, AppColors.secondary)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Balance', AppUtils.formatCurrency(balance), Icons.account_balance_wallet, balance >= 0 ? Colors.green : Colors.red)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String amount, IconData icon, Color color) {
    return NeumorphicContainer(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(amount, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildBudgetProgress() {
    return Consumer2<ExpenseProvider, UserProvider>(
      builder: (context, expenseProvider, userProvider, child) {
        final monthlyBudget = userProvider.userProfile?.monthlyBudget ?? 0.0;
        final monthlyExpenses = expenseProvider.monthlyExpenses;
        final percentage = monthlyBudget > 0 ? (monthlyExpenses / monthlyBudget) : 0.0;

        return NeumorphicContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monthly Budget Progress', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(percentage > 0.8 ? Colors.red : AppColors.primary),
                minHeight: 8,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Spent: ${AppUtils.formatCurrency(monthlyExpenses)}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('Budget: ${AppUtils.formatCurrency(monthlyBudget)}', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return NeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton('Add Expense', Icons.add, () => context.push('/add-expense')),
              _buildActionButton('View Reports', Icons.bar_chart, () => context.go('/reports')),
              _buildActionButton('Set Budget', Icons.savings, () => context.go('/budget')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return NeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Transactions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => context.go('/expenses'), child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 16),
          const Center(child: Text('No recent transactions')),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
