import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_biky/core/extensions/context_extension.dart';

/// عنوان قسم وجنبه "عرض الكل" (بيظهر لو `onSeeAllTap` متبعت).
/// `title` بيتبعت مترجم
class RowWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllTap;

  const RowWidget({super.key, required this.title, this.onSeeAllTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        if (onSeeAllTap != null)
          TextButton(
            onPressed: onSeeAllTap,
            style: TextButton.styleFrom(
              foregroundColor: context.appColors.primary,
              textStyle: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text('common.seeAll'.tr()),
          ),
      ],
    );
  }
}
