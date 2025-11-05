import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppTextStyles {
  static TextStyle headline1(BuildContext context) => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFamily: 'Roboto',
        height: 1.2,
      );

  static TextStyle headline2(BuildContext context) => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFamily: 'Roboto',
        height: 1.2,
      );

  static TextStyle bodyLarge(BuildContext context) => TextStyle(
        fontSize: 16.sp,
        color: AppColors.textPrimary,
        fontFamily: 'Roboto',
        height: 1.2,
      );

  static TextStyle bodyMedium(BuildContext context) => TextStyle(
        fontSize: 14.sp,
        color: AppColors.textSecondary,
        fontFamily: 'Roboto',
        height: 1.2,
      );

  static TextStyle button(BuildContext context) => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        fontFamily: 'Roboto',
        height: 1.2,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: 12.sp,
        color: AppColors.textSecondary,
        fontFamily: 'Roboto',
        height: 1.2,
      );

  // Provides safe text style supporting fallback font for robust display
  static TextStyle safeText({
    required double size,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: fontWeight,
      color: color,
      fontFamily: 'Roboto',
      fontFamilyFallback: ['sans-serif'],
    );
  }
}
