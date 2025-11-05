import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveUtils {
  static double getFontSize(double baseSize, {bool useSp = true}) {
    return useSp ? baseSize.sp : baseSize;
  }

  static TextStyle responsiveTextStyle({
    required double baseSize,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    bool useSp = true,
  }) {
    return TextStyle(
      fontSize: getFontSize(baseSize, useSp: useSp),
      fontWeight: fontWeight,
      color: color,
      fontFamily: 'Roboto',
      fontFamilyFallback: ['sans-serif'],
    );
  }

  static EdgeInsets getPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return EdgeInsets.symmetric(
      horizontal: screenWidth * 0.04,
      vertical: screenWidth * 0.02,
    );
  }

  static bool isWeb() => kIsWeb;

  static bool isMobile() => !kIsWeb;

  static double getIconSize(BuildContext context) => isWeb() ? 24.0 : 20.0;

  static double getImageHeight(BuildContext context,
      {required double baseHeight}) {
    return baseHeight.h;
  }

  static int getGridCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isWeb() || screenWidth > 900) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  static double getGridItemHeight(BuildContext context,
      {required double baseHeight}) {
    return baseHeight.h;
  }
}
