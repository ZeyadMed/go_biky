import 'package:flutter/material.dart';
import 'package:go_biky/core/theme/app_colors.dart';

/// الألوان اللي بتتغير حسب الوضع، بتتقري بـ `context.appColors`.
/// أي لون جديد يتضاف هنا بقيمتين (light و dark) وفي copyWith و lerp
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.primary,
    required this.primaryContainer,
    required this.secondary,
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgTertiary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.border,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.error,
    required this.errorContainer,
    required this.info,
    required this.infoContainer,
  });

  /// أحمر البراند: الأزرار الأساسية، العنصر النشط، اللينكات، الـ progress
  final Color primary;

  /// درجة فاتحة من الأحمر: badge، كارت متحدد، chip نشط
  final Color primaryContainer;

  /// الرمادي الغامق: الأزرار الثانوية والـ chips
  final Color secondary;

  /// خلفية الشاشة
  final Color bgPrimary;

  /// الكروت والـ sheets
  final Color bgSecondary;

  /// الحقول والـ chips
  final Color bgTertiary;

  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color border;

  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;

  /// rose عشان يبان مختلف عن أحمر البراند، للأخطاء بس
  final Color error;
  final Color errorContainer;
  final Color info;
  final Color infoContainer;

  static const light = AppThemeColors(
    primary: AppColors.brandRed,
    primaryContainer: Color(0xffFBE9E8),
    secondary: AppColors.brandCharcoal,
    bgPrimary: Color(0xffF7F6F4),
    bgSecondary: Color(0xffFFFFFF),
    bgTertiary: Color(0xffF0EFEC),
    textPrimary: Color(0xff1C1C1B),
    textSecondary: Color(0xff5F5E5A),
    textHint: Color(0xff9A9893),
    border: Color(0xffE3E1DC),
    success: Color(0xff15803D),
    successContainer: Color(0xffDCFCE7),
    warning: Color(0xffB45309),
    warningContainer: Color(0xffFEF3C7),
    error: Color(0xffE11D48),
    errorContainer: Color(0xffFFE4E6),
    info: Color(0xff0369A1),
    infoContainer: Color(0xffE0F2FE),
  );

  static const dark = AppThemeColors(
    primary: Color(0xffD94A48),
    primaryContainer: Color(0xff3A1F1F),
    secondary: Color(0xffC8C7C2),
    bgPrimary: Color(0xff121212),
    bgSecondary: Color(0xff1C1C1C),
    bgTertiary: Color(0xff262626),
    textPrimary: Color(0xffF2F2F0),
    textSecondary: Color(0xffB5B4AF),
    textHint: Color(0xff807F7A),
    border: Color(0xff343432),
    success: Color(0xff4ADE80),
    successContainer: Color(0xff12301F),
    warning: Color(0xffFBBF24),
    warningContainer: Color(0xff3A2A0A),
    error: Color(0xffFB7185),
    errorContainer: Color(0xff3F1520),
    info: Color(0xff38BDF8),
    infoContainer: Color(0xff0C2A3A),
  );

  @override
  AppThemeColors copyWith({
    Color? primary,
    Color? primaryContainer,
    Color? secondary,
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgTertiary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? border,
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
    Color? error,
    Color? errorContainer,
    Color? info,
    Color? infoContainer,
  }) {
    return AppThemeColors(
      primary: primary ?? this.primary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      secondary: secondary ?? this.secondary,
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgTertiary: bgTertiary ?? this.bgTertiary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      border: border ?? this.border,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      info: info ?? this.info,
      infoContainer: infoContainer ?? this.infoContainer,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgTertiary: Color.lerp(bgTertiary, other.bgTertiary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      border: Color.lerp(border, other.border, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      error: Color.lerp(error, other.error, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
    );
  }
}
