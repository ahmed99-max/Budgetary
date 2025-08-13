import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

class PaymentMethodPicker extends StatelessWidget {
  final String selectedPaymentMethod;
  final ValueChanged<String> onPaymentMethodSelected;

  const PaymentMethodPicker({
    super.key,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: AppConstants.paymentMethods.map((method) {
        // Safely extract as non-nullable String
        final id = method['id'] as String? ?? '';
        final name = method['name'] as String? ?? '';
        final iconName = method['icon'] as String? ?? '';
        final isSelected = selectedPaymentMethod == id;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.smallSpacing),
          child: GestureDetector(
            onTap: () => onPaymentMethodSelected(id),
            child: AnimatedContainer(
              duration: AppConstants.shortAnimation,
              padding: const EdgeInsets.all(AppConstants.mediumSpacing),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.smallSpacing),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppConstants.smallRadius),
                    ),
                    child: Icon(
                      _getPaymentIcon(iconName),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppConstants.mediumSpacing),
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.onSurface,
                          ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primary,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(growable: false),
    );
  }

  // Map iconName strings to Flutter icons
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
