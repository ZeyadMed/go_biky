import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_change_model.dart';
import 'package:go_biky/feature/oil_change/data/model/oil_status_model.dart';
import 'package:go_biky/feature/oil_change/presentation/view/widgets/oil_change_widgets.dart';
import 'package:go_biky/feature/oil_change/presentation/view/widgets/oil_status.dart';
import 'package:go_biky/feature/oil_change/presentation/view_model/cubit/oil_log_cubit.dart';
import 'package:go_biky/feature/oil_change/presentation/view_model/cubit/oil_status_cubit.dart';

/// سجل تغييرات الزيت: دورة الزيت الحالية فوق، والتغييرات متجمعة بالشهر
/// من الأحدث للأقدم، والصفحة اللي بعدها بتيجي مع السكرول
class OilLogScreen extends StatefulWidget {
  const OilLogScreen({super.key});

  @override
  State<OilLogScreen> createState() => _OilLogScreenState();
}

class _OilLogScreenState extends State<OilLogScreen> {
  final _logCubit = getIt<OilLogCubit>();
  final _oilCubit = getIt<OilStatusCubit>();

  @override
  void initState() {
    super.initState();
    if (_logCubit.state.isInitial) _logCubit.fetch(page: 1);
  }

  /// الدورة الحالية جاية من حالة الزيت، فبتتحدث مع السجل
  Future<void> _refresh() =>
      Future.wait([_logCubit.refresh(), _oilCubit.getOilStatus()]);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        bottom: false,
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
              child: BlocBuilder<OilLogCubit, BaseState<OilChangeModel>>(
                bloc: _logCubit,
                builder: (context, state) {
                  if (state.isFailure && state.items.isEmpty) {
                    return FailureWidget(
                      errorMessage:
                          state.errorMessage ??
                          'common.somethingWentWrong'.tr(),
                      onRefresh: _refresh,
                    );
                  }

                  return RefreshIndicator(
                    color: colors.primary,
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      controller: _logCubit.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      // الـ padding اللي تحت فيه ارتفاع الـ bottom nav، فآخر
                      // المحتوى مايستخباش وراه
                      padding: EdgeInsetsDirectional.fromSTEB(
                        24.w,
                        16.h,
                        24.w,
                        MediaQuery.paddingOf(context).bottom + 24.h,
                      ),
                      child: ResponsiveCenter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            BlocBuilder<
                              OilStatusCubit,
                              BaseState<OilStatusModel>
                            >(
                              bloc: _oilCubit,
                              builder: (context, oilState) =>
                                  switch (oilState.data) {
                                    final oil? => _CurrentCycleCard(oil: oil),
                                    null when oilState.isFailure =>
                                      const SizedBox.shrink(),
                                    null => AppShimmer(
                                      child: ShimmerBox(
                                        height: 96.h,
                                        borderRadius: BorderRadius.circular(
                                          24.r,
                                        ),
                                      ),
                                    ),
                                  },
                            ),
                            Gaps.v(24.h),
                            _Entries(state: state),
                            if (state.isLoadingMore) ...[
                              Gaps.v(16.h),
                              Center(
                                child: CircularProgressIndicator(
                                  color: colors.primary,
                                ),
                              ),
                            ],
                            if (state.isLoadingMoreFauilare) ...[
                              Gaps.v(8.h),
                              Center(
                                child: TextButton(
                                  onPressed: () =>
                                      _logCubit.fetch(page: state.page),
                                  style: TextButton.styleFrom(
                                    foregroundColor: colors.primary,
                                  ),
                                  child: Text('common.retry'.tr()),
                                ),
                              ),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// التغييرات متجمعة بالشهر، أو shimmer أول تحميل، أو رسالة لو السجل فاضي
class _Entries extends StatelessWidget {
  const _Entries({required this.state});

  final BaseState<OilChangeModel> state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (state.items.isEmpty) {
      if (state.isInitial || state.isLoading) {
        return const ListShimmer(itemCount: 4);
      }
      return Text(
        'oilLog.empty'.tr(),
        textAlign: TextAlign.center,
        style: context.textTheme.bodyMedium?.copyWith(
          color: colors.textSecondary,
        ),
      );
    }

    final months = <DateTime, List<OilChangeModel>>{};
    for (final entry in state.items) {
      final date = entry.submittedAtUtc.toLocal();
      months.putIfAbsent(DateTime(date.year, date.month), () => []).add(entry);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, MapEntry(key: month, value: entries))
            in months.entries.indexed) ...[
          if (index > 0) Gaps.v(24.h),
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
      ],
    );
  }
}

/// دورة الزيت من آخر تغيير معتمد، ولون المتبقي حسب حالة الزيت زي الرئيسية
class _CurrentCycleCard extends StatelessWidget {
  const _CurrentCycleCard({required this.oil});

  final OilStatusModel oil;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final onCard = context.colorScheme.onSecondary;
    final remainingKm = oil.remainingToMaxKm.clamp(0, oil.maxKm);
    final status = OilStatus.of(oil);

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
                        context.formatNumber(oil.kmSinceOilChange),
                        context.formatNumber(oil.maxKm),
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

  final OilChangeModel entry;

  String _caption(BuildContext context) => switch (entry.status) {
    OilChangeStatus.pending => 'oilLog.pendingCaption'.tr(
      args: [entry.shortId, _sentAt(context)],
    ),
    OilChangeStatus.approved => 'oilLog.approvedCaption'.tr(
      args: [context.formatNumber(entry.kmAtSubmit)],
    ),
    OilChangeStatus.rejected => entry.rejectReason ?? '',
  };

  /// التاريخ مكتوب في عنوان الكارت، فلو مش النهارده بيكفي الوقت
  String _sentAt(BuildContext context) {
    final submittedAt = entry.submittedAtUtc.toLocal();
    final time = context.formatTime(submittedAt);
    return DateUtils.isSameDay(submittedAt, DateTime.now())
        ? 'oilLog.todayAt'.tr(args: [time])
        : time;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final caption = _caption(context);
    final (statusKey, statusColor, statusContainer) = switch (entry.status) {
      OilChangeStatus.pending => (
        'oilLog.statusPending',
        colors.warning,
        colors.warningContainer,
      ),
      OilChangeStatus.approved => (
        'oilLog.statusApproved',
        colors.success,
        colors.successContainer,
      ),
      OilChangeStatus.rejected => (
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
          OilChangeVideoThumb(width: 60.r, height: 76.r, borderRadius: 12.r),
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
                        context.formatDate(entry.submittedAtUtc.toLocal()),
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
                if (entry.odometerKmAtSubmit case final odometerKm?) ...[
                  Gaps.v(4.h),
                  Text(
                    'oilLog.odometer'.tr(
                      args: [context.formatNumber(odometerKm)],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (caption.isNotEmpty) ...[
                  Gaps.v(4.h),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: entry.status == OilChangeStatus.rejected
                          ? colors.error
                          : colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
