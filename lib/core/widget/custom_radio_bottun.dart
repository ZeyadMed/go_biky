import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// راديو لمجموعة اختيارات (`value` و `groupValue`)، و`child` بيتحط جنبه
class CustomRadioButton<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  /// لو مش متبعت بياخد 20.r
  final double? size;
  final Color? activeColor;
  final Color? inactiveColor;
  final double strokeWidth;
  final Duration animationDuration;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  const CustomRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.size,
    this.activeColor,
    this.inactiveColor,
    this.strokeWidth = 2.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.child,
    this.padding,
    this.enabled = true,
  });

  bool get isSelected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final active = activeColor ?? colors.primary;
    final inactive = inactiveColor ?? colors.textHint;
    final dimension = size ?? 20.r;

    return GestureDetector(
      onTap: enabled ? () => onChanged(value) : null,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: animationDuration,
              width: dimension,
              height: dimension,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: enabled
                      ? (isSelected ? active : inactive)
                      : inactive.withValues(alpha: 0.5),
                  width: strokeWidth,
                ),
              ),
              child: AnimatedScale(
                duration: animationDuration,
                scale: isSelected ? 1.0 : 0.0,
                child: Container(
                  margin: EdgeInsets.all(strokeWidth + 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: enabled ? active : active.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            if (child != null) ...[
              Gaps.h(8.w),
              Opacity(opacity: enabled ? 1.0 : 0.5, child: child!),
            ],
          ],
        ),
      ),
    );
  }
}
