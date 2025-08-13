import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';

class CategoryPicker extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryPicker({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppConstants.smallSpacing,
        mainAxisSpacing: AppConstants.smallSpacing,
      ),
      itemCount: AppConstants.categories.length,
      itemBuilder: (context, index) {
        final category = AppConstants.categories[index];
        final isSelected = selectedCategory == category['id'];

        return GestureDetector(
          onTap: () => onCategorySelected(category['id']!),
          child: AnimatedContainer(
            duration: AppConstants.shortAnimation,
            padding: const EdgeInsets.all(AppConstants.smallSpacing),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppUtils.hexToColor(category['color']!)
                      .withValues(alpha: 0.2)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
              border: Border.all(
                color: isSelected
                    ? AppUtils.hexToColor(category['color']!)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.smallSpacing),
                  decoration: BoxDecoration(
                    color: AppUtils.hexToColor(category['color']!),
                    borderRadius:
                        BorderRadius.circular(AppConstants.smallRadius),
                  ),
                  child: Icon(
                    _getCategoryIcon(category['icon']!),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(height: AppConstants.smallSpacing),
                Text(
                  category['name']!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? AppUtils.hexToColor(category['color']!)
                            : AppColors.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
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
