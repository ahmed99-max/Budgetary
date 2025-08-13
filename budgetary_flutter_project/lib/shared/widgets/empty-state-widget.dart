import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'custom_button.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final Widget? customAction;
  final Color? iconColor;
  final double? iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.customAction,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.largeSpacing),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.onSurfaceVariant).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize ?? 64,
                color: iconColor ?? AppColors.onSurfaceVariant,
              ),
            ),
            
            const SizedBox(height: AppConstants.largeSpacing),
            
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppConstants.smallSpacing),
            
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (customAction != null) ...[
              const SizedBox(height: AppConstants.largeSpacing),
              customAction!,
            ] else if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: AppConstants.largeSpacing),
              CustomButton(
                text: actionText!,
                onPressed: onActionPressed,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final IconData? icon;

  const ErrorStateWidget({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'An error occurred. Please try again.',
    this.actionText,
    this.onActionPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largeSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppConstants.largeSpacing),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
            ),
            
            const SizedBox(height: AppConstants.largeSpacing),
            
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: AppConstants.smallSpacing),
            
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: AppConstants.largeSpacing),
              CustomButton(
                text: actionText!,
                onPressed: onActionPressed,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class NoInternetWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetWidget({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      message: 'Please check your connection and try again.',
      actionText: 'Retry',
      onActionPressed: onRetry,
      iconColor: AppColors.error,
    );
  }
}

class MaintenanceWidget extends StatelessWidget {
  const MaintenanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.construction,
      title: 'Under Maintenance',
      message: 'We\'re currently performing maintenance. Please check back later.',
      iconColor: AppColors.secondary,
    );
  }
}

class ComingSoonWidget extends StatelessWidget {
  final String? feature;

  const ComingSoonWidget({
    super.key,
    this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.upcoming,
      title: 'Coming Soon',
      message: feature != null 
          ? '$feature is coming soon. Stay tuned!'
          : 'This feature is coming soon. Stay tuned!',
      iconColor: AppColors.tertiary,
    );
  }
}