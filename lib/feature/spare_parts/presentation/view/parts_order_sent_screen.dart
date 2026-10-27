import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/router/bottom_nav_app.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/spare_parts/presentation/widgets/spare_parts_widgets.dart';
import 'package:go_biky/feature/spare_parts/spare_parts_order.dart';
import 'package:go_router/go_router.dart';

// TODO: من بيانات المستخدم لما الـ API يجهز
const _riderFirstName = 'أحمد';
const _fleetName = 'مدار';

/// تأكيد إرسال طلب القطع: الطلب وصل للمراجعة ولسه مش جاهز للاستلام
class PartsOrderSentScreen extends StatelessWidget {
  const PartsOrderSentScreen({super.key, required this.order});

  final SparePartsOrder order;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final createdAt = order.createdAt;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 0),
              child: ResponsiveCenter(
                child: CustomBackHeader(title: 'partsOrder.sentTitle'.tr()),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
                child: ResponsiveCenter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (order.items.firstOrNull?.part case final part?)
                        Center(
                          child: SizedBox(
                            width: 168.r,
                            height: 182.r,
                            child: SparePartImage(
                              source: part.images.firstOrNull,
                              category: part.category,
                              borderRadius: 24.r,
                              iconSize: 56.r,
                            ),
                          ),
                        ),
                      Gaps.v(12.h),
                      const Center(child: _SuccessCheck()),
                      Gaps.v(12.h),
                      Text(
                        'partsOrder.received'.tr(args: [_riderFirstName]),
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          height: 1.4,
                        ),
                      ),
                      Gaps.v(4.h),
                      Text(
                        'partsOrder.receivedSubtitle'.tr(args: [_fleetName]),
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.textSecondary,
                          height: 1.7,
                        ),
                      ),
                      Gaps.v(12.h),
                      Center(
                        child: CustomBadge(
                          text: 'partsOrder.sentBadge'.tr(
                            args: [
                              context.formatNumber(order.id, grouped: false),
                            ],
                          ),
                        ),
                      ),
                      Gaps.v(20.h),
                      CustomDetailsCard(
                        rows: [
                          (
                            label: 'partsOrder.orderDate'.tr(),
                            value: 'partsOrder.dateTime'.tr(
                              args: [
                                context.formatDate(createdAt),
                                context.formatTime(createdAt),
                              ],
                            ),
                          ),
                          (
                            label: 'partsOrder.requestedParts'.tr(),
                            value: partsAndUnits(
                              context,
                              parts: order.items.length,
                              units: order.unitsCount,
                            ),
                          ),
                          (
                            label: 'partsOrder.totalWithVat'.tr(),
                            value: context.formatPrice(order.total),
                          ),
                          (
                            label: 'partsOrder.pickupCenter'.tr(),
                            value: order.pickupCenter,
                          ),
                        ],
                      ),
                      Gaps.v(12.h),
                      const _NextStepCard(),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(20.w, 8.h, 20.w, 16.h),
              child: ResponsiveCenter(
                child: CustomButton(
                  title: 'partsOrder.viewDetails'.tr(),
                  // الرجوع من التفاصيل بيودّي على طلباتي مش على التأكيد
                  onPressed: () {
                    final router = GoRouter.of(context);
                    BottomNavApp.openTab(context, BottomNavTab.orders);
                    router.push(AppRouter.orderDetails, extra: order);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// علامة صح في دايرة بلون النجاح. الصح بلون الكروت عشان يفضل واضح في
/// الوضعين (أبيض في الفاتح وغامق فوق الأخضر الفاتح في الداكن)
class _SuccessCheck extends StatelessWidget {
  const _SuccessCheck();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(color: colors.success, shape: BoxShape.circle),
      child: Icon(Icons.check_rounded, color: colors.bgSecondary, size: 26.r),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  const _NextStepCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'partsOrder.nextStepTitle'.tr(),
            style: context.textTheme.titleSmall?.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          Gaps.v(2.h),
          Text(
            'partsOrder.nextStepBody'.tr(),
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: 11.sp,
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
