import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/service_locator/service_locator.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/spare_parts/presentation/view_model/cubit/cart_cubit.dart';
import 'package:go_biky/feature/spare_parts/presentation/widgets/spare_parts_widgets.dart';
import 'package:go_biky/feature/spare_parts/spare_part.dart';
import 'package:go_router/go_router.dart';

// TODO: بيانات مؤقتة لحد ما الـ API يجهز. الصور لسه مش في الـ assets،
// والنص الفاضي بيظهر مكانه أيقونة التصنيف
const _bikeName = 'ياماها إف زد ٢٥٠';
const _parts = [
  SparePart(
    id: 1,
    name: 'زيت محرك ١٠ دبليو-٤٠',
    description:
        'زيت شبه تخليقي لمحركات الدراجات رباعية الأشواط. حماية ثابتة للمحرك '
        'وناقل الحركة في حرارة المدينة. العبوة: ١ لتر • المواصفة: جاسو إم إيه ٢.',
    price: 45,
    category: SparePartCategory.oils,
    stock: StockStatus.available,
    images: ['', ''],
    compatibleBike: _bikeName,
  ),
  SparePart(
    id: 2,
    name: 'فحمات فرامل أمامية',
    description:
        'فحمات سيراميك بثبات عالي في الفرملة وتآكل أقل للديسك، مناسبة للتوقف '
        'المتكرر داخل المدينة. الطقم: قطعتان.',
    price: 75,
    category: SparePartCategory.brakes,
    stock: StockStatus.available,
    compatibleBike: _bikeName,
  ),
  SparePart(
    id: 3,
    name: 'إطار خلفي رياضي',
    description:
        'إطار بدون أنبوب بتماسك قوي على الطرق الجافة والمبللة. المقاس: '
        '١٤٠/٧٠ - ١٧.',
    price: 220,
    category: SparePartCategory.tires,
    stock: StockStatus.available,
    compatibleBike: _bikeName,
  ),
  SparePart(
    id: 4,
    name: 'طقم سلسلة وتروس',
    description:
        'سلسلة بحلقات مانعة للتسريب مع الترس الأمامي والخلفي، لنقل حركة أنعم '
        'وعمر أطول.',
    price: 160,
    category: SparePartCategory.chains,
    stock: StockStatus.limited,
    compatibleBike: _bikeName,
  ),
  SparePart(
    id: 5,
    name: 'فلتر زيت',
    description:
        'فلتر بورق عالي الكثافة يحجز الشوائب ويحافظ على نظافة الزيت حتى '
        'التغيير القادم.',
    price: 30,
    category: SparePartCategory.filters,
    stock: StockStatus.available,
    compatibleBike: _bikeName,
  ),
  SparePart(
    id: 6,
    name: 'مصباح أمامي ليد',
    description:
        'مصباح ليد بإضاءة أوضح واستهلاك أقل للبطارية، مقاوم للماء والغبار.',
    price: 120,
    category: SparePartCategory.lighting,
    stock: StockStatus.available,
    compatibleBike: _bikeName,
  ),
  SparePart(
    id: 7,
    name: 'بطارية ١٢ فولت',
    description: 'بطارية جل بدون صيانة، تشغيل سريع حتى في الصباح البارد.',
    price: 180,
    category: SparePartCategory.batteries,
    stock: StockStatus.outOfStock,
    compatibleBike: _bikeName,
  ),
];

/// الصيانة وقطع الغيار: بحث وفلتر بالتصنيف، وكارت كل قطعة بيفتح تفاصيلها.
/// "أضف إلى الطلب" في الكارت بيتحول لعداد + و −
class SparePartsScreen extends StatefulWidget {
  const SparePartsScreen({super.key});

  @override
  State<SparePartsScreen> createState() => _SparePartsScreenState();
}

class _SparePartsScreenState extends State<SparePartsScreen> {
  /// null = الكل
  SparePartCategory? _category;
  String _query = '';

