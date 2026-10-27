import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';
import 'package:go_biky/core/widget/custom_shimmer_widget.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// مستطيل الـ skeleton. مابيلمعش لوحده: بيتحط جوه AppShimmer أو جوه
/// واحد من الـ shimmers اللي تحت عشان كل الشاشة تلمع مع بعض
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final bool isCircle;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.appColors.border,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle
            ? null
            : borderRadius ?? BorderRadius.circular(6.r),
      ),
    );
  }
}

/// skeleton لقايمة: صورة (مربعة أو دايرة) + سطرين في كل عنصر
class ListShimmer extends StatelessWidget {
  final int itemCount;
  final bool circleImage;

  const ListShimmer({super.key, this.itemCount = 6, this.circleImage = false});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: itemCount,
        separatorBuilder: (_, _) => Gaps.v(16.h),
        itemBuilder: (_, _) => Row(
          children: [
            ShimmerBox(
              height: 60.r,
              width: 60.r,
              isCircle: circleImage,
              borderRadius: BorderRadius.circular(10.r),
            ),
            Gaps.h(16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 16.h, width: double.infinity),
                  Gaps.v(8.h),
                  ShimmerBox(height: 14.h, width: 150.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// skeleton لجريد كروت (زي قطع الغيار): صورة + اسم + سعر.
/// عدد الأعمدة 2 على الموبايل و 3 على التابلت لو `crossAxisCount` مش متبعت
class GridShimmer extends StatelessWidget {
  final int itemCount;
  final int? crossAxisCount;

  const GridShimmer({super.key, this.itemCount = 6, this.crossAxisCount});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              crossAxisCount ?? context.responsiveValue(mobile: 2, tablet: 3),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (_, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ShimmerBox(
                height: double.infinity,
                width: double.infinity,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            Gaps.v(8.h),
            ShimmerBox(height: 14.h, width: double.infinity),
            Gaps.v(6.h),
            ShimmerBox(height: 14.h, width: 60.w),
          ],
        ),
      ),
    );
  }
}

/// skeleton لصفحة تفاصيل: صورة كبيرة + عنوان + فقرات
class DetailsShimmer extends StatelessWidget {
  const DetailsShimmer({super.key});

  Widget _section() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(height: 18.h, width: 120.w),
        Gaps.v(12.h),
        ShimmerBox(height: 14.h, width: double.infinity),
        Gaps.v(6.h),
        ShimmerBox(height: 14.h, width: double.infinity),
        Gaps.v(6.h),
        ShimmerBox(height: 14.h, width: 220.w),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
              height: 200.h,
              width: double.infinity,
              borderRadius: BorderRadius.circular(16.r),
            ),
            Gaps.v(20.h),
            ShimmerBox(height: 20.h, width: 180.w),
            Gaps.v(10.h),
            ShimmerBox(height: 16.h, width: 100.w),
            Gaps.v(24.h),
            _section(),
            Gaps.v(20.h),
            _section(),
            Gaps.v(20.h),
            _section(),
          ],
        ),
      ),
    );
  }
}
