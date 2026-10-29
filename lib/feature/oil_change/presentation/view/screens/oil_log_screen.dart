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

  Widget _currentCycle() {
    return BlocBuilder<OilStatusCubit, BaseState<OilStatusModel>>(
      bloc: _oilCubit,
      builder: (context, oilState) => switch (oilState.data) {
        final oil? => _CurrentCycleCard(oil: oil),
        null when oilState.isFailure => const SizedBox.shrink(),
        null => AppShimmer(
          child: ShimmerBox(
            height: 96.h,
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
      },
    );
  }

  /// تحميل الصفحة اللي بعدها أو إعادة محاولتها، والملاحظة اللي في الآخر
  Widget _footer(BuildContext context, BaseState<OilChangeModel> state) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.isLoadingMore) ...[
          Gaps.v(16.h),
          Center(child: CircularProgressIndicator(color: colors.primary)),
        ],
        if (state.isLoadingMoreFauilare) ...[
          Gaps.v(8.h),
          Center(
            child: CustomButton.text(
              title: 'common.retry'.tr(),
              onPressed: () => _logCubit.fetch(page: state.page),
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
    );
  }

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
                    // slivers مش Column، عشان التغييرات تتبني مع السكرول
                    // بدل ما كل اللي اتحمل يتبني مرة واحدة والسجل بيكبر
                    child: CustomScrollView(
                      controller: _logCubit.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          // الـ padding اللي تحت فيه ارتفاع الـ bottom nav،
                          // فآخر المحتوى مايستخباش وراه
                          padding: EdgeInsetsDirectional.fromSTEB(
                            24.w,
                            16.h,
                            24.w,
                            MediaQuery.paddingOf(context).bottom + 24.h,
                          ),
                          sliver: SliverResponsiveCenter(
                            sliver: SliverMainAxisGroup(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      bottom: 24.h,
                                    ),
                                    child: _currentCycle(),
                                  ),
                                ),
                                _Entries(state: state),
                                SliverToBoxAdapter(
                                  child: _footer(context, state),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

/// التغييرات متجمعة بالشهر، أو shimmer أول تحميل، أو رسالة لو السجل فاضي.
/// sliver عشان الكروت تتبني مع السكرول
class _Entries extends StatelessWidget {
  const _Entries({required this.state});

  final BaseState<OilChangeModel> state;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (state.items.isEmpty) {
      return SliverToBoxAdapter(
        child: state.isInitial || state.isLoading
            ? const ListShimmer(itemCount: 4)
            : Text(
                'oilLog.empty'.tr(),
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
      );
    }

    final months = <DateTime, List<OilChangeModel>>{};
    for (final entry in state.items) {
      final date = entry.submittedAtUtc.toLocal();
      months.putIfAbsent(DateTime(date.year, date.month), () => []).add(entry);
    }

    // عنوان كل شهر وبعده تغييراته في لستة واحدة، وكل صف بيتبني لما يظهر
    final rows = <WidgetBuilder>[
      for (final (index, MapEntry(key: month, value: entries))
          in months.entries.indexed) ...[
        (context) => Padding(
          padding: EdgeInsetsDirectional.only(top: index > 0 ? 24.h : 0),
          child: RowWidget(
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
        ),
        for (final entry in entries)
          (context) => Padding(
            padding: EdgeInsetsDirectional.only(top: 12.h),
            child: _EntryCard(entry: entry),
          ),
      ],
    ];

    return SliverList.builder(
      itemCount: rows.length,
      itemBuilder: (context, index) => rows[index](context),
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
