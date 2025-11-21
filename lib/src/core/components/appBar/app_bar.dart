import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../utils/responsive_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor; // ← REQUIRED because you use it

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.backgroundColor,
    this.titleColor,
    this.iconColor, // ← REQUIRED
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Theme-aware default colors
    final defaultBackgroundColor = backgroundColor ?? 
        (isDark ? theme.appBarTheme.backgroundColor ?? Colors.grey.shade900 
                : AppColors.primary);
    final defaultTitleColor = titleColor ?? 
        (isDark ? Colors.white 
                : AppColors.textTertiary);
    final defaultIconColor = iconColor ?? 
        (isDark ? Colors.white 
                : AppColors.white);

    return AppBar(
      backgroundColor: defaultBackgroundColor,
      title: Text(
        title,
        style: AppTextStyles.headline2(context).copyWith(
          color: defaultTitleColor,
        ),
      ),
      iconTheme: IconThemeData(
        color: defaultIconColor,
      ),
      centerTitle: true,
      actions: actions,
      elevation: ResponsiveUtils.isWeb() ? 4 : 0,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}