  List<SparePart> get _filteredParts {
    final query = _query.trim().toLowerCase();
    return [
      for (final part in _parts)
        if ((_category == null || part.category == _category) &&
            (query.isEmpty || part.name.toLowerCase().contains(query)))
          part,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final parts = _filteredParts;
    // على التابلت ٣ كروت في الصف
    final columns = context.responsiveValue(mobile: 2, tablet: 3);
    final rowsCount = (parts.length / columns).ceil();

    return BlocProvider.value(
      value: getIt<CartCubit>(),
      child: DismissKeyboardWrapper(
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 12.w, 0),
                  child: ResponsiveCenter(
                    child: CustomBackHeader(
                      title: 'spareParts.title'.tr(),
                      trailing: const CartButton(),
                    ),
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
                        sliver: SliverToBoxAdapter(
                          child: ResponsiveCenter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                CustomSearchWidget(
                                  filled: true,
                                  hintText: 'spareParts.searchHint'.tr(),
                                  onChanged: (value) =>
                                      setState(() => _query = value),
                                ),
                                Gaps.v(14.h),
                                _CategoryFilter(
                                  selected: _category,
                                  onSelected: (category) =>
                                      setState(() => _category = category),
                                ),
                                Gaps.v(20.h),
                                RowWidget(
                                  title: 'spareParts.pickedForYourBike'.tr(),
                                  trailing: Text(
                                    'spareParts.productsCount'.plural(
                                      parts.length,
                                      args: [
                                        context.formatNumber(parts.length),
                                      ],
                                    ),
                                    style: context.textTheme.labelMedium
                                        ?.copyWith(
                                          color: colors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // الـ padding اللي تحت فيه ارتفاع الـ bottom nav، فآخر
                      // كارت مايستخباش وراه
                      SliverPadding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          20.w,
                          0,
                          20.w,
                          MediaQuery.paddingOf(context).bottom + 24.h,
                        ),
                        sliver: parts.isEmpty
                            ? const SliverToBoxAdapter(child: _NoResults())
                            : SliverList.separated(
                                itemCount: rowsCount,
                                separatorBuilder: (_, _) => Gaps.v(12.h),
                                itemBuilder: (context, row) => ResponsiveCenter(
                                  child: _PartsRow(
                                    parts: parts
                                        .skip(row * columns)
                                        .take(columns)
                                        .toList(),
                                    columns: columns,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "الكل" والتصنيفات، والمختار بالرمادي الغامق
class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter({required this.selected, required this.onSelected});

  final SparePartCategory? selected;
  final ValueChanged<SparePartCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 8.h,
      children: [
        CustomChoiceChip(
          label: 'spareParts.all'.tr(),
          isSelected: selected == null,
          onTap: () => onSelected(null),
        ),
        for (final category in SparePartCategory.values)
          CustomChoiceChip(
            label: category.labelKey.tr(),
            isSelected: selected == category,
            onTap: () => onSelected(category),
          ),
      ],
    );
  }
}

/// صف كروت، والصف الأخير الناقص بيكمل بمكان فاضي عشان الكروت تفضل بنفس العرض
class _PartsRow extends StatelessWidget {
  const _PartsRow({required this.parts, required this.columns});

  final List<SparePart> parts;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < columns; i++) ...[
          if (i > 0) Gaps.h(12.w),
          Expanded(
            child: i < parts.length
                ? _PartCard(part: parts[i])
                : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }
}

class _PartCard extends StatelessWidget {
  const _PartCard({required this.part});

  final SparePart part;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = context.textTheme;

    return Material(
      color: colors.bgSecondary,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: () => context.push(AppRouter.sparePartDetails, extra: part),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 7 / 4,
              child: SparePartImage(
                source: part.images.firstOrNull,
                category: part.category,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    part.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.labelLarge?.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.formatPrice(part.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Gaps.h(6.w),
                      Text(
                        part.stock.labelKey.tr(),
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10.sp,
                          color: part.stock.color(colors),
                        ),
                      ),
                    ],
                  ),
                  Gaps.v(8.h),
                  _OrderControl(part: part),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "أضف إلى الطلب" بيتحول لعداد أول ما القطعة تدخل الطلب، ولما الكمية ترجع
/// صفر بيرجع زي ما كان
class _OrderControl extends StatelessWidget {
  const _OrderControl({required this.part});

  final SparePart part;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cart = context.read<CartCubit>();
    final quantity = context.select(
      (CartCubit cart) => cart.quantityOf(part.id),
    );
    final height = 32.h;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: quantity == 0
          ? CustomButton(
              key: const ValueKey('add'),
              title: 'spareParts.addToOrder'.tr(),
              onPressed: part.stock.canOrder
                  ? () => cart.increment(part)
                  : null,
              height: height,
              borderRadius: 10.r,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              backgroundColor: colors.primaryContainer,
              textColor: colors.primary,
              fontSize: 11.sp,
              iconAtEnd: true,
              icon: Icon(Icons.add_rounded, color: colors.primary, size: 16.r),
            )
          : CustomQuantityStepper(
              key: const ValueKey('stepper'),
              quantity: quantity,
              onIncrement: () => cart.increment(part),
              onDecrement: () => cart.decrement(part),
              style: QuantityStepperStyle.filled,
              height: height,
            ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: colors.textHint, size: 48.r),
          Gaps.v(12.h),
          Text(
            'spareParts.noResults'.tr(),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
