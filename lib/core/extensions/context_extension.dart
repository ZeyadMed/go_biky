import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/theme/app_theme_colors.dart';
import 'package:go_biky/core/widgets/stateless/gaps.dart';

/// حدود الأجهزة بالـ logical pixels
abstract final class Breakpoints {
  /// أي عرض أقل من كده موبايل صغير
  static const double smallMobile = 360;

  /// أقصر ضلع للشاشة من كده وطالع تابلت
  static const double tablet = 600;
}

extension ContextExtensions on BuildContext {
  // ─── Responsive ───────────────────────────────────
  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isTablet =>
      MediaQuery.sizeOf(this).shortestSide >= Breakpoints.tablet;

  bool get isSmallMobile => !isTablet && screenWidth < Breakpoints.smallMobile;

  bool get isNormalMobile => !isTablet && !isSmallMobile;

  /// قيمة بتختلف حسب الجهاز، و`smallMobile` و`tablet` لو مش موجودين
  /// بياخدوا قيمة `mobile`
  T responsiveValue<T>({required T mobile, T? smallMobile, T? tablet}) {
    if (isTablet) return tablet ?? mobile;
    if (isSmallMobile) return smallMobile ?? mobile;
    return mobile;
  }

  // ─── Theme ────────────────────────────────────────
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;

  AppThemeColors get appColors =>
      theme.extension<AppThemeColors>() ??
      (isDarkMode ? AppThemeColors.dark : AppThemeColors.light);

  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ─── Language ─────────────────────────────────────
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  /// بيقلب بين العربي والإنجليزي، والاختيار بيتحفظ
  Future<void> toggleLanguage() =>
      setLocale(isArabic ? const Locale('en') : const Locale('ar'));

  // ─── Keyboard ─────────────────────────────────────
  bool get isKeyboardVisible => MediaQuery.viewInsetsOf(this).bottom != 0;

  FocusScopeNode get focusScopeNode => FocusScope.of(this);

  // ─── Messages ─────────────────────────────────────
  void showErrorMessage(String message) =>
      _showSnackBar(message, icon: Icons.error_rounded, iconColor: appColors.error);

  void showSuccessMessage(String message) => _showSnackBar(
    message,
    icon: Icons.check_circle_rounded,
    iconColor: appColors.success,
  );

  void _showSnackBar(
    String message, {
    required IconData icon,
    required Color iconColor,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(this);
    if (messenger == null) return;

    final colors = appColors;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: colors.bgSecondary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: colors.border),
          ),
          margin: EdgeInsetsDirectional.fromSTEB(16.w, 0, 16.w, 24.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          content: Row(
            children: [
              Icon(icon, color: iconColor, size: 22.r),
              Gaps.h(10.w),
              Expanded(
                child: Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  void showLoadingDialog({
    String? message,
    bool canPop = false,
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => PopScope(
        canPop: canPop,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 24.h,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: context.appColors.primary),
              Gaps.v(16.h),
              Text(
                message ?? 'common.loading'.tr(),
                style: context.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
