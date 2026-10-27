import 'package:flutter/widgets.dart';
import 'package:go_biky/core/extensions/context_extension.dart';

/// لما الـ layout كله يختلف حسب الجهاز. `smallMobile` و`tablet` اختياريين
/// ولو مش موجودين بيعرض `mobile`
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.smallMobile,
    this.tablet,
  });

  final Widget mobile;
  final Widget? smallMobile;
  final Widget? tablet;

  @override
  Widget build(BuildContext context) {
    return context.responsiveValue(
      mobile: mobile,
      smallMobile: smallMobile,
      tablet: tablet,
    );
  }
}
