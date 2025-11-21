import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Reusable empty state widget
class EmptyState extends StatelessWidget {
  const EmptyState({
    Key? key,
    this.icon,
    this.iconSize = 64,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  }) : super(key: key);

  final IconData? icon;
  final double iconSize;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: AppSpacing.paddingXL,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
            if (icon != null)
              Icon(
                icon,
                size: iconSize,
                color: iconColor ?? Colors.grey.shade400,
              ),
            if (icon != null) AppSpacing.gapLG,
            if (title != null)
              Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            if (title != null && message != null) AppSpacing.gapSM,
            if (message != null)
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.gapLG,
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }
}

/// Predefined empty states
class EmptyStates {
  static Widget noItems({String? message}) => EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No items found',
        message: message ?? 'There are no items to display at the moment.',
      );

  static Widget noResults({String? message}) => EmptyState(
        icon: Icons.search_off,
        title: 'No results found',
        message: message ?? 'Try adjusting your search criteria.',
      );

  static Widget noConnection({VoidCallback? onRetry}) => EmptyState(
        icon: Icons.wifi_off,
        title: 'No internet connection',
        message: 'Please check your internet connection and try again.',
        actionLabel: 'Retry',
        onAction: onRetry,
      );

  static Widget error({
    String? message,
    VoidCallback? onRetry,
  }) =>
      EmptyState(
        icon: Icons.error_outline,
        iconColor: AppColors.error,
        title: 'Something went wrong',
        message: message ?? 'An error occurred. Please try again.',
        actionLabel: 'Retry',
        onAction: onRetry,
      );
}

