import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/balance/data/model/balance_model.dart';
import 'package:go_biky/feature/balance/data/model/statement_entry_model.dart';
import 'package:go_biky/feature/balance/data/model/statement_model.dart';
import 'package:go_biky/feature/balance/presentation/view/widgets/balance_status.dart';
import 'package:go_biky/feature/balance/presentation/view/widgets/money_format.dart';
import 'package:go_biky/feature/balance/presentation/view_model/cubit/statement_cubit.dart';

/// كشف الحساب: الرصيد الحالي فوق، والحركات متجمعة بالشهر من الأحدث للأقدم
class StatementScreen extends StatefulWidget {
  const StatementScreen({super.key});

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  final _cubit = getIt<StatementCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.getStatement();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 0),
              child: ResponsiveCenter(
                child: CustomBackHeader(
                  title: 'balance.title'.tr(),
                  subtitle: 'balance.subtitle'.tr(),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<StatementCubit, BaseState<StatementModel>>(
                bloc: _cubit,
                builder: (context, state) {
                  final statement = state.data;

                  if (statement == null) {
                    if (state.isFailure) {
                      return FailureWidget(
                        errorMessage:
                            state.errorMessage ??
                            'common.somethingWentWrong'.tr(),
                        onRefresh: _cubit.getStatement,
                      );
                    }
                    return const _Loading();
                  }

                  return RefreshIndicator(
                    color: colors.primary,
                    onRefresh: _cubit.getStatement,
                    // slivers مش Column، عشان الحركات تتبني مع السكرول بدل
                    // ما الكشف كله يتبني مرة واحدة وهو بيكبر
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                            20.w,
                            16.h,
                            20.w,
                            24.h,
                          ),
                          sliver: SliverResponsiveCenter(
                            sliver: SliverMainAxisGroup(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(
                                      bottom: 24.h,
                                    ),
                                    child: _SummaryCard(
                                      balance: statement.balance,
                                    ),
                                  ),
                                ),
                                _Entries(entries: statement.entries),
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

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 24.h),
      child: ResponsiveCenter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppShimmer(
              child: ShimmerBox(
                height: 150.h,
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
            Gaps.v(24.h),
            const ListShimmer(itemCount: 4, circleImage: true),
          ],
        ),
      ),
    );
  }
}

/// الكارت الغامق اللي فوق: المديونية أو الرصيد كبير، وتحته الإجماليات
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.balance});

  final BalanceModel balance;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final onCard = context.colorScheme.onSecondary;
    final status = BalanceStatus.of(balance);

    Widget total(String label, double amount) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 11.sp,
            color: onCard.withValues(alpha: 0.7),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            context.formatMoney(amount),
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: onCard,
            ),
          ),
        ),
      ],
    );

    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(18.w, 16.h, 18.w, 18.h),
      decoration: BoxDecoration(
        color: colors.secondary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: status.containerColor(colors),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  status.icon,
                  color: status.color(colors),
                  size: 18.r,
                ),
              ),
              Gaps.h(10.w),
              Expanded(
                child: Text(
                  status.labelKey.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: onCard.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          Gaps.v(6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              context.formatMoney(status.amountOf(balance)),
              style: textTheme.displaySmall?.copyWith(
                fontSize: 34.sp,
                fontWeight: FontWeight.w800,
                color: onCard,
                height: 1.3,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Divider(
              height: 1,
              thickness: 1,
              color: onCard.withValues(alpha: 0.15),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: total('balance.totalCharged'.tr(), balance.totalCharged),
              ),
              Gaps.h(12.w),
              Expanded(
                child: total('balance.totalPaid'.tr(), balance.totalPaid),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// الحركات متجمعة بالشهر من الأحدث، أو رسالة لو الكشف فاضي. sliver عشان
/// الكروت تتبني مع السكرول
class _Entries extends StatelessWidget {
  const _Entries({required this.entries});

  final List<StatementEntryModel> entries;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (entries.isEmpty) {
      return SliverToBoxAdapter(
        child: Text(
          'balance.empty'.tr(),
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium?.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    final sorted = [...entries]..sort((a, b) => b.atUtc.compareTo(a.atUtc));
    final months = <DateTime, List<StatementEntryModel>>{};
    for (final entry in sorted) {
      final date = entry.atUtc.toLocal();
      months.putIfAbsent(DateTime(date.year, date.month), () => []).add(entry);
    }

    // عنوان كل شهر وبعده حركاته في لستة واحدة، وكل صف بيتبني لما يظهر
    final rows = <WidgetBuilder>[
      for (final (index, MapEntry(key: month, value: monthEntries))
          in months.entries.indexed) ...[
        (context) => Padding(
          padding: EdgeInsetsDirectional.only(top: index > 0 ? 24.h : 0),
          child: RowWidget(
            title: context.formatMonthYear(month),
            trailing: Text(
              'balance.entriesCount'.plural(
                monthEntries.length,
                args: [context.formatNumber(monthEntries.length)],
              ),
              style: context.textTheme.labelMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        for (final entry in monthEntries)
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

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.entry});

  final StatementEntryModel entry;

  /// الموجب مديونية والسالب رصيد ليه
  String _runningBalance(BuildContext context) {
    final balance = entry.runningBalance;
    if (balance > 0) {
      return 'balance.debtAfter'.tr(args: [context.formatMoney(balance)]);
    }
    if (balance < 0) {
      return 'balance.creditAfter'.tr(args: [context.formatMoney(-balance)]);
    }
    return 'balance.settledAfter'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final isPayment = entry.isPayment;
    final color = isPayment ? colors.success : colors.error;
    final at = entry.atUtc.toLocal();
    final title = entry.description.isNotEmpty
        ? context.localizeDigits(entry.description)
        : (isPayment ? 'balance.payment' : 'balance.charge').tr();
    final captionStyle = textTheme.bodySmall?.copyWith(
      fontSize: 11.sp,
      color: colors.textSecondary,
    );

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: isPayment
                  ? colors.successContainer
                  : colors.errorContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPayment ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: color,
              size: 22.r,
            ),
          ),
          Gaps.h(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${context.formatDayMonth(at)} • ${context.formatTime(at)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: captionStyle,
                ),
                Text(
                  _runningBalance(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: captionStyle?.copyWith(color: colors.textHint),
                ),
              ],
            ),
          ),
          Gaps.h(8.w),
          Text(
            '${isPayment ? '+' : '-'}${context.formatMoney(entry.amount)}',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
