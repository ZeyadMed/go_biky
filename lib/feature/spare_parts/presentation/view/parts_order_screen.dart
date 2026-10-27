import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/orders/presentation/view_model/cubit/orders_cubit.dart';
import 'package:go_biky/feature/spare_parts/cart_item.dart';
import 'package:go_biky/feature/spare_parts/presentation/view_model/cubit/cart_cubit.dart';
import 'package:go_biky/feature/spare_parts/presentation/widgets/spare_parts_widgets.dart';
import 'package:go_biky/feature/spare_parts/spare_parts_order.dart';
import 'package:go_router/go_router.dart';

// TODO: بيانات مؤقتة لحد ما الـ API يجهز
const _bikeName = 'ياماها إف زد ٢٥٠';
const _pickupCenter = 'مدار • الياسمين';

/// طلب قطع الغيار: القطع اللي في السلة بكمياتها والإجمالي. الطلب بيتبعت
/// للمراجعة مش للدفع، وبعد الإرسال الشاشة بتتبدل بشاشة التأكيد
class PartsOrderScreen extends StatefulWidget {
  const PartsOrderScreen({super.key});

  @override
  State<PartsOrderScreen> createState() => _PartsOrderScreenState();
}

class _PartsOrderScreenState extends State<PartsOrderScreen> {
  final _cart = getIt<CartCubit>();
  final _notesController = TextEditingController();

  /// بعد الإرسال السلة بتتمسح، فالشاشة بتفضل زي ما هي لحد ما تختفي بدل
  /// ما تبان فاضية وقت الانتقال
  bool _submitted = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    final notes = _notesController.text.trim();
    // TODO: إرسال الطلب لما الـ API يجهز، والطلب اللي بيرجع منه هو اللي
    // يتبعت لشاشة التأكيد ويتضاف في طلباتي
    final orders = getIt<OrdersCubit>();
    final order = SparePartsOrder(
      id: orders.nextTempId,
      createdAt: DateTime.now(),
      items: _cart.items,
      pickupCenter: _pickupCenter,
      notes: notes.isEmpty ? null : notes,
    );
    orders.add(order);
    _submitted = true;
    _cart.clear();
    context.pushReplacement(AppRouter.partsOrderSent, extra: order);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cart,
      child: BlocBuilder<CartCubit, Map<int, CartItem>>(
        buildWhen: (_, _) => !_submitted,
        builder: (context, cart) {
          final items = cart.values.toList();
          final total = _cart.totalPrice;

          return DismissKeyboardWrapper(
            child: Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                        20.w,
                        12.h,
                        20.w,
                        0,
                      ),
                      child: ResponsiveCenter(
                        child: CustomBackHeader(
                          title: 'partsOrder.title'.tr(),
                          subtitle: items.isEmpty
                              ? null
                              : partsAndUnits(
                                  context,
                                  parts: items.length,
                                  units: _cart.totalCount,
                                ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: items.isEmpty
                          ? const _EmptyOrder()
                          : SingleChildScrollView(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                12.h,
                                20.w,
                                24.h,
                              ),
                              child: ResponsiveCenter(
                                child: _OrderBody(
                                  items: items,
                                  total: total,
                                  notesController: _notesController,
                                ),
                              ),
                            ),
                    ),
                    if (items.isNotEmpty)
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          20.w,
                          8.h,
                          20.w,
                          16.h,
                        ),
                        child: ResponsiveCenter(
                          child: CustomButton(
                            title: 'partsOrder.submitWithTotal'.tr(
                              args: [context.formatPrice(total)],
                            ),
                            onPressed: _submit,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderBody extends StatelessWidget {
  const _OrderBody({
    required this.items,
    required this.total,
    required this.notesController,
  });

  final List<CartItem> items;
  final num total;
  final TextEditingController notesController;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            'partsOrder.forYourBike'.tr(args: [_bikeName]),
            style: textTheme.labelSmall?.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        for (final item in items) ...[
          Gaps.v(12.h),
          _OrderItemCard(item: item),
        ],
        Gaps.v(16.h),
        CustomTextField(
          controller: notesController,
          labelText: 'partsOrder.notesLabel'.tr(),
          hintText: 'partsOrder.notesHint'.tr(),
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 3,
        ),
        Gaps.v(16.h),
        CustomDetailsCard(
          rows: [
            for (final item in items)
              (
                label: 'partsOrder.itemLine'.tr(
                  args: [item.part.name, context.formatNumber(item.quantity)],
                ),
                value: context.formatPrice(item.total),
              ),
          ],
          footer: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'partsOrder.total'.tr(),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Gaps.h(12.w),
                  Text(
                    context.formatPrice(total),
                    style: textTheme.headlineMedium?.copyWith(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
              Gaps.v(4.h),
              Text(
                'partsOrder.vatNote'.tr(),
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 10.sp,
                  color: colors.textHint,
                ),
              ),
            ],
          ),
        ),
        Gaps.v(16.h),
        Text(
          'partsOrder.disclaimer'.tr(),
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 11.sp,
            color: colors.textHint,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

/// صورة القطعة واسمها وسعر الوحدة، والكمية بتتغير من العداد وأقل كمية
/// واحدة، والحذف من زرار السلة
class _OrderItemCard extends StatelessWidget {
  const _OrderItemCard({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final cart = context.read<CartCubit>();
    final part = item.part;

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: context.responsiveValue(mobile: 88.r, smallMobile: 72.r),
            height: 104.r,
            child: SparePartImage(
              source: part.images.firstOrNull,
              category: part.category,
              borderRadius: 16.r,
              iconSize: 28.r,
            ),
          ),
          Gaps.h(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  part.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'partsOrder.unitPrice'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          color: colors.textHint,
                        ),
                      ),
                    ),
                    Gaps.h(8.w),
                    Text(
                      context.formatPrice(part.price),
                      style: textTheme.titleSmall?.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Gaps.v(8.h),
                Row(
                  children: [
                    CustomQuantityStepper(
                      quantity: item.quantity,
                      onIncrement: () => cart.increment(part),
                      onDecrement: item.quantity > 1
                          ? () => cart.decrement(part)
                          : null,
                      style: QuantityStepperStyle.boxed,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => cart.remove(part),
                      tooltip: 'partsOrder.remove'.tr(),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: colors.textSecondary,
                        size: 22.r,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// السلة فاضية: لو اتفتحت من غير قطع أو الراكب حذف كل حاجة
class _EmptyOrder extends StatelessWidget {
  const _EmptyOrder();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: ResponsiveCenter(
          maxWidth: 360.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                color: colors.textHint,
                size: 56.r,
              ),
              Gaps.v(12.h),
              Text(
                'partsOrder.emptyTitle'.tr(),
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Gaps.v(4.h),
              Text(
                'partsOrder.emptySubtitle'.tr(),
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
              Gaps.v(20.h),
              CustomButton(
                title: 'partsOrder.browseParts'.tr(),
                onPressed: () => context.pop(),
                outlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
