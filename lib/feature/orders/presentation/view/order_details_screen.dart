import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/spare_parts/presentation/widgets/spare_parts_widgets.dart';
import 'package:go_biky/feature/spare_parts/spare_parts_order.dart';
import 'package:go_router/go_router.dart';

/// تفاصيل طلب القطع: بياناته ورحلته من الإرسال لحد الاستلام والقطع اللي فيه
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final SparePartsOrder order;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final status = order.status;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 0),
              child: ResponsiveCenter(
                child: CustomBackHeader(title: 'orderDetails.title'.tr()),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                child: ResponsiveCenter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomDetailsCard(
                        header: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'orders.orderNumber'.tr(
                                  args: [
                                    context.formatNumber(
                                      order.id,
                                      grouped: false,
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.headlineSmall?.copyWith(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Gaps.h(8.w),
                            CustomBadge(
                              text: status.labelKey.tr(),
                              color: status.color(colors),
                              backgroundColor: status.containerColor(colors),
                            ),
                          ],
                        ),
                        rows: [
                          (
                            label: 'orderDetails.createdAt'.tr(),
                            value: context.formatDate(order.createdAt),
                          ),
                          (
                            label: 'partsOrder.pickupCenter'.tr(),
                            value: order.pickupCenter,
                          ),
                        ],
                      ),
                      Gaps.v(20.h),
                      RowWidget(title: 'orderDetails.journey'.tr()),
                      Gaps.v(12.h),
                      _OrderJourney(order: order),
                      Gaps.v(20.h),
                      RowWidget(
                        title: 'partsOrder.requestedParts'.tr(),
                        trailing: Text(
                          'partsOrder.unitsCount'.plural(
                            order.unitsCount,
                            args: [context.formatNumber(order.unitsCount)],
                          ),
                          style: textTheme.labelMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Gaps.v(12.h),
                      _OrderPartsCard(order: order),
                      if (order.notes case final notes?) ...[
                        Gaps.v(12.h),
                        Text(
                          'orderDetails.yourNote'.tr(args: [notes]),
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                            color: colors.textHint,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 8.h, 20.w, 16.h),
              child: ResponsiveCenter(
                child: CustomButton(
                  title: 'orderDetails.contact'.tr(),
                  onPressed: () => context.push(
                    AppRouter.contactUs,
                    extra: 'contactUs.orderSubject'.tr(
                      args: [context.formatNumber(order.id, grouped: false)],
                    ),
                  ),
                  backgroundColor: colors.secondary,
                  textColor: context.colorScheme.onSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// مراحل الطلب بالترتيب: اللي خلصت بلون النجاح، والحالية بلون حالتها
/// وحواليها هالة، واللي لسه رمادي. اللي ليها تاريخ بيظهر تاريخها، والباقي
/// وصف المرحلة
class _OrderJourney extends StatelessWidget {
  const _OrderJourney({required this.order});

  final SparePartsOrder order;

  @override
  Widget build(BuildContext context) {
    const steps = OrderStatus.values;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.appColors.bgSecondary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          for (final step in steps)
            _JourneyStep(order: order, step: step, isLast: step == steps.last),
        ],
      ),
    );
  }
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({
    required this.order,
    required this.step,
    required this.isLast,
  });

  final SparePartsOrder order;
  final OrderStatus step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final status = order.status;
    final isCurrent = step == status;
    final isReached = step.index <= status.index;
    final date = isReached ? order.reachedAt(step) : null;
    final dotSize = 18.r;

    final Widget dot;
    if (isCurrent) {
      dot = Container(
        width: dotSize,
        height: dotSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: status.containerColor(colors),
          shape: BoxShape.circle,
        ),
        child: Container(
          width: dotSize * 0.55,
          height: dotSize * 0.55,
          decoration: BoxDecoration(
            color: status.color(colors),
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      dot = Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          color: isReached ? colors.success : colors.bgTertiary,
          shape: BoxShape.circle,
          border: isReached
              ? null
              : Border.all(color: colors.border, width: 1.5.r),
        ),
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: dotSize,
            child: Column(
              children: [
                Gaps.v(4.h),
                dot,
                // الخط بيتلوّن لما المرحلة اللي بعده تبقى وصلت
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.r,
                      color: step.index < status.index
                          ? colors.success
                          : colors.border,
                    ),
                  ),
              ],
            ),
          ),
          Gaps.h(12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsetsDirectional.only(bottom: isLast ? 0 : 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.labelKey.tr(),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: isReached ? FontWeight.w800 : FontWeight.w700,
                      color: isReached ? colors.textPrimary : colors.textHint,
                    ),
                  ),
                  Text(
                    date == null
                        ? step.hintKey.tr()
                        : 'orderDetails.stepDate'.tr(
                            args: [
                              context.formatDayMonth(date),
                              context.formatTime(date),
                            ],
                          ),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: isReached ? colors.textSecondary : colors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// القطع بصورها وكمياتها وسعر كل واحدة، والإجمالي في الآخر
class _OrderPartsCard extends StatelessWidget {
  const _OrderPartsCard({required this.order});

  final SparePartsOrder order;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final amountStyle = textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w800,
    );

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in order.items) ...[
            Row(
              children: [
                SizedBox.square(
                  dimension: 48.r,
                  child: SparePartImage(
                    source: item.part.images.firstOrNull,
                    category: item.part.category,
                    borderRadius: 12.r,
                    iconSize: 20.r,
                  ),
                ),
                Gaps.h(10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.part.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: amountStyle,
                      ),
                      Text(
                        'orderDetails.unitLine'.tr(
                          args: [
                            context.formatNumber(item.quantity),
                            context.formatPrice(item.part.price),
                          ],
                        ),
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          color: colors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                Gaps.h(8.w),
                Text(context.formatPrice(item.total), style: amountStyle),
              ],
            ),
            Gaps.v(12.h),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  'partsOrder.totalWithVat'.tr(),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              Gaps.h(8.w),
              Text(context.formatPrice(order.total), style: amountStyle),
            ],
          ),
        ],
      ),
    );
  }
}
