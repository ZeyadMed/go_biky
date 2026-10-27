import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// صف في قايمة (زي صفوف صفحة الحساب): أيقونة + عنوان + سهم، وخط تحته.
/// `text` بيتبعت مترجم، و`trailing` بيتحط مكان السهم (زي Switch)
class CustomListTile extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;
  final Color? backgroundColor;
  final Widget? trailing;
  final double? height;
  final bool showDivider;
  final VoidCallback? onTap;

  const CustomListTile({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
    this.iconColor,
    this.textColor,
    this.backgroundColor,
    this.trailing,
    this.height,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: backgroundColor ?? colors.bgSecondary,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: height ?? 50.h),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: showDivider
              ? BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colors.border, width: 0.5),
                  ),
                )
              : null,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 20.r,
                  color: iconColor ?? colors.textSecondary,
                ),
                Gaps.h(20.w),
              ],
              Expanded(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: textColor,
                  ),
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 15.r,
                    color: colors.primary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
