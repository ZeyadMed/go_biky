import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/custom_button.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// dialog تأكيد: أيقونة في مربع ملوّن، وعنوان ورسالة في النص، وزرار تأكيد
/// وتحته "إلغاء والعودة". النصوص بتتبعت مترجمة، و`show` بترجع true لو أكّد.
/// من غير ألوان الأيقونة والزرار بيبقوا بلون البراند، وللإجراء الخطير ابعت
/// `error` / `errorContainer`
class CustomConfirmDialog extends StatelessWidget {
  const CustomConfirmDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.content,
    this.iconColor,
    this.iconBackgroundColor,
    this.confirmColor,
    this.confirmTextColor,
  });

  final IconData icon;
  final String title;
  final String message;

  /// لو مش متبعت مفيش زرار تأكيد، والـ dialog بيبقى للعرض بزرار قفل بس
  /// (ابعت نصه في `cancelText`)
  final String? confirmText;

  /// لو مش متبعت بيبقى "إلغاء والعودة"
  final String? cancelText;

  /// محتوى تحت الرسالة وفوق الزراير (زي أرقام التواصل)
  final Widget? content;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? confirmColor;
  final Color? confirmTextColor;

  static Future<bool> show(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Widget? content,
    Color? iconColor,
    Color? iconBackgroundColor,
    Color? confirmColor,
    Color? confirmTextColor,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => CustomConfirmDialog(
        icon: icon,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        content: content,
        iconColor: iconColor,
        iconBackgroundColor: iconBackgroundColor,
        confirmColor: confirmColor,
        confirmTextColor: confirmTextColor,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;

    return Dialog(
      backgroundColor: colors.bgSecondary,
      // من غير elevation الـ M3 مابيلوّنش الخلفية بلون البراند
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400.w),
        child: SingleChildScrollView(
          padding: EdgeInsetsDirectional.fromSTEB(20.w, 24.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.r,
                height: 56.r,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? colors.primaryContainer,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? colors.primary,
                  size: 28.r,
                ),
              ),
              Gaps.v(16.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Gaps.v(10.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  height: 1.7,
                ),
              ),
              Gaps.v(20.h),
              if (content case final content?) ...[content, Gaps.v(20.h)],
              if (confirmText case final confirmText?) ...[
                CustomButton(
                  title: confirmText,
                  onPressed: () => Navigator.of(context).pop(true),
                  backgroundColor: confirmColor,
                  textColor: confirmTextColor,
                  height: 48.h,
                  fontSize: 15.sp,
                ),
                Gaps.v(10.h),
              ],
              CustomButton(
                title: cancelText ?? 'common.cancelAndBack'.tr(),
                onPressed: () => Navigator.of(context).pop(false),
                outlined: true,
                borderColor: colors.border,
                textColor: colors.textPrimary,
                height: 48.h,
                fontSize: 15.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
