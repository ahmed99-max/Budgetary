import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/expense_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../models/expense.dart';
import '../expenses_tab.dart';
import '../reports_tab.dart';
import '../profile_tab.dart'; // Added import for Profile tab

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    await Future.wait<void>([
      Provider.of<UserProvider>(context, listen: false).loadUserProfile(),
      Provider.of<ExpenseProvider>(context, listen: false).loadExpenses(),
    ]);
  }

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _currentIndex == 0
          ? _buildDashboardTab()
          : _currentIndex == 1
              ? const ExpensesScreen()
              : _currentIndex == 2
                  ? const ReportsScreen()
                  : const ProfileScreen(), // Added Profile tab
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            // Added item for Profile
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          _sliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.largeSpacing),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _quickStats(),
                const SizedBox(height: AppConstants.largeSpacing),
                _budgetProgress(),
                const SizedBox(height: AppConstants.largeSpacing),
                _recentTransactions(),
                const SizedBox(height: AppConstants.largeSpacing),
                _quickActions(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sliverAppBar() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final profile = userProvider.userProfile;
        final firstName = profile?.firstName ?? 'User';
        final greeting = _greeting();

        return SliverAppBar(
          expandedHeight: 120,
          pinned: true,
          backgroundColor: AppColors.surface,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(
              left: AppConstants.largeSpacing,
              bottom: AppConstants.smallSpacing,
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good $greeting,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                Text(
                  firstName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              onPressed: () =>
                  AppUtils.showSnackBar(context, 'No new notifications'),
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppConstants.smallSpacing),
          ],
        );
      },
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _quickStats() {
    return Consumer2<ExpenseProvider, UserProvider>(
      builder: (context, expenseProv, userProv, child) {
        final today = expenseProv.todayExpenses;
        final month = expenseProv.monthlyExpenses;
        final income = userProv.monthlyIncome;
        final balance = income - month;

        return Row(
          children: [
            _statCard('Today', today, Icons.today, AppColors.primary),
            const SizedBox(width: AppConstants.mediumSpacing),
            _statCard(
                'Month', month, Icons.calendar_month, AppColors.secondary),
            const SizedBox(width: AppConstants.mediumSpacing),
            _statCard(
              'Balance',
              balance,
              Icons.account_balance_wallet,
              balance >= 0 ? AppColors.success : AppColors.error,
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, double amount, IconData icon, Color color) {
    return Expanded(
      child: NeumorphicContainer(
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppConstants.smallSpacing),
            Text(
              AppUtils.formatCurrency(amount),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _budgetProgress() {
    return Consumer2<ExpenseProvider, UserProvider>(
      builder: (context, expenseProv, userProv, child) {
        final budget = userProv.monthlyIncome;
        final spent = expenseProv.monthlyExpenses;
        final pct = budget > 0 ? (spent / budget) : 0.0;

        return NeumorphicContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Budget Progress',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.smallSpacing),
              LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  pct > 0.8 ? AppColors.error : AppColors.primary,
                ),
                minHeight: 8,
              ),
              const SizedBox(height: AppConstants.smallSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Spent: ${AppUtils.formatCurrency(spent)}'),
                  Text('Budget: ${AppUtils.formatCurrency(budget)}'),
                ],
              ),
              const SizedBox(height: AppConstants.smallSpacing),
              Text(
                '${(pct * 100).toStringAsFixed(1)}% of budget used',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: pct > 0.8
                          ? AppColors.error
                          : AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _recentTransactions() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final recentExpenses =
            expenseProvider.expenses.take(5).toList(); // Get last 5 expenses

        return NeumorphicContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentIndex = 1),
                    child: Text(
                      'View All',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.mediumSpacing),
              if (recentExpenses.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppConstants.largeSpacing),
                    child: Text('No transactions yet'),
                  ),
                )
              else
                ...recentExpenses
                    .map((expense) => _buildTransactionTile(expense)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionTile(Expense expense) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.smallSpacing),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppUtils.getCategoryColor(expense.category)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              AppUtils.getCategoryIcon(expense.category),
              color: AppUtils.getCategoryColor(expense.category),
              size: 20,
            ),
          ),
          const SizedBox(width: AppConstants.mediumSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  expense.category,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppUtils.formatCurrency(expense.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              Text(
                AppUtils.formatDate(expense.date),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return NeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          Row(
            children: [
              _actionButton(
                'Add Expense',
                Icons.add_circle,
                AppColors.primary,
                () => setState(() => _currentIndex = 1),
              ),
              const SizedBox(width: AppConstants.mediumSpacing),
              _actionButton(
                'View Reports',
                Icons.analytics,
                AppColors.secondary,
                () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.mediumSpacing),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: AppConstants.smallSpacing),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
