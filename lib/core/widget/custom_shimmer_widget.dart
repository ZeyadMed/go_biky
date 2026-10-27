import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:shimmer/shimmer.dart';

/// بيلف أي skeleton بالـ shimmer بألوان الثيم فبيبان سليم في الوضعين.
/// لون العناصر اللي جواه مش فارق (الشيمر بيلونها)، المهم تبقى مصمتة
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Shimmer.fromColors(
      baseColor: colors.border,
      highlightColor: colors.bgTertiary,
      direction: Directionality.of(context) == TextDirection.rtl
          ? ShimmerDirection.rtl
          : ShimmerDirection.ltr,
      child: child,
    );
  }
}

/// مستطيل أو دايرة بتلمع لوحدها، للـ placeholder الصغير (زي مكان صورة
/// لسه بتحمل). لو الأبعاد مش متبعتة: المستطيل 55.h بعرض كامل، والدايرة 20.r
class CustomShimmerWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final BoxShape shape;
  final double? borderRadius;

  const CustomShimmerWidget({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
  }) : shape = BoxShape.rectangle;

  const CustomShimmerWidget.circular({super.key, this.height, this.width})
    : shape = BoxShape.circle,
      borderRadius = null;

  @override
  Widget build(BuildContext context) {
    final isCircle = shape == BoxShape.circle;

    return AppShimmer(
      child: Container(
        height: height ?? (isCircle ? 20.r : 55.h),
        width: width ?? (isCircle ? 20.r : double.infinity),
        decoration: BoxDecoration(
          color: context.appColors.border,
          shape: shape,
          borderRadius: isCircle
              ? null
              : BorderRadius.circular(borderRadius ?? 10.r),
        ),
      ),
    );
  }
}
