import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';

/// chip اختيار (تصنيف أو فلتر): المختار بالرمادي الغامق والباقي بخلفية
/// الكروت. `label` بيتبعت مترجم، و`padding` و`fontSize` لو الديزاين محتاج
/// chip أكبر من الافتراضي
class CustomChoiceChip extends StatelessWidget {
  const CustomChoiceChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.padding,
    this.fontSize,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Semantics(
      button: true,
      selected: isSelected,
      child: Material(
        color: isSelected ? colors.secondary : colors.bgSecondary,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding:
                padding ??
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 3.h),
            child: Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                fontSize: fontSize,
                color: isSelected
                    ? context.colorScheme.onSecondary
                    : colors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
