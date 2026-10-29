import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:go_biky/core/extensions/extensions.dart';

extension MoneyFormat on BuildContext {
  /// مبلغ بالجنيه بفواصل الآلاف: "١٬٠٠٠ ج.م" / "EGP 1,000"
  String formatMoney(num value) =>
      'balance.money'.tr(args: [formatNumber(value)]);
}
