import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/theme/app_colors.dart';
import 'package:go_biky/core/theme/app_theme_colors.dart';

/// بيتبني جوه ScreenUtilInit عشان الـ .sp تشتغل
abstract final class AppThemeData {
  static ThemeData light() => _build(AppThemeColors.light, Brightness.light);

  static ThemeData dark() => _build(AppThemeColors.dark, Brightness.dark);

  static ThemeData _build(AppThemeColors colors, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: AppColors.whiteColor,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.textPrimary,
      secondary: colors.secondary,
      onSecondary: isDark ? colors.bgPrimary : AppColors.whiteColor,
      error: colors.error,
      onError: AppColors.whiteColor,
      errorContainer: colors.errorContainer,
      onErrorContainer: colors.error,
      surface: colors.bgSecondary,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.border,
      outlineVariant: colors.border,
    );

    // لون الخط بيتحط هنا، فأي شاشة بتستخدم context.textTheme
    // بيتغير لونها لوحدها مع الوضع
    final textTheme = _textTheme().apply(
      fontFamily: 'Cairo',
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Cairo',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.bgPrimary,
      textTheme: textTheme,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.bgPrimary,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      iconTheme: IconThemeData(color: colors.textPrimary),
      dividerTheme: DividerThemeData(color: colors.border, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
        selectionColor: colors.primary.withValues(alpha: 0.3),
        selectionHandleColor: colors.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textHint),
        errorStyle: textTheme.bodySmall?.copyWith(color: colors.error),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.bgSecondary,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.bgSecondary,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  // Regular 400 نصوص، Medium 500 عناصر مهمة، SemiBold 600 عناوين، Bold 700 إبراز
  static TextTheme _textTheme() => TextTheme(
    displayLarge: TextStyle(fontSize: 34.sp, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.w700),
    displaySmall: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w700),
    headlineLarge: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
    labelMedium: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
    labelSmall: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
  );
}
