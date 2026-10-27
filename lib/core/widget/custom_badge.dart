import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';

/// شارة صغيرة مدورة لحالة أو معلومة قصيرة (بانتظار الموافقة، تم الاعتماد...).
/// `text` بيتبعت مترجم. من غير ألوان بتبقى بلون البراند، ولحالة ابعت لونها
/// والـ Container بتاعه (`success` / `successContainer`)
class CustomBadge extends StatelessWidget {
  const CustomBadge({
    super.key,
    required this.text,
    this.color,
    this.backgroundColor,
  });

  final String text;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.primaryContainer,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.labelSmall?.copyWith(
          color: color ?? colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
