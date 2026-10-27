import 'package:flutter/material.dart';
import 'package:go_biky/core/theme/app_theme_colors.dart';

/// حالة الزيت بتحدد لون الدايرة والمتبقي والـ badge وآخر التحية في الرئيسية
enum OilStatus {
  safe('home.oilSafe', 'home.roadIsGreen'),
  dueSoon('home.oilDueSoon', 'home.timeForCare'),
  changeRequired('home.oilChangeRequired', 'home.timeForCare');

  const OilStatus(this.labelKey, this.greetingKey);

  final String labelKey;
  final String greetingKey;

  /// المتبقي 20% من مسافة التغيير أو أقل = "اقترب الموعد" (٤٠ من ٥٠)،
  /// و10% أو أقل = "يلزم التغيير" (٤٥ من ٥٠)
  static OilStatus from({required int remainingKm, required int intervalKm}) {
    if (remainingKm <= intervalKm * 0.1) return OilStatus.changeRequired;
    if (remainingKm <= intervalKm * 0.2) return OilStatus.dueSoon;
    return OilStatus.safe;
  }

  Color color(AppThemeColors colors) => switch (this) {
    OilStatus.safe => colors.success,
    OilStatus.dueSoon => colors.warning,
    OilStatus.changeRequired => colors.error,
  };

  Color containerColor(AppThemeColors colors) => switch (this) {
    OilStatus.safe => colors.successContainer,
    OilStatus.dueSoon => colors.warningContainer,
    OilStatus.changeRequired => colors.errorContainer,
  };
}
