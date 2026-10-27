import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/extensions.dart';
import 'package:go_biky/core/router/app_router.dart';
import 'package:go_biky/core/widget/widgets.dart';
import 'package:go_biky/feature/spare_parts/presentation/view_model/cubit/cart_cubit.dart';
import 'package:go_biky/feature/spare_parts/spare_part.dart';
import 'package:go_router/go_router.dart';

/// عدد القطع والوحدات بالشكل "قطعتان • ٣ وحدات"
String partsAndUnits(
  BuildContext context, {
  required int parts,
  required int units,
}) => [
  'partsOrder.partsCount'.plural(parts, args: [context.formatNumber(parts)]),
  'partsOrder.unitsCount'.plural(units, args: [context.formatNumber(units)]),
].join(' • ');

/// صورة القطعة، ولو مش موجودة بتظهر أيقونة التصنيف مكانها
class SparePartImage extends StatelessWidget {
  const SparePartImage({
    super.key,
    required this.source,
    required this.category,
    this.borderRadius,
    this.iconSize,
  });

  final String? source;
  final SparePartCategory category;
  final double? borderRadius;

  /// لو مش متبعت بياخد 32.r
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return FlexibleImage(
      source: source,
      borderRadius: borderRadius,
      placeholder: ColoredBox(
        color: colors.bgTertiary,
        child: Center(
          child: Icon(
            category.icon,
            color: colors.textHint,
            size: iconSize ?? 32.r,
          ),
        ),
      ),
    );
  }
}

/// أيقونة السلة في آخر الهيدر وعليها عدد القطع اللي في الطلب.
/// محتاجة `CartCubit` فوقها
class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final count = context.select((CartCubit cart) => cart.totalCount);

    return IconButton(
      onPressed: () => context.push(AppRouter.partsOrder),
      tooltip: 'spareParts.cart'.tr(),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(context.formatNumber(count)),
        backgroundColor: colors.primary,
        textColor: context.colorScheme.onPrimary,
        child: Icon(
          Icons.shopping_bag_outlined,
          color: colors.textPrimary,
          size: 26.r,
        ),
      ),
    );
  }
}
