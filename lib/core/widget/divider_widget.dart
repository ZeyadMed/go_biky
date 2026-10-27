import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';

/// خط أفقي في نصه كلمة، والافتراضي "أو". `text` بيتبعت مترجم.
///
/// Example:
/// DividerWidget()
/// DividerWidget(text: 'common.or'.tr(), lineColor: context.appColors.border)
class DividerWidget extends StatelessWidget {
  final String? text;
  final Color? lineColor;
  final double thickness;
  final double? spacing;
  final TextStyle? textStyle;

  const DividerWidget({
    super.key,
    this.text,
    this.lineColor,
    this.thickness = 0.5,
    this.spacing,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = lineColor ?? colors.border;

    Widget line() =>
        Expanded(child: Container(height: thickness, color: color));

    return Row(
      children: [
        line(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing ?? 12.w),
          child: Text(
            text ?? 'common.or'.tr(),
            textAlign: TextAlign.center,
            style:
                textStyle ??
                context.textTheme.labelLarge?.copyWith(
                  color: colors.textSecondary,
                ),
          ),
        ),
        line(),
      ],
    );
  }
}
