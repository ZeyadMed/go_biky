import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/custom_button.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// حالة الخطأ: أيقونة + رسالة. لو `onRefresh` متبعت بيبقى فيه سحب للتحديث
/// وزرار "إعادة المحاولة". `errorMessage` بيتبعت مترجم
class FailureWidget extends StatelessWidget {
  final RefreshCallback? onRefresh;
  final String errorMessage;

  const FailureWidget({super.key, this.onRefresh, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline_rounded, size: 75.r, color: colors.error),
        Gaps.v(16.h),
        Text(
          errorMessage,
          style: context.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        if (onRefresh != null) ...[
          Gaps.v(20.h),
          CustomButton(
            title: 'common.retry'.tr(),
            onPressed: onRefresh,
            outlined: true,
            width: 180.w,
            height: 44.h,
          ),
        ],
      ],
    );

    if (onRefresh == null) {
      return Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: content,
        ),
      );
    }

    return RefreshIndicator(
      color: colors.primary,
      onRefresh: onRefresh!,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : 0,
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}
