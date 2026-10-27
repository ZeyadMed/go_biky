import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/oil_change/oil_change_proof.dart';
import 'package:go_biky/feature/oil_change/presentation/widgets/oil_change_widgets.dart';
import 'package:go_router/go_router.dart';

// TODO: من بيانات المستخدم لما الـ API يجهز
const _riderFirstName = 'أحمد';

/// حالة إثبات تغيير الزيت: بانتظار موافقة المشرف، أو اتعتمد واتصفّر العداد
class OilChangeStatusScreen extends StatelessWidget {
  const OilChangeStatusScreen({super.key, required this.proof});

  final OilChangeProof proof;

  @override
  Widget build(BuildContext context) {
    return switch (proof.status) {
      OilProofStatus.pending => OilChangeLayout(
        title: 'oilChange.statusTitle'.tr(),
        step: OilChangeStep.review,
        body: _PendingView(proof: proof),
        button: CustomButton(
          title: 'oilChange.viewOilLog'.tr(),
          onPressed: () => context.push(AppRouter.oilLog),
          backgroundColor: context.appColors.secondary,
          textColor: context.colorScheme.onSecondary,
        ),
      ),
      OilProofStatus.approved => OilChangeLayout(
        title: 'oilChange.approvedTitle'.tr(),
        step: OilChangeStep.confirmation,
        body: _ApprovedView(proof: proof),
        button: CustomButton(
          title: 'oilChange.backToHome'.tr(),
          onPressed: () => context.go(AppRouter.initialRoute),
        ),
      ),
    };
  }
}

TextStyle? _headlineStyle(BuildContext context) => context
    .textTheme
    .headlineMedium
    ?.copyWith(fontSize: 26.sp, fontWeight: FontWeight.w800, height: 1.4);

TextStyle? _subtitleStyle(BuildContext context) => context.textTheme.bodySmall
    ?.copyWith(color: context.appColors.textSecondary, height: 1.7);

class _PendingView extends StatelessWidget {
  const _PendingView({required this.proof});

  final OilChangeProof proof;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: OilBottleImage(
            width: 104.r,
            height: 120.r,
            borderRadius: 22.r,
          ),
        ),
        Gaps.v(12.h),
        Center(
          child: CustomBadge(
            text: 'oilChange.pendingApproval'.tr(),
            color: colors.warning,
            backgroundColor: colors.warningContainer,
          ),
        ),
        Gaps.v(8.h),
        Text(
          'oilChange.proofReceived'.tr(args: [_riderFirstName]),
          textAlign: TextAlign.center,
          style: _headlineStyle(context),
        ),
        Gaps.v(4.h),
        Text(
          'oilChange.proofReceivedSubtitle'.tr(),
          textAlign: TextAlign.center,
          style: _subtitleStyle(context),
        ),
        Gaps.v(20.h),
        _ProofCard(proof: proof),
        Gaps.v(12.h),
        OilChangeDetailsCard(
          changeDate: proof.changeDate,
          odometerKm: proof.odometerKm,
          kmUsed: proof.kmUsed,
          kmInterval: proof.kmInterval,
        ),
        Gaps.v(12.h),
        _CounterNotResetCard(
          kmUsed: proof.kmUsed,
          kmInterval: proof.kmInterval,
        ),
      ],
    );
  }
}

/// صورة الإثبات اللي اتبعتت ورقمه ووقت إرساله
class _ProofCard extends StatelessWidget {
  const _ProofCard({required this.proof});

  final OilChangeProof proof;

