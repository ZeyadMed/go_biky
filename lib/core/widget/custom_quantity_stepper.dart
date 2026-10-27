import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

enum QuantityStepperStyle {
  /// الـ + بس جوه دايرة بلون البراند الفاتح (صفحة تفاصيل القطعة)
  plain,

  /// الزرارين جوه مربعات مدورة، الـ + بلون البراند الفاتح والـ − رمادي
  /// (سلة الطلب)
  boxed,

  /// شريط بعرض المكان كله بخلفية البراند الفاتحة (كارت القطعة)
  filled,
}

/// عداد كمية: زرار + والرقم وزرار −، وشكله بيتحدد بـ `style`.
/// `onIncrement` / `onDecrement` بـ null بيعطلوا الزرار
class CustomQuantityStepper extends StatelessWidget {
  const CustomQuantityStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.style = QuantityStepperStyle.plain,
    this.height,
  });

  final int quantity;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final QuantityStepperStyle style;

  /// ارتفاع الشريط في `filled`، ولو مش متبعت بياخد 34.h
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final filled = style == QuantityStepperStyle.filled;
    final boxed = style == QuantityStepperStyle.boxed;
    final squareShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.r),
    );
    final count = Text(
      context.formatNumber(quantity),
      textAlign: TextAlign.center,
      maxLines: 1,
      style: context.textTheme.titleSmall?.copyWith(
        color: filled ? colors.primary : colors.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );

    if (filled) {
      return Container(
        height: height ?? 34.h,
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _StepButton(
              icon: Icons.add_rounded,
              tooltip: 'common.increase'.tr(),
              color: colors.primary,
              shape: squareShape,
              onPressed: onIncrement,
            ),
            Expanded(child: Center(child: count)),
            _StepButton(
              icon: Icons.remove_rounded,
              tooltip: 'common.decrease'.tr(),
              color: colors.primary,
              shape: squareShape,
              onPressed: onDecrement,
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.add_rounded,
          tooltip: 'common.increase'.tr(),
          color: colors.primary,
          backgroundColor: colors.primaryContainer,
          shape: boxed ? squareShape : null,
          onPressed: onIncrement,
        ),
        Gaps.h(8.w),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 24.w),
          child: count,
        ),
        Gaps.h(8.w),
        _StepButton(
          icon: Icons.remove_rounded,
          tooltip: 'common.decrease'.tr(),
          color: colors.textPrimary,
          backgroundColor: boxed ? colors.bgTertiary : null,
          shape: boxed ? squareShape : null,
          onPressed: onDecrement,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
    this.backgroundColor,
    this.shape,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback? onPressed;
  final Color? backgroundColor;

  /// لو null بيبقى دايرة
  final OutlinedBorder? shape;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        foregroundColor: color,
        disabledForegroundColor: color.withValues(alpha: 0.3),
        backgroundColor: backgroundColor,
        disabledBackgroundColor: backgroundColor?.withValues(alpha: 0.5),
        fixedSize: Size.square(34.r),
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: shape,
      ),
      icon: Icon(icon, size: 18.r),
    );
  }
}
