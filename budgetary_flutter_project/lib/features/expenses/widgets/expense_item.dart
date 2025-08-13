import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/expense_model.dart';
import '../../../shared/widgets/neumorphic_container.dart';

class ExpenseItem extends StatelessWidget {
  final ExpenseModel expense;
  final bool isGridView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpenseItem({
    super.key,
    required this.expense,
    this.isGridView = false,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = AppConstants.categories.firstWhere(
      (cat) => cat['id'] == expense.category,
      orElse: () => AppConstants.categories.last,
    );

    if (isGridView) {
      return _buildGridItem(context, category);
    } else {
      return _buildListItem(context, category);
    }
  }

  Widget _buildListItem(BuildContext context, Map<String, dynamic> category) {
    return NeumorphicContainer(
      child: Row(
        children: [
          // Category Icon
          Container(
            padding: const EdgeInsets.all(AppConstants.mediumSpacing),
            decoration: BoxDecoration(
              color: AppUtils.hexToColor(category['color']).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
            ),
            child: Icon(
              _getCategoryIcon(category['icon']),
              color: AppUtils.hexToColor(category['color']),
              size: 24,
            ),
          ),

          const SizedBox(width: AppConstants.mediumSpacing),

          // Expense Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.smallSpacing),
                Row(
                  children: [
                    Text(
                      category['name'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppUtils.hexToColor(category['color']),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: AppConstants.smallSpacing),
                    Text(
                      '•',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: AppConstants.smallSpacing),
                    Text(
                      AppUtils.formatDateShort(expense.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount and Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppUtils.formatCurrency(expense.amount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: AppConstants.smallSpacing),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(
                      Icons.edit,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppConstants.mediumSpacing),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.delete,
                      size: 18,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, Map<String, dynamic> category) {
    return NeumorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Icon and Amount
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.smallSpacing),
                decoration: BoxDecoration(
                  color: AppUtils.hexToColor(category['color']).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                ),
                child: Icon(
                  _getCategoryIcon(category['icon']),
                  color: AppUtils.hexToColor(category['color']),
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                AppUtils.formatCurrencyCompact(expense.amount),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Description
          Text(
            expense.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppConstants.smallSpacing),

          // Category and Date
          Text(
            category['name'],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppUtils.hexToColor(category['color']),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            AppUtils.formatDateShort(expense.date),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),

          const Spacer(),

          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Icon(
                  Icons.edit,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppConstants.mediumSpacing),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.delete,
                  size: 16,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
}