  @override
  Widget build(BuildContext context) {
    final submittedAt = proof.submittedAt;
    final time = context.formatTime(submittedAt);
    final sentAt = DateUtils.isSameDay(submittedAt, DateTime.now())
        ? 'oilChange.sentToday'.tr(args: [time])
        : 'oilChange.sentOn'.tr(args: [context.formatDate(submittedAt), time]);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: context.appColors.bgSecondary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          FlexibleImage(
            source: proof.image,
            width: 64.r,
            height: 64.r,
            borderRadius: 12.r,
          ),
          Gaps.h(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'oilChange.proofNumber'.tr(
                    args: [context.formatNumber(proof.id, grouped: false)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Gaps.v(2.h),
                Text(
                  sentAt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// تنبيه إن العداد لسه ماتصفّرش لحد موافقة المشرف
class _CounterNotResetCard extends StatelessWidget {
  const _CounterNotResetCard({required this.kmUsed, required this.kmInterval});

  final int kmUsed;
  final int kmInterval;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final remainingKm = (kmInterval - kmUsed).clamp(0, kmInterval);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.warningContainer,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'oilChange.counterNotReset'.tr(
              args: [
                context.formatNumber(kmUsed),
                context.formatNumber(kmInterval),
              ],
            ),
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: colors.warning,
            ),
          ),
          Gaps.v(2.h),
          Text(
            'oilChange.counterNotResetNote'.tr(
              args: [context.formatNumber(remainingKm)],
            ),
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: 11.sp,
              color: colors.warning,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovedView extends StatelessWidget {
  const _ApprovedView({required this.proof});

  final OilChangeProof proof;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: CustomBadge(
            text: 'oilChange.proofApproved'.tr(
              args: [context.formatNumber(proof.id, grouped: false)],
            ),
            color: colors.success,
            backgroundColor: colors.successContainer,
          ),
        ),
        Gaps.v(10.h),
        Text(
          'oilChange.approvedHeadline'.tr(),
          textAlign: TextAlign.center,
          style: _headlineStyle(context),
        ),
        Gaps.v(16.h),
        Center(child: _ResetRing(kmInterval: proof.kmInterval)),
        Gaps.v(16.h),
        Text(
          'oilChange.remainingToNextChange'.tr(
            args: [context.formatNumber(proof.kmInterval)],
          ),
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall?.copyWith(
            fontSize: 22.sp,
            fontWeight: FontWeight.w800,
            color: colors.success,
          ),
        ),
        Gaps.v(4.h),
        Text(
          'oilChange.approvedSubtitle'.tr(),
          textAlign: TextAlign.center,
          style: _subtitleStyle(context),
        ),
        Gaps.v(20.h),
        CustomDetailsCard(
          rows: [
            if (proof.approvedAt case final approvedAt?)
              (
                label: 'oilChange.approvalDate'.tr(),
                value: context.formatDate(approvedAt),
              ),
            (
              label: 'oilChange.odometerAtChange'.tr(),
              value: 'oilChange.km'.tr(
                args: [context.formatNumber(proof.odometerKm)],
              ),
            ),
            (
              label: 'oilChange.proofStatus'.tr(),
              value: 'oilChange.approvedBySupervisor'.tr(),
            ),
          ],
        ),
      ],
    );
  }
}

/// العداد بعد التصفير: الـ track فاضي وفي النص صفر من مسافة التغيير
class _ResetRing extends StatelessWidget {
  const _ResetRing({required this.kmInterval});

  final int kmInterval;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox.square(
      dimension: 230.r,
      child: CustomPaint(
        painter: _ResetRingPainter(
          outlineColor: colors.border,
          fillColor: colors.successContainer,
          trackColor: colors.border,
          successColor: colors.success,
          accentColor: colors.primary,
          trackWidth: 10.r,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.formatNumber(0),
                style: context.textTheme.displaySmall?.copyWith(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              Text(
                'oilChange.ofKm'.tr(args: [context.formatNumber(kmInterval)]),
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// حلقة خارجية رفيعة عليها شرطتين للزينة، وجواها دايرة بلون النجاح
/// والـ track، والشرطة اللي فوق الـ track بتعلّم بداية العداد
class _ResetRingPainter extends CustomPainter {
  const _ResetRingPainter({
    required this.outlineColor,
    required this.fillColor,
    required this.trackColor,
    required this.successColor,
    required this.accentColor,
    required this.trackWidth,
  });

  final Color outlineColor;
  final Color fillColor;
  final Color trackColor;

  /// بداية العداد وشرطة من شرطتين الزينة
  final Color successColor;

  /// شرطة الزينة التانية
  final Color accentColor;
  final double trackWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final accentWidth = trackWidth * 0.4;
    final outerRadius = radius - accentWidth / 2;
    final trackRadius = radius * 0.72;

    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = accentWidth
      ..strokeCap = StrokeCap.round;
    final outerRect = Rect.fromCircle(center: center, radius: outerRadius);
    // الزوايا بالراديان من الساعة ٣ مع عقارب الساعة زي الديزاين
    canvas
      ..drawArc(outerRect, -0.7, 0.08, false, accentPaint..color = accentColor)
      ..drawArc(outerRect, 2.6, 0.08, false, accentPaint..color = successColor);

    canvas.drawCircle(center, radius * 0.88, Paint()..color = fillColor);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackWidth;
    canvas.drawCircle(center, trackRadius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: trackRadius),
      -math.pi / 2 - 0.025,
      0.05,
      false,
      trackPaint..color = successColor,
    );
  }

  @override
  bool shouldRepaint(_ResetRingPainter oldDelegate) =>
      outlineColor != oldDelegate.outlineColor ||
      fillColor != oldDelegate.fillColor ||
      trackColor != oldDelegate.trackColor ||
      successColor != oldDelegate.successColor ||
      accentColor != oldDelegate.accentColor ||
      trackWidth != oldDelegate.trackWidth;
}
