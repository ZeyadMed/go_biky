import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/widget/widgets.dart';

// TODO: صورة جركن الزيت لسه مش في الـ assets
const String? _oilBottleImage = null;

/// خطوات طلب تغيير الزيت بنفس ترتيبها في الـ stepper
enum OilChangeStep {
  proof('oilChange.stepProof'),
  review('oilChange.stepReview'),
  confirmation('oilChange.stepConfirmation');

  const OilChangeStep(this.labelKey);

  final String labelKey;
}

/// هيكل شاشات تغيير الزيت: العنوان والـ stepper ثابتين فوق، والمحتوى
/// بيعمل scroll، والزرار ثابت تحت
class OilChangeLayout extends StatelessWidget {
  const OilChangeLayout({
    super.key,
    required this.title,
    required this.step,
    required this.body,
    required this.button,
  });

  final String title;
  final OilChangeStep step;
  final Widget body;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.w, 12.h, 24.w, 0),
              child: ResponsiveCenter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomBackHeader(title: title),
                    Gaps.v(16.h),
                    _StepIndicator(current: step),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
                child: ResponsiveCenter(child: body),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.w, 8.h, 24.w, 16.h),
              child: ResponsiveCenter(child: button),
            ),
          ],
        ),
      ),
    );
  }
}

/// الخطوة الحالية واللي قبلها بلون البراند، واللي بعدها رمادي
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final OilChangeStep current;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final step in OilChangeStep.values) ...[
          if (step.index > 0) Gaps.h(6.w),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: step.index <= current.index
                        ? colors.primary
                        : colors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Gaps.v(6.h),
                Text(
                  step.labelKey.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: step.index <= current.index
                        ? colors.primary
                        : colors.textHint,
                    fontWeight: step == current
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// صورة جركن الزيت، ولحد ما تتضاف في الـ assets بتظهر أيقونة مكانها
class OilBottleImage extends StatelessWidget {
  const OilBottleImage({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return FlexibleImage(
      source: _oilBottleImage,
      width: width,
      height: height,
      borderRadius: borderRadius,
      placeholder: ColoredBox(
        color: colors.bgTertiary,
        child: Center(
          child: Icon(
            Icons.oil_barrel_outlined,
            color: colors.textSecondary,
            size: width * 0.45,
          ),
        ),
      ),
    );
  }
}

/// تاريخ التغيير وقراءة العداد والمسافة من آخر تغيير
class OilChangeDetailsCard extends StatelessWidget {
  const OilChangeDetailsCard({
    super.key,
    required this.changeDate,
    required this.odometerKm,
    required this.kmUsed,
    required this.kmInterval,
  });

  final DateTime changeDate;
  final int odometerKm;
  final int kmUsed;
  final int kmInterval;

  @override
  Widget build(BuildContext context) {
    return CustomDetailsCard(
      rows: [
        (
          label: 'oilChange.changeDate'.tr(),
          value: context.formatDate(changeDate),
        ),
        (
          label: 'oilChange.odometerReading'.tr(),
          value: 'oilChange.km'.tr(args: [context.formatNumber(odometerKm)]),
        ),
        (
          label: 'oilChange.sinceLastChange'.tr(),
          value: 'oilChange.kmOf'.tr(
            args: [
              context.formatNumber(kmUsed),
              context.formatNumber(kmInterval),
            ],
          ),
        ),
      ],
    );
  }
}
