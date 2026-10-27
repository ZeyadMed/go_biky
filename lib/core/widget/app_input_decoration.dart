import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// شكل الحقول الموحد في التطبيق (نفس حقول اللوجن)، بيستخدمه
/// CustomTextField و CustomPhoneField و CustomDropDown
abstract final class AppInputDecoration {
  static InputDecoration of(
    BuildContext context, {
    String? hintText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    double? borderRadius,
    EdgeInsetsGeometry? contentPadding,
  }) {
    final colors = context.appColors;

    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 14.r),
          borderSide: BorderSide(color: color, width: width),
        );

    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      filled: true,
      fillColor: colors.bgTertiary,
      contentPadding:
          contentPadding ??
          EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      prefixIconColor: colors.textSecondary,
      suffixIconColor: colors.textSecondary,
      border: border(colors.border),
      enabledBorder: border(colors.border),
      disabledBorder: border(colors.border.withValues(alpha: 0.5)),
      focusedBorder: border(colors.primary, width: 1.5),
      errorBorder: border(colors.error),
      focusedErrorBorder: border(colors.error, width: 1.5),
    );
  }
}

/// عنوان فوق الحقل، ولو `label` بـ null بيرجع الحقل زي ما هو
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (label == null) return child;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label!, style: context.textTheme.labelLarge),
        Gaps.v(8.h),
        child,
      ],
    );
  }
}
