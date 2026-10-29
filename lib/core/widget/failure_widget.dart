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

  /// سطر جوه كارت مكان عنصر واحد فشل (زي كارت الرصيد) بدل الشاشة كلها،
  /// و"إعادة المحاولة" زرار نص في آخره
  final bool compact;

  const FailureWidget({
    super.key,
    this.onRefresh,
    required this.errorMessage,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (compact) {
      return Container(
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 8.h, 8.w, 8.h),
        decoration: BoxDecoration(
          color: colors.bgSecondary,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: colors.error, size: 22.r),
            Gaps.h(10.w),
            Expanded(
              child: Text(
                errorMessage,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
            if (onRefresh != null)
              TextButton(
                onPressed: onRefresh,
                style: TextButton.styleFrom(foregroundColor: colors.primary),
                child: Text('common.retry'.tr()),
              ),
          ],
        ),
      );
    }

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
