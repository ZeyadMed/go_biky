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
