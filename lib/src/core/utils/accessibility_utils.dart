import 'package:flutter/material.dart';

/// Accessibility utilities for better screen reader support and text scaling
class AccessibilityUtils {
  /// Get semantic label for a widget
  static String getSemanticLabel(String? text, {String? fallback}) {
    return text?.isNotEmpty == true ? text! : (fallback ?? '');
  }

  /// Check if text scaling is enabled
  static bool isTextScaled(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    return textScaler.scale(1.0) > 1.0;
  }

  /// Get accessible text style that respects text scaling
  static TextStyle accessibleTextStyle(
    BuildContext context,
    TextStyle baseStyle,
  ) {
    final textScaler = MediaQuery.textScalerOf(context);
    return baseStyle.copyWith(
      fontSize: textScaler.scale(baseStyle.fontSize ?? 14),
    );
  }

  /// Minimum tap target size (48dp as per Material Design)
  static const double minTapTargetSize = 48.0;

  /// Check if tap target meets minimum size
  static bool isTapTargetAccessible(Size size) {
    return size.width >= minTapTargetSize && size.height >= minTapTargetSize;
  }

  /// Get semantic properties for buttons
  static Map<String, dynamic> buttonSemantics({
    required String label,
    String? hint,
    bool enabled = true,
    bool selected = false,
  }) {
    return {
      'label': label,
      if (hint != null) 'hint': hint,
      'enabled': enabled,
      'button': true,
      'selected': selected,
    };
  }

  /// Get semantic properties for images
  static Map<String, dynamic> imageSemantics({
    required String label,
    String? hint,
    bool isDecorative = false,
  }) {
    return {
      if (!isDecorative) 'label': label,
      if (hint != null) 'hint': hint,
      'image': true,
      'excludeSemantics': isDecorative,
    };
  }
}

