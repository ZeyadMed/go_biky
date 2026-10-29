import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// بيحط المحتوى في النص بعرض أقصى، عشان الفورم والمحتوى الأساسي
/// مايتمطش على عرض التابلت. على الموبايل مالوش أي تأثير
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({super.key, required this.child, this.maxWidth});

  final Widget child;

  /// لو مش متبعت بياخد 520.w
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 520.w),
        child: child,
      ),
    );
  }
}

/// نفس [ResponsiveCenter] بس لـ sliver جوه `CustomScrollView`، عشان
/// اللستات الطويلة تتبني lazy (اللي ظاهر بس) وهي في النص بنفس العرض الأقصى
class SliverResponsiveCenter extends StatelessWidget {
  const SliverResponsiveCenter({
    super.key,
    required this.sliver,
    this.maxWidth,
  });

  final Widget sliver;

  /// لو مش متبعت بياخد 520.w
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final side = (constraints.crossAxisExtent - (maxWidth ?? 520.w)) / 2;
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: side > 0 ? side : 0),
          sliver: sliver,
        );
      },
    );
  }
}
