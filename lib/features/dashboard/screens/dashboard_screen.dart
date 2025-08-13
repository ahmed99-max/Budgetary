import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/expense_provider.dart';
import '../../../core/providers/budget_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../shared/widgets/responsive_builder.dart';
import '../../../shared/widgets/neumorphic_container.dart';
import '../../../shared/widgets/neumorphic_button.dart';
import '../../../shared/widgets/neumorphic_app_bar.dart';
import '../../../shared/widgets/neumorphic_bottom_nav.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/spending_chart.dart';
import '../widgets/quick_actions_panel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;
  int _currentBottomNavIndex = 0;

  final List<NeumorphicBottomNavigationItem> _bottomNavItems = [
    const NeumorphicBottomNavigationItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    const NeumorphicBottomNavigationItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      label: 'Expenses',
    ),
    const NeumorphicBottomNavigationItem(
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
      label: 'Add',
    ),
    const NeumorphicBottomNavigationItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart,
      label: 'Reports',
    ),
    const NeumorphicBottomNavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _refreshAnimation = CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    );

    _loadDashboardData();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

    await Future.wait([
      userProvider.loadUserData(),
      expenseProvider.loadExpenses(),
      budgetProvider.loadBudgets(),
    ]);
  }

  Future<void> _onRefresh() async {
    _refreshController.forward();
    await _loadDashboardData();
    await Future.delayed(const Duration(milliseconds: 500));
    _refreshController.reset();
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentBottomNavIndex = index);

    switch (index) {
      case 0:
        // Dashboard - already here
        break;
      case 1:
        // Navigate to expenses
        Navigator.of(context).pushNamed('/expenses');
        break;
      case 2:
        // Navigate to add expense
        Navigator.of(context).pushNamed('/expenses/add');
        break;
      case 3:
        // Navigate to reports
        Navigator.of(context).pushNamed('/reports');
        break;
      case 4:
        // Navigate to profile
        Navigator.of(context).pushNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<ThemeProvider>(context).isDarkMode
          ? const Color(0xFF2C3E50)
          : const Color(0xFFE0E5EC),
      body: Consumer4<UserProvider, ExpenseProvider, BudgetProvider, ThemeProvider>(
        builder: (context, userProvider, expenseProvider, budgetProvider, themeProvider, child) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            backgroundColor: themeProvider.isDarkMode
                ? const Color(0xFF34495E)
                : const Color(0xFFECF0F1),
            color: const Color(0xFF6C7CE7),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Custom App Bar
                SliverToBoxAdapter(
                  child: _buildCustomAppBar(userProvider, themeProvider)
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3),
                ),

                // Greeting and Summary Cards
                SliverToBoxAdapter(
                  child: _buildGreetingSection(userProvider, themeProvider)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3),
                ),

                // Budget Overview
                SliverToBoxAdapter(
                  child: BudgetOverviewCard(
                    totalBudget: budgetProvider.totalBudget,
                    totalSpent: expenseProvider.monthlyTotal,
                    budgetProgress: budgetProvider.overallProgress,
                  )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: -0.3),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: QuickActionsPanel(
                    onAddExpense: () => Navigator.of(context).pushNamed('/expenses/add'),
                    onViewReports: () => Navigator.of(context).pushNamed('/reports'),
                    onScanReceipt: () => Navigator.of(context).pushNamed('/receipt-scanner'),
                    onSetBudget: () => Navigator.of(context).pushNamed('/budget/setup'),
                  )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 600.ms)
                    .slideX(begin: 0.3),
                ),

                // Spending Chart
                SliverToBoxAdapter(
                  child: SpendingChart(
                    expenses: expenseProvider.recentExpenses.take(7).toList(),
                    period: 'Last 7 Days',
                  )
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3),
                ),

                // Recent Transactions
                SliverToBoxAdapter(
                  child: RecentTransactionsList(
                    transactions: expenseProvider.recentExpenses.take(10).toList(),
                    onViewAll: () => Navigator.of(context).pushNamed('/expenses'),
                  )
                    .animate(delay: 1000.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.3),
                ),

                // Bottom spacing for navigation
                SliverToBoxAdapter(
                  child: SizedBox(height: 100.rh),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: NeumorphicBottomNavigation(
        items: _bottomNavItems,
        currentIndex: _currentBottomNavIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildCustomAppBar(UserProvider userProvider, ThemeProvider themeProvider) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.rw, 50.rh, 20.rw, 20.rh),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // App Logo/Title
          NeumorphicContainer(
            padding: EdgeInsets.symmetric(horizontal: 16.rw, vertical: 8.rh),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: const Color(0xFF6C7CE7),
                  size: 24.rr,
                ),
                SizedBox(width: 8.rw),
                Text(
                  'Budgetary',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
                    fontWeight: FontWeight.w700,
                    color: themeProvider.isDarkMode
                        ? const Color(0xFFECF0F1)
                        : const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),

          // Notification and Profile
          Row(
            children: [
              NeumorphicButton(
                onPressed: () {
                  // Navigate to notifications
                },
                padding: EdgeInsets.all(12.rr),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 24.rr,
                      color: themeProvider.isDarkMode
                          ? const Color(0xFFECF0F1)
                          : const Color(0xFF2C3E50),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8.rr,
                        height: 8.rr,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE74C3C),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.rw),
              NeumorphicButton(
                onPressed: () => Navigator.of(context).pushNamed('/profile'),
                padding: EdgeInsets.all(8.rr),
                child: CircleAvatar(
                  radius: 16.rr,
                  backgroundColor: const Color(0xFF6C7CE7),
                  backgroundImage: userProvider.currentUser?.profilePicture != null
                      ? NetworkImage(userProvider.currentUser!.profilePicture!)
                      : null,
                  child: userProvider.currentUser?.profilePicture == null
                      ? Text(
                          userProvider.currentUser?.initials ?? 'U',
                          style: TextStyle(
                            fontSize: 14.rf,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection(UserProvider userProvider, ThemeProvider themeProvider) {
    final currentHour = DateTime.now().hour;
    String greeting;
    if (currentHour < 12) {
      greeting = 'Good Morning';
    } else if (currentHour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    final user = userProvider.currentUser;
    final firstName = user?.firstName ?? 'User';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.rw),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            '$greeting,',
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w400,
              color: themeProvider.isDarkMode
                  ? const Color(0xFFBDC3C7)
                  : const Color(0xFF7F8C8D),
            ),
          ),
          SizedBox(height: 4.rh),
          Text(
            firstName,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 28),
              fontWeight: FontWeight.w700,
              color: themeProvider.isDarkMode
                  ? const Color(0xFFECF0F1)
                  : const Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 20.rh),

          // Today's Summary Cards
          ResponsiveBuilder(
            builder: (context, deviceType) {
              if (deviceType == DeviceType.mobile) {
                return Column(children: _buildSummaryCards(userProvider));
              } else {
                return Row(
                  children: _buildSummaryCards(userProvider)
                      .map((card) => Expanded(child: card))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSummaryCards(UserProvider userProvider) {
    final user = userProvider.currentUser;
    final today = DateTime.now();
    final formatter = NumberFormat.currency(symbol: '\$');

    return [
      _SummaryCard(
        title: 'Total Balance',
        amount: formatter.format(user?.netWorth ?? 0),
        icon: Icons.account_balance,
        color: const Color(0xFF6C7CE7),
        trend: '+2.5%',
        isPositive: true,
      ),
      SizedBox(height: 16.rh, width: 16.rw),
      _SummaryCard(
        title: 'Monthly Spent',
        amount: formatter.format(user?.totalExpenses ?? 0),
        icon: Icons.trending_down,
        color: const Color(0xFFE74C3C),
        trend: '-5.2%',
        isPositive: false,
      ),
      SizedBox(height: 16.rh, width: 16.rw),
      _SummaryCard(
        title: 'Savings',
        amount: formatter.format(user?.totalSavings ?? 0),
        icon: Icons.savings,
        color: const Color(0xFF27AE60),
        trend: '+12.8%',
        isPositive: true,
      ),
    ];
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final String trend;
  final bool isPositive;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return NeumorphicContainer(
      margin: EdgeInsets.symmetric(vertical: 4.rh),
      padding: EdgeInsets.all(16.rr),
      child: Row(
        children: [
          // Icon
          NeumorphicContainer(
            padding: EdgeInsets.all(12.rr),
            style: context.convexStyle.copyWith(
              color: color.withOpacity(0.1),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.rr,
            ),
          ),
          SizedBox(width: 16.rw),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                    fontWeight: FontWeight.w500,
                    color: themeProvider.isDarkMode
                        ? const Color(0xFFBDC3C7)
                        : const Color(0xFF7F8C8D),
                  ),
                ),
                SizedBox(height: 4.rh),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.w700,
                    color: themeProvider.isDarkMode
                        ? const Color(0xFFECF0F1)
                        : const Color(0xFF2C3E50),
                  ),
                ),
                SizedBox(height: 4.rh),
                Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: isPositive ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                      size: 14.rr,
                    ),
                    SizedBox(width: 4.rw),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w600,
                        color: isPositive ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
