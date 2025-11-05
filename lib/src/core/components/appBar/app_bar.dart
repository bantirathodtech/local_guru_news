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
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.primary,
      title: Text(
        title,
        style: AppTextStyles.headline2(context).copyWith(
          color: titleColor ?? AppColors.textTertiary,
        ),
      ),
      iconTheme: IconThemeData(
        color: iconColor ?? AppColors.white, // ← Uses the parameter
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
