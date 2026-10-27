import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/orders/presentation/view_model/cubit/orders_cubit.dart';
import 'package:go_biky/feature/spare_parts/presentation/widgets/spare_parts_widgets.dart';
import 'package:go_biky/feature/spare_parts/spare_parts_order.dart';
import 'package:go_router/go_router.dart';

enum _OrdersFilter {
  all('orders.all'),
  active('orders.active'),
  completed('orders.completed');

  const _OrdersFilter(this.labelKey);

  final String labelKey;

  bool matches(SparePartsOrder order) => switch (this) {
    _OrdersFilter.all => true,
    _OrdersFilter.active => !order.status.isCompleted,
    _OrdersFilter.completed => order.status.isCompleted,
  };
}

/// طلباتي: طلبات القطع من الأحدث للأقدم، وكل طلب عليه شريط بمراحله لحد
/// الاستلام
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _filter = _OrdersFilter.all;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocProvider.value(
      value: getIt<OrdersCubit>(),
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 12.w, 0),
                child: ResponsiveCenter(
                  child: CustomBackHeader(
                    title: 'orders.title'.tr(),
                    subtitle: 'orders.subtitle'.tr(),
                    trailing: IconButton(
                      // TODO: فلترة الطلبات لما يتعمل الديزاين بتاعها
                      onPressed: () {},
                      tooltip: 'orders.filter'.tr(),
                      icon: Icon(
                        Icons.tune_rounded,
                        color: colors.textPrimary,
                        size: 26.r,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 0),
                child: ResponsiveCenter(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        for (final filter in _OrdersFilter.values)
                          CustomChoiceChip(
                            label: filter.labelKey.tr(),
                            isSelected: filter == _filter,
                            onTap: () => setState(() => _filter = filter),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 4.h,
                            ),
                            fontSize: 12.sp,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<OrdersCubit, List<SparePartsOrder>>(
                  builder: (context, orders) {
                    final visible = orders.where(_filter.matches).toList();
                    if (visible.isEmpty) return const _NoOrders();

                    // الـ padding اللي تحت فيه ارتفاع الـ bottom nav، فآخر
                    // طلب مايستخباش وراه
                    return ListView.separated(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        20.w,
                        16.h,
                        20.w,
                        MediaQuery.paddingOf(context).bottom + 24.h,
                      ),
                      itemCount: visible.length,
                      separatorBuilder: (_, _) => Gaps.v(12.h),
                      itemBuilder: (context, index) => ResponsiveCenter(
                        child: _OrderCard(order: visible[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final SparePartsOrder order;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final status = order.status;
    final items = order.items
        .map(
          (item) => 'partsOrder.itemLine'.tr(
            args: [item.part.name, context.formatNumber(item.quantity)],
          ),
        )
        .join(' + ');

    return Material(
      color: colors.bgSecondary,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(22.r),
      child: InkWell(
        onTap: () => context.push(AppRouter.orderDetails, extra: order),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(14.w, 14.h, 14.w, 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'orders.orderNumber'.tr(
                        args: [context.formatNumber(order.id, grouped: false)],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
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
              Gaps.v(10.h),
              Row(
                children: [
                  if (order.items.firstOrNull?.part case final part?) ...[
                    SizedBox(
                      width: 72.r,
                      height: 68.r,
                      child: SparePartImage(
                        source: part.images.firstOrNull,
                        category: part.category,
                        borderRadius: 14.r,
                        iconSize: 26.r,
                      ),
                    ),
                    Gaps.h(12.w),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          items,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          context.formatDate(order.createdAt),
                          maxLines: 1,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                            color: colors.textHint,
                          ),
                        ),
                        Gaps.v(2.h),
                        Text(
                          context.formatPrice(order.total),
                          maxLines: 1,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gaps.v(12.h),
              _OrderProgress(status: status),
            ],
          ),
        ),
      ),
    );
  }
}

/// مراحل الطلب: الشرطة لحد المرحلة الحالية بلون الحالة، واسم المرحلة
/// الحالية غامق والباقي باهت
class _OrderProgress extends StatelessWidget {
  const _OrderProgress({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final statusColor = status.color(colors);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final step in OrderStatus.values) ...[
          if (step.index > 0) Gaps.h(4.w),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 3.h,
                  decoration: BoxDecoration(
                    color: step.index <= status.index
                        ? statusColor
                        : colors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                Gaps.v(6.h),
                Text(
                  step.labelKey.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.textTheme.labelSmall?.copyWith(
                    fontSize: 9.sp,
                    color: step == status
                        ? colors.textPrimary
                        : colors.textHint,
                    fontWeight: step == status
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

class _NoOrders extends StatelessWidget {
  const _NoOrders();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, color: colors.textHint, size: 52.r),
            Gaps.v(12.h),
            Text(
              'orders.empty'.tr(),
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
