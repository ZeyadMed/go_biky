import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/bloc/base_bloc.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/balance/data/model/balance_model.dart';
import 'package:go_biky/feature/balance/presentation/view/widgets/balance_status.dart';
import 'package:go_biky/feature/balance/presentation/view/widgets/money_format.dart';
import 'package:go_biky/feature/balance/presentation/view_model/cubit/balance_cubit.dart';
import 'package:go_router/go_router.dart';

/// المديونية أو الرصيد اللي ليه، والضغط عليه بيفتح كشف الحساب.
/// `showDetails` بيزوّد إجمالي المستحقات والمدفوع تحت (في حسابي)
class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key, this.showDetails = false});

  final bool showDetails;

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  final _cubit = getIt<BalanceCubit>();

  @override
  void initState() {
    super.initState();
    // الكارت في الرئيسية وحسابي والتابات بتتبني مع بعض، فأول واحد بس
    // هو اللي بيطلب
    if (_cubit.state.isInitial) _cubit.getBalance();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BalanceCubit, BaseState<BalanceModel>>(
      bloc: _cubit,
      builder: (context, state) => switch (state.data) {
        final balance? => _Content(
          balance: balance,
          showDetails: widget.showDetails,
        ),
        null when state.isFailure => FailureWidget(
          compact: true,
          errorMessage: 'balance.loadFailed'.tr(),
          onRefresh: _cubit.getBalance,
        ),
        null => AppShimmer(
          child: ShimmerBox(
            height: widget.showDetails ? 150.h : 84.h,
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.balance, required this.showDetails});

  final BalanceModel balance;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final status = BalanceStatus.of(balance);
    final statusColor = status.color(colors);

    return Material(
      color: colors.bgSecondary,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(24.r),
      child: InkWell(
        onTap: () => context.push(AppRouter.statement),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16.w, 14.h, 16.w, 14.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: status.containerColor(colors),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(status.icon, color: statusColor, size: 22.r),
                  ),
                  Gaps.h(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.labelKey.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            context.formatMoney(status.amountOf(balance)),
                            style: textTheme.headlineSmall?.copyWith(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gaps.h(8.w),
                  Text(
                    'balance.viewStatement'.tr(),
                    style: textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Gaps.h(4.w),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13.r,
                    color: colors.primary,
                  ),
                ],
              ),
              if (showDetails) ...[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Divider(height: 1, thickness: 1, color: colors.border),
                ),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _Total(
                          label: 'balance.totalCharged'.tr(),
                          amount: balance.totalCharged,
                        ),
                      ),
                      VerticalDivider(
                        width: 24.w,
                        thickness: 1,
                        color: colors.border,
                      ),
                      Expanded(
                        child: _Total(
                          label: 'balance.totalPaid'.tr(),
                          amount: balance.totalPaid,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            fontSize: 11.sp,
            color: context.appColors.textSecondary,
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            context.formatMoney(amount),
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
