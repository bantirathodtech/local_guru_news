import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'empty_state.dart';

/// Improved error widget with retry functionality
class ErrorWidgetImproved extends StatelessWidget {
  const ErrorWidgetImproved({
    Key? key,
    required this.message,
    this.onRetry,
    this.title,
    this.icon,
  }) : super(key: key);

  final String message;
  final VoidCallback? onRetry;
  final String? title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: icon ?? Icons.error_outline,
      iconColor: AppColors.error,
      title: title ?? 'Something went wrong',
      message: message,
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }
}

/// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  const NetworkErrorWidget({
    Key? key,
    this.onRetry,
    this.message,
  }) : super(key: key);

  final VoidCallback? onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off,
      iconColor: AppColors.warning,
      title: 'Connection Error',
      message: message ??
          'Unable to connect to the server. Please check your internet connection.',
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }
}
