import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/spare_parts/presentation/view_model/cubit/cart_cubit.dart';
import 'package:go_biky/feature/spare_parts/presentation/widgets/spare_parts_widgets.dart';
import 'package:go_biky/feature/spare_parts/spare_part.dart';
import 'package:go_router/go_router.dart';

/// تفاصيل القطعة: الكمية بتتحدد هنا وبتدخل الطلب من الزرار اللي تحت. لو
/// القطعة في الطلب بالفعل الشاشة بتبدأ بكميتها والزرار بيحدّثها
class SparePartDetailsScreen extends StatefulWidget {
  const SparePartDetailsScreen({super.key, required this.part});

  final SparePart part;

  @override
  State<SparePartDetailsScreen> createState() => _SparePartDetailsScreenState();
}

class _SparePartDetailsScreenState extends State<SparePartDetailsScreen> {
  final _cart = getIt<CartCubit>();
  late final bool _inCart = _cart.quantityOf(widget.part.id) > 0;
  late int _quantity = _inCart ? _cart.quantityOf(widget.part.id) : 1;

  void _submit() {
    _cart.setQuantity(widget.part, _quantity);
    context.showSuccessMessage(
      (_inCart ? 'spareParts.orderUpdated' : 'spareParts.addedToOrder').tr(),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final part = widget.part;
    final colors = context.appColors;
    final textTheme = context.textTheme;
    final canOrder = part.stock.canOrder;

    return BlocProvider.value(
      value: _cart,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 12.w, 0),
                child: ResponsiveCenter(
                  child: CustomBackHeader(
                    title: 'spareParts.detailsTitle'.tr(),
                    trailing: const CartButton(),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                  child: ResponsiveCenter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Gallery(images: part.images, category: part.category),
                        Gaps.v(16.h),
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: CustomBadge(
                                  text: part.stock.detailsLabelKey.tr(),
                                  color: part.stock.color(colors),
                                  backgroundColor: part.stock.containerColor(
                                    colors,
                                  ),
                                ),
                              ),
                            ),
                            Gaps.h(12.w),
                            Text(
                              context.formatPrice(part.price),
                              style: textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.primary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          part.name,
                          style: textTheme.headlineSmall?.copyWith(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Gaps.v(6.h),
                        Text(
                          part.description,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 13.sp,
                            color: colors.textSecondary,
                            height: 1.7,
                          ),
                        ),
                        if (part.compatibleBike case final bike?) ...[
                          Gaps.v(16.h),
                          _CompatibilityCard(bikeName: bike),
                        ],
                        Gaps.v(20.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'spareParts.quantity'.tr(),
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            CustomQuantityStepper(
                              quantity: _quantity,
                              onIncrement: canOrder
                                  ? () => setState(() => _quantity++)
                                  : null,
                              onDecrement: canOrder && _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                            ),
                          ],
                        ),
                        Gaps.v(16.h),
                        Text(
                          'spareParts.priceNote'.tr(),
                          style: textTheme.bodySmall?.copyWith(
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
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20.w, 8.h, 20.w, 16.h),
                child: ResponsiveCenter(
                  child: CustomButton(
                    title:
                        (_inCart
                                ? 'spareParts.updateOrderWithPrice'
                                : 'spareParts.addToOrderWithPrice')
                            .tr(
                              args: [
                                context.formatPrice(part.price * _quantity),
                              ],
                            ),
                    onPressed: canOrder ? _submit : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// الصورة الكبيرة بتتقلب بالسحب، والصور الصغيرة تحتها بتظهر لو في أكتر من
/// صورة والضغط على واحدة بيفتحها
class _Gallery extends StatefulWidget {
  const _Gallery({required this.images, required this.category});

  final List<String> images;
  final SparePartCategory category;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  final _pageController = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _open(int index) => _pageController.animateToPage(
    index,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final images = widget.images;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 13 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22.r),
            child: images.isEmpty
                ? SparePartImage(
                    source: null,
                    category: widget.category,
                    iconSize: 64.r,
                  )
                : PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) => setState(() => _current = index),
                    itemBuilder: (context, index) => SparePartImage(
                      source: images[index],
                      category: widget.category,
                      iconSize: 64.r,
                    ),
                  ),
          ),
        ),
        if (images.length > 1) ...[
          Gaps.v(10.h),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              for (var i = 0; i < images.length; i++)
                Semantics(
                  button: true,
                  selected: i == _current,
                  child: GestureDetector(
                    onTap: () => _open(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44.r,
                      height: 44.r,
                      padding: EdgeInsets.all(2.r),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: i == _current ? colors.primary : colors.border,
                          width: 1.5.r,
                        ),
                      ),
                      child: SparePartImage(
                        source: images[i],
                        category: widget.category,
                        borderRadius: 9.r,
                        iconSize: 18.r,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _CompatibilityCard extends StatelessWidget {
  const _CompatibilityCard({required this.bikeName});

  final String bikeName;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.successContainer,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, color: colors.success, size: 22.r),
          Gaps.h(10.w),
          Expanded(
            child: Text(
              'spareParts.compatibleWith'.tr(args: [bikeName]),
              style: context.textTheme.labelLarge?.copyWith(
                color: colors.success,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
