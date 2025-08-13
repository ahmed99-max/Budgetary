import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/widgets/neumorphic_container.dart';

class ExpenseFilter extends StatefulWidget {
  final String selectedCategory;
  final String selectedPaymentMethod;
  final DateTimeRange? dateRange;
  final Function(String, String, DateTimeRange?) onFiltersChanged;

  const ExpenseFilter({
    super.key,
    required this.selectedCategory,
    required this.selectedPaymentMethod,
    required this.dateRange,
    required this.onFiltersChanged,
  });

  @override
  State<ExpenseFilter> createState() => _ExpenseFilterState();
}

class _ExpenseFilterState extends State<ExpenseFilter> {
  late String _selectedCategory;
  late String _selectedPaymentMethod;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    _selectedPaymentMethod = widget.selectedPaymentMethod;
    _selectedDateRange = widget.dateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.largeRadius),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(
                vertical: AppConstants.mediumSpacing),
            decoration: BoxDecoration(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.largeSpacing),
            child: Row(
              children: [
                Text(
                  'Filter Expenses',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: AppColors.onSurface),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.largeSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryFilter(),
                  const SizedBox(height: AppConstants.largeSpacing),
                  _buildPaymentMethodFilter(),
                  const SizedBox(height: AppConstants.largeSpacing),
                  _buildDateRangeFilter(),
                  const SizedBox(height: AppConstants.extraLargeSpacing),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppConstants.largeSpacing,
                        ),
                      ),
                      child: const Text('Apply Filters'),
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

  Widget _buildCategoryFilter() {
    return NeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.onSurface),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),

          // All Categories Option
          _buildFilterOption(
            'all',
            'All Categories',
            Icons.all_inclusive,
            AppColors.onSurfaceVariant,
            _selectedCategory == 'all',
            (selected) {
              setState(() => _selectedCategory = 'all');
            },
          ),
          const SizedBox(height: AppConstants.smallSpacing),

          // **Individual Categories**
          ...AppConstants.categories.map((category) {
            final id = category['id'] as String? ?? '';
            final name = category['name'] as String? ?? '';
            final iconName = category['icon'] as String? ?? '';
            final colorHex = category['color'] as String? ?? '#000000';

            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
              child: _buildFilterOption(
                id,
                name,
                _getCategoryIcon(iconName),
                AppUtils.hexToColor(colorHex),
                _selectedCategory == id,
                (selected) {
                  setState(() => _selectedCategory = id);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodFilter() {
    return NeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.onSurface),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),

          // All Payment Methods Option
          _buildFilterOption(
            'all',
            'All Payment Methods',
            Icons.all_inclusive,
            AppColors.onSurfaceVariant,
            _selectedPaymentMethod == 'all',
            (selected) {
              setState(() => _selectedPaymentMethod = 'all');
            },
          ),
          const SizedBox(height: AppConstants.smallSpacing),

          // **Individual Payment Methods**
          ...AppConstants.paymentMethods.map((method) {
            final id = method['id'] as String? ?? '';
            final name = method['name'] as String? ?? '';
            final iconName = method['icon'] as String? ?? '';

            return Padding(
              padding: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
              child: _buildFilterOption(
                id,
                name,
                _getPaymentIcon(iconName),
                AppColors.primary,
                _selectedPaymentMethod == id,
                (selected) {
                  setState(() => _selectedPaymentMethod = id);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter() {
    return NeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Range',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.onSurface),
          ),
          const SizedBox(height: AppConstants.mediumSpacing),
          GestureDetector(
            onTap: _selectDateRange,
            child: Container(
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                border: Border.all(
                  color: _selectedDateRange != null
                      ? AppColors.primary
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    color: _selectedDateRange != null
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppConstants.mediumSpacing),
                  Expanded(
                    child: Text(
                      _selectedDateRange != null
                          ? '${AppUtils.formatDate(_selectedDateRange!.start)} - ${AppUtils.formatDate(_selectedDateRange!.end)}'
                          : 'Select date range',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: _selectedDateRange != null
                                ? AppColors.onSurface
                                : AppColors.onSurfaceVariant,
                          ),
                    ),
                  ),
                  if (_selectedDateRange != null)
                    GestureDetector(
                      onTap: () {
                        setState(() => _selectedDateRange = null);
                      },
                      child:
                          Icon(Icons.clear, color: AppColors.error, size: 20),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(
    String value,
    String label,
    IconData icon,
    Color iconColor,
    bool isSelected,
    Function(bool) onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.mediumSpacing),
        decoration: BoxDecoration(
          color: isSelected
              ? iconColor.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
          border: Border.all(
            color: isSelected ? iconColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? iconColor : AppColors.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: AppConstants.mediumSpacing),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? iconColor : AppColors.onSurface,
                    ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: iconColor, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'all';
      _selectedPaymentMethod = 'all';
      _selectedDateRange = null;
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(
      _selectedCategory,
      _selectedPaymentMethod,
      _selectedDateRange,
    );
    Navigator.pop(context);
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'receipt':
        return Icons.receipt;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      default:
        return Icons.more_horiz;
    }
  }

  IconData _getPaymentIcon(String iconName) {
    switch (iconName) {
      case 'money':
        return Icons.money;
      case 'qr_code':
        return Icons.qr_code;
      case 'credit_card':
        return Icons.credit_card;
      case 'account_balance':
        return Icons.account_balance;
      case 'account_wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }
}

class ExpenseFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final DateTimeRange? selectedDateRange;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onClearFilters;

  const ExpenseFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.selectedDateRange,
    required this.onFilterChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Food', 'Transport', 'Shopping', 'Bills'];

    return Container(
      padding: const EdgeInsets.all(AppConstants.mediumSpacing),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Category dropdown
          DropdownButtonFormField<String>(
            value: selectedFilter,
            items: categories
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    ))
                .toList(),
            onChanged: (val) {
              if (val != null) onFilterChanged(val);
              Navigator.pop(context);
            },
            decoration: const InputDecoration(labelText: 'Category'),
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Date range picker
          ElevatedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(selectedDateRange != null
                ? "${selectedDateRange!.start.toLocal()} → ${selectedDateRange!.end.toLocal()}"
                : "Select Date Range"),
            onPressed: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
                initialDateRange: selectedDateRange,
              );
              onDateRangeChanged(range);
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: AppConstants.mediumSpacing),

          // Clear filters
          TextButton(
            onPressed: () {
              onClearFilters();
              Navigator.pop(context);
            },
            child: const Text("Clear Filters"),
          ),
        ],
      ),
    );
  }
}
