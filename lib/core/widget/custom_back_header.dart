import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// زرار الرجوع في البداية والعنوان جنبه، و`subtitle` تحت العنوان و`trailing`
/// في آخر الصف (زي زرار فلتر). النصوص بتتبعت مترجمة. الرجوع بـ maybePop
/// عشان أي PopScope في الشاشة يشتغل
class CustomBackHeader extends StatelessWidget {
  const CustomBackHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          style: IconButton.styleFrom(
            backgroundColor: colors.bgSecondary,
            fixedSize: Size.square(40.r),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.textPrimary,
            size: 18.r,
          ),
        ),
        Gaps.h(12.w),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    color: colors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) ...[Gaps.h(8.w), trailing!],
      ],
    );
  }
}
