import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/providers/expense_provider.dart';
import '../../models/expense.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../shared/widgets/custom-app-bar.dart';
import '../../shared/widgets/loading-widget.dart';
import '../../../shared/widgets/empty-state-widget.dart';
import '../../features/expenses/widgets/add_expense_bottom_sheet.dart';
import '../../features/expenses/widgets/expense_filter.dart';
import '../../features/expenses/widgets/expense_stats_card.dart';
import '../expenses/screens/add_expense_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).loadExpenses();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddExpenseBottomSheet({Expense? expense}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseBottomSheet(
        expense: expense,
        onAddExpense: (newExpense) {
          final ep = Provider.of<ExpenseProvider>(context, listen: false);
          if (expense != null) {
            ep.updateExpense(newExpense);
          } else {
            ep.addExpense(newExpense);
          }
        },
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
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
        _selectedDateRange = picked;
      });
      if (mounted) {
        Provider.of<ExpenseProvider>(context, listen: false)
            .filterExpensesByDateRange(picked);
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedFilter = 'All';
      _selectedDateRange = null;
    });
    Provider.of<ExpenseProvider>(context, listen: false).clearFilters();
  }

  void _deleteExpense(Expense expense) {
    Provider.of<ExpenseProvider>(context, listen: false)
        .deleteExpense(expense.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            Provider.of<ExpenseProvider>(context, listen: false)
                .undoDeleteExpense(expense);
          },
        ),
      ),
    );
  }

  void _editExpense(Expense expense) {
    _showAddExpenseBottomSheet(expense: expense);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          return CustomScrollView(
            slivers: [
              CustomAppBar(
                title: 'Expenses',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilterOptions(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAddExpenseBottomSheet,
                  ),
                ],
              ),

              // Stats Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                  child: ExpenseStatsCard(
                    expenses: expenseProvider.expenses,
                    totalExpenses: expenseProvider.totalExpenses,
                    monthlyExpenses: expenseProvider.monthlyExpenses,
                    weeklyExpenses: expenseProvider.weeklyExpenses,
                    dailyAverage: expenseProvider.dailyAverageExpenses,
                  ),
                ),
              ),

              // Filter Chips
              if (_selectedFilter != 'All' || _selectedDateRange != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.mediumSpacing,
                    ),
                    child: Row(
                      children: [
                        if (_selectedFilter != 'All')
                          Chip(
                            label: Text(_selectedFilter),
                            onDeleted: () {
                              setState(() {
                                _selectedFilter = 'All';
                              });
                              expenseProvider
                                  .filterExpensesByCategory(_selectedFilter);
                            },
                          ),
                        if (_selectedDateRange != null) ...[
                          const SizedBox(width: AppConstants.smallSpacing),
                          Chip(
                            label: Text(
                              '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
                            ),
                            onDeleted: () {
                              setState(() {
                                _selectedDateRange = null;
                              });
                              expenseProvider.clearFilters();
                            },
                          ),
                        ],
                        const Spacer(),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  ),
                ),

              // Tab Bar
              SliverToBoxAdapter(
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Recent'),
                    Tab(text: 'Categories'),
                    Tab(text: 'Monthly'),
                  ],
                ),
              ),

              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRecentExpenses(expenseProvider),
                    _buildCategoryExpenses(expenseProvider),
                    _buildMonthlyExpenses(expenseProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddExpenseModal(
            context), // Added the FAB here to call the modal
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecentExpenses(ExpenseProvider expenseProvider) {
    if (expenseProvider.isLoading) {
      return const LoadingWidget();
    }

    final expenses = expenseProvider.filteredExpenses;

    if (expenses.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.receipt_long,
        title: 'No Expenses Found',
        message: 'Start tracking your expenses by adding your first expense.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        return _buildExpenseItem(expense);
      },
    );
  }

  Widget _buildCategoryExpenses(ExpenseProvider expenseProvider) {
    if (expenseProvider.isLoading) {
      return const LoadingWidget();
    }

    final categoryExpenses = expenseProvider.expensesByCategory;

    if (categoryExpenses.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.category,
        title: 'No Categories Found',
        message: 'Your expense categories will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      itemCount: categoryExpenses.keys.length,
      itemBuilder: (context, index) {
        final category = categoryExpenses.keys.elementAt(index);
        final expenses = categoryExpenses[category]!;
        final categoryTotal =
            expenses.fold<double>(0, (sum, e) => sum + e.amount);

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.mediumSpacing),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppUtils.getCategoryColor(category).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                AppUtils.getCategoryIcon(category),
                color: AppUtils.getCategoryColor(category),
              ),
            ),
            title: Text(category,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${expenses.length} expenses • ${AppUtils.formatCurrency(categoryTotal)}',
            ),
            children: expenses
                .map((e) => _buildExpenseItem(e, showCategory: false))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildMonthlyExpenses(ExpenseProvider expenseProvider) {
    if (expenseProvider.isLoading) {
      return const LoadingWidget();
    }

    final monthlyExpenses = expenseProvider.monthlyExpensesData;

    if (monthlyExpenses.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.calendar_month,
        title: 'No Monthly Data',
        message: 'Your monthly expense data will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      itemCount: monthlyExpenses.keys.length,
      itemBuilder: (context, index) {
        final month = monthlyExpenses.keys.elementAt(index);
        final expenses = monthlyExpenses[month]!;
        final monthTotal = expenses.fold<double>(0, (sum, e) => sum + e.amount);

        return Card(
          margin: const EdgeInsets.only(bottom: AppConstants.mediumSpacing),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_month, color: AppColors.primary),
            ),
            title: Text(
              DateFormat('MMMM yyyy').format(month),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${expenses.length} expenses • ${AppUtils.formatCurrency(monthTotal)}',
            ),
            children: expenses.map((e) => _buildExpenseItem(e)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildExpenseItem(Expense expense, {bool showCategory = true}) {
    return Slidable(
      key: ValueKey(expense.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _editExpense(expense),
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) => _deleteExpense(expense),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppUtils.getCategoryColor(expense.category).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            AppUtils.getCategoryIcon(expense.category),
            color: AppUtils.getCategoryColor(expense.category),
          ),
        ),
        title: Text(expense.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCategory)
              Text(
                expense.category,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            Text(
              DateFormat('MMM d, yyyy • h:mm a').format(expense.date),
              style: TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            if (expense.note.isNotEmpty)
              Text(
                expense.note,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Text(
          AppUtils.formatCurrency(expense.amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.error,
          ),
        ),
        onTap: () => _showExpenseDetails(expense),
      ),
    );
  }

  void _showExpenseDetails(Expense expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.largeSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.largeSpacing),

                // Header: category icon + title + amount
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppUtils.getCategoryColor(expense.category)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        AppUtils.getCategoryIcon(expense.category),
                        color: AppUtils.getCategoryColor(expense.category),
                      ),
                    ),
                    const SizedBox(width: AppConstants.mediumSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            expense.category,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      AppUtils.formatCurrency(expense.amount),
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.largeSpacing),

                // Details list
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: DateFormat('EEEE, MMM d, yyyy').format(expense.date),
                ),
                _buildDetailRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: DateFormat('h:mm a').format(expense.date),
                ),
                if (expense.paymentMethod.isNotEmpty)
                  _buildDetailRow(
                    icon: Icons.payment,
                    label: 'Payment Method',
                    value: expense.paymentMethod,
                  ),

                // Note section
                if (expense.note.isNotEmpty) ...[
                  const SizedBox(height: AppConstants.mediumSpacing),
                  Text(
                    'Note',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppConstants.smallSpacing),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.mediumSpacing),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppConstants.mediumRadius),
                    ),
                    child: Text(
                      expense.note,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],

                const SizedBox(height: AppConstants.largeSpacing),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _editExpense(expense);
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: AppConstants.mediumSpacing),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteExpense(expense);
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: AppConstants.smallSpacing),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ExpenseFilterWidget(
        selectedFilter: _selectedFilter,
        selectedDateRange: _selectedDateRange,
        onFilterChanged: (filter) {
          setState(() => _selectedFilter = filter);
          Provider.of<ExpenseProvider>(context, listen: false)
              .filterExpensesByCategory(filter);
        },
        onDateRangeChanged: (dateRange) {
          setState(() => _selectedDateRange = dateRange);
          if (dateRange != null) {
            Provider.of<ExpenseProvider>(context, listen: false)
                .filterExpensesByDateRange(dateRange);
          }
        },
        onClearFilters: _clearFilters,
      ),
    );
  }
}
