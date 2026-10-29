import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// الزرار الأساسي في التطبيق (نفس شكل زرار اللوجن). `title` بيتبعت مترجم.
/// `outlined` بيخليه شفاف بحدود بلون البراند، و`isLoading` بيعرض loader
/// وبيقفل الضغط. [CustomButton.text] لزرار نص من غير خلفية
class CustomButton extends StatelessWidget {
  final String title;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  /// لو null الزرار بيبقى متعطل وباهت ومابيستجيبش للضغط
  final VoidCallback? onPressed;
  final bool outlined;
  final bool isLoading;
  final double? fontSize;
  final FontWeight? fontWeight;

  /// الأيقونة بعد النص بدل ما تبقى قبله
  final bool iconAtEnd;

  /// زرار نص ([CustomButton.text])
  final bool _textOnly;

  /// لزرار النص: أصغر وعريض ومن غير مساحة زيادة حواليه، لما يبقى جنب
  /// عنصر تاني في صف (زي "تحديد الكل كمقروء")
  final bool compact;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.width,
    this.height,
    this.outlined = false,
    this.isLoading = false,
    this.fontSize,
    this.fontWeight,
    this.iconAtEnd = false,
  }) : _textOnly = false,
       compact = false;

  /// زرار نص بلون البراند بحجم النص بس مش بعرض الشاشة، زي "إعادة المحاولة"
  /// و"تغيير الفيديو"
  const CustomButton.text({
    super.key,
    required this.title,
    required this.onPressed,
    this.textColor,
    this.fontWeight,
    this.compact = false,
  }) : _textOnly = true,
       icon = null,
       backgroundColor = null,
       borderColor = null,
       borderRadius = null,
       padding = null,
       width = null,
       height = null,
       outlined = false,
       isLoading = false,
       fontSize = null,
       iconAtEnd = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    if (_textOnly) return _buildText(context);

    final background = outlined
        ? Colors.transparent
        : backgroundColor ?? colors.primary;
    final foreground =
        textColor ??
        (outlined ? colors.primary : context.colorScheme.onPrimary);
    final border = borderColor ?? (outlined ? colors.primary : null);

    return Opacity(
      opacity: onPressed == null ? 0.4 : 1,
      child: Material(
        color: background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
          side: border == null ? BorderSide.none : BorderSide(color: border),
        ),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          child: Container(
            width: width ?? double.infinity,
            height: height ?? 52.h,
            padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox.square(
                    dimension: 22.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: foreground,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null && !iconAtEnd) ...[
                        icon!,
                        Gaps.h(10.w),
                      ],
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: foreground,
                            fontWeight: fontWeight ?? FontWeight.w700,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                      if (icon != null && iconAtEnd) ...[
                        Gaps.h(10.w),
                        icon!,
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    final textTheme = context.textTheme;
    final style = compact ? textTheme.labelMedium : textTheme.labelLarge;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? context.appColors.primary,
        textStyle: style?.copyWith(
          fontWeight: fontWeight ?? (compact ? FontWeight.w700 : null),
        ),
        visualDensity: compact ? VisualDensity.compact : null,
        tapTargetSize: compact ? MaterialTapTargetSize.shrinkWrap : null,
      ),
      child: Text(title, textAlign: TextAlign.center),
    );
  }
}
