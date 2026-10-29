import 'package:flutter/material.dart';
import 'package:go_biky/core/theme/app_theme_colors.dart';
import 'package:go_biky/feature/balance/data/model/balance_model.dart';

/// حالة الرصيد بتحدد المبلغ اللي بيظهر كبير ولونه وأيقونته
enum BalanceStatus {
  outstanding('balance.outstanding', Icons.account_balance_wallet_outlined),
  credit('balance.credit', Icons.savings_outlined),
  settled('balance.settled', Icons.check_circle_outline_rounded);

  const BalanceStatus(this.labelKey, this.icon);

  final String labelKey;
  final IconData icon;

  /// المديونية الأول، وبعدها الرصيد اللي ليه، ولو الاتنين صفر يبقى مسدد
  static BalanceStatus of(BalanceModel balance) {
    if (balance.outstanding > 0) return BalanceStatus.outstanding;
    if (balance.credit > 0) return BalanceStatus.credit;
    return BalanceStatus.settled;
  }

  double amountOf(BalanceModel balance) => switch (this) {
    BalanceStatus.outstanding => balance.outstanding,
    BalanceStatus.credit => balance.credit,
    BalanceStatus.settled => 0,
  };

  Color color(AppThemeColors colors) => switch (this) {
    BalanceStatus.outstanding => colors.error,
    BalanceStatus.credit || BalanceStatus.settled => colors.success,
  };

  Color containerColor(AppThemeColors colors) => switch (this) {
    BalanceStatus.outstanding => colors.errorContainer,
    BalanceStatus.credit || BalanceStatus.settled => colors.successContainer,
  };
}
