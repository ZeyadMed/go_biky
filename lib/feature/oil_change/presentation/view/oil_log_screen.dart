import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/oil_change/oil_log_entry.dart';
import 'package:go_biky/feature/oil_change/oil_status.dart';

// TODO: بيانات مؤقتة لحد ما الـ API يجهز
const _cycleKmUsed = 45;
const _cycleKmInterval = 50;
final _entries = [
  OilLogEntry(
    proofId: 782,
    status: OilLogStatus.pending,
    changeDate: DateTime(2026, 10, 25),
    submittedAt: DateTime(2026, 10, 25, 10, 30),
    odometerKm: 12495,
  ),
  OilLogEntry(
    proofId: 781,
    status: OilLogStatus.approved,
    changeDate: DateTime(2026, 10, 24),
    submittedAt: DateTime(2026, 10, 24, 9, 15),
    odometerKm: 12450,
  ),
  OilLogEntry(
    proofId: 780,
    status: OilLogStatus.approved,
    changeDate: DateTime(2026, 10, 23),
    submittedAt: DateTime(2026, 10, 23, 18, 40),
    odometerKm: 12400,
    cycleKm: 49,
  ),
  OilLogEntry(
    proofId: 779,
    status: OilLogStatus.rejected,
    changeDate: DateTime(2026, 10, 23),
    submittedAt: DateTime(2026, 10, 23, 17, 5),
    odometerKm: 12398,
    rejectionReason: 'الصورة غير واضحة',
    resubmitted: true,
  ),
];

/// سجل تغييرات الزيت: دورة الزيت الحالية فوق، والتغييرات متجمعة بالشهر
/// من الأحدث للأقدم
class OilLogScreen extends StatelessWidget {
  const OilLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final months = <DateTime, List<OilLogEntry>>{};
    for (final entry in _entries) {
      final date = entry.changeDate;
      months.putIfAbsent(DateTime(date.year, date.month), () => []).add(entry);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24.w, 12.h, 16.w, 0),
              child: ResponsiveCenter(
                child: CustomBackHeader(
                  title: 'oilLog.title'.tr(),
                  subtitle: 'oilLog.subtitle'.tr(),
                  trailing: IconButton(
                    // TODO: فلترة السجل لما يتعمل الديزاين بتاعها
                    onPressed: () {},
                    tooltip: 'oilLog.filter'.tr(),
                    icon: Icon(
                      Icons.tune_rounded,
                      color: colors.textPrimary,
                      size: 26.r,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
                child: ResponsiveCenter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _CurrentCycleCard(
                        kmUsed: _cycleKmUsed,
                        kmInterval: _cycleKmInterval,
                      ),
                      for (final MapEntry(key: month, value: entries)
                          in months.entries) ...[
                        Gaps.v(24.h),
                        RowWidget(
                          title: context.formatMonthYear(month),
                          trailing: Text(
                            'oilLog.recordsCount'.plural(
                              entries.length,
                              args: [context.formatNumber(entries.length)],
                            ),
                            style: context.textTheme.labelMedium?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        for (final entry in entries) ...[
                          Gaps.v(12.h),
                          _EntryCard(entry: entry),
                        ],
                      ],
                      Gaps.v(20.h),
                      Text(
                        'oilLog.footnote'.tr(),
                        textAlign: TextAlign.center,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          color: colors.textHint,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// دورة الزيت من آخر تغيير معتمد، ولون المتبقي حسب حالة الزيت زي الرئيسية
class _CurrentCycleCard extends StatelessWidget {
  const _CurrentCycleCard({required this.kmUsed, required this.kmInterval});

  final int kmUsed;
  final int kmInterval;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final onCard = context.colorScheme.onSecondary;
    final remainingKm = (kmInterval - kmUsed).clamp(0, kmInterval);
    final status = OilStatus.from(
      remainingKm: remainingKm,
      intervalKm: kmInterval,
    );

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(18.w, 16.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'oilLog.currentCycle'.tr(),
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: 11.sp,
              color: onCard.withValues(alpha: 0.7),
            ),
          ),
          Gaps.v(4.h),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    'oilLog.cycleProgress'.tr(
                      args: [
                        context.formatNumber(kmUsed),
                        context.formatNumber(kmInterval),
                      ],
                    ),
                    style: context.textTheme.displaySmall?.copyWith(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w800,
                      color: onCard,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              Gaps.h(12.w),
              CustomBadge(
                text: 'oilLog.kmRemaining'.tr(
                  args: [context.formatNumber(remainingKm)],
                ),
                color: status.color(colors),
                backgroundColor: status.containerColor(colors),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final OilLogEntry entry;

  String _caption(BuildContext context) => switch (entry.status) {
    OilLogStatus.pending => 'oilLog.pendingCaption'.tr(
      args: [
        context.formatNumber(entry.proofId, grouped: false),
        _sentAt(context),
      ],
    ),
    OilLogStatus.approved => switch (entry.cycleKm) {
      final km? => 'oilLog.approvedCaption'.tr(
        args: [context.formatNumber(km)],
      ),
      null => 'oilLog.currentCycleCaption'.tr(),
    },
    OilLogStatus.rejected => [
      ?entry.rejectionReason,
      if (entry.resubmitted) 'oilLog.resubmitted'.tr(),
    ].join(' • '),
  };

  /// التاريخ مكتوب في عنوان الكارت، فلو مش النهارده بيكفي الوقت
  String _sentAt(BuildContext context) {
    final time = context.formatTime(entry.submittedAt);
    return DateUtils.isSameDay(entry.submittedAt, DateTime.now())
        ? 'oilLog.todayAt'.tr(args: [time])
        : time;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final (statusKey, statusColor, statusContainer) = switch (entry.status) {
      OilLogStatus.pending => (
        'oilLog.statusPending',
        colors.warning,
        colors.warningContainer,
      ),
      OilLogStatus.approved => (
        'oilLog.statusApproved',
        colors.success,
        colors.successContainer,
      ),
      OilLogStatus.rejected => (
        'oilLog.statusRejected',
        colors.error,
        colors.errorContainer,
      ),
    };

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlexibleImage(
            source: entry.image,
            width: 60.r,
            height: 76.r,
            borderRadius: 12.r,
            placeholder: ColoredBox(
              color: colors.bgTertiary,
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  color: colors.textHint,
                  size: 26.r,
                ),
              ),
            ),
          ),
          Gaps.h(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gaps.v(4.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.formatDate(entry.changeDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Gaps.h(8.w),
                    CustomBadge(
                      text: statusKey.tr(),
                      color: statusColor,
                      backgroundColor: statusContainer,
                    ),
                  ],
                ),
                Gaps.v(4.h),
                Text(
                  'oilLog.odometer'.tr(
                    args: [context.formatNumber(entry.odometerKm)],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gaps.v(4.h),
                Text(
                  _caption(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11.sp,
                    color: entry.status == OilLogStatus.rejected
                        ? colors.error
                        : colors.textSecondary,
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
