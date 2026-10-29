import 'package:flutter/material.dart';
import 'package:go_biky/core/theme/app_theme_colors.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_status_model.dart';

/// حالة الزيت بتحدد لون الدايرة والمتبقي والـ badge وآخر التحية في الرئيسية
enum OilStatus {
  safe('home.oilSafe', 'home.roadIsGreen'),
  dueSoon('home.oilDueSoon', 'home.timeForCare'),
  changeRequired('home.oilChangeRequired', 'home.timeForCare');

  const OilStatus(this.labelKey, this.greetingKey);

  final String labelKey;
  final String greetingKey;

  /// من حدود التحذير اللي راجعة من الـ API: من أول تحذير "اقترب الموعد"،
  /// ومن التحذير التاني "يلزم التغيير"
  static OilStatus of(OilStatusModel oil) {
    final km = oil.kmSinceOilChange;
    if (km >= oil.secondWarningKm) return OilStatus.changeRequired;
    if (km >= oil.firstWarningKm) return OilStatus.dueSoon;
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
