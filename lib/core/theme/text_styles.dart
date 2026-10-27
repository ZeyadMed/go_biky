import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/theme/app_colors.dart';

/// ستايلات لونها ثابت، للنص الأبيض فوق الصور بس (زي السبلاش).
/// أي نص عادي يتكتب بـ `context.textTheme` عشان لونه يتغير مع الـ dark mode
abstract final class TextStyles {
  static TextStyle whiteText(
    double fontSize, {
    FontWeight weight = FontWeight.bold,
  }) => TextStyle(
    fontSize: fontSize.sp,
    color: AppColors.whiteColor,
    fontWeight: weight,
    fontFamily: 'Cairo',
  );
}
