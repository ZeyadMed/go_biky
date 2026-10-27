import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/widget/custom_shimmer_widget.dart';
import 'package:go_biky/core/widget/loading_shimmer.dart';
import 'package:go_biky/core/widget/stateless/gaps.dart';

/// skeleton لشاشة كاملة فيها بحث وعنوان وقايمة. لازم ياخد ارتفاع محدد
/// (body الـ Scaffold أو Expanded) عشان القايمة جواه Expanded
class ShimmerSkeleton extends StatelessWidget {
  const ShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // search box skeleton
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: ShimmerBox(
              height: 48.h,
              width: double.infinity,
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: ShimmerBox(width: 140.w, height: 20.h),
          ),
          Gaps.v(10.h),
          // list skeletons
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              itemBuilder: (_, _) => Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                child: Row(
                  children: [
                    ShimmerBox(width: 40.r, height: 40.r),
                    Gaps.h(16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(height: 12.h, width: double.infinity),
                          Gaps.v(8.h),
                          ShimmerBox(height: 12.h, width: 150.w),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemCount: 6,
            ),
          ),
        ],
      ),
    );
  }
}
