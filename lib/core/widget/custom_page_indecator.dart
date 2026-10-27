import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_biky/core/extensions/context_extension.dart';

/// نقط الصفحات (السلايدر والـ onboarding)، النقطة النشطة بتطول وبتاخد لون البراند
class CustomPageIndicator extends StatelessWidget {
  final int currentIndex;
  final int itemCount;
  final double? dotSize;
  final double? activeDotWidth;
  final double? spacing;
  final Color? activeColor;
  final Color? inactiveColor;

  const CustomPageIndicator({
    super.key,
    required this.currentIndex,
    required this.itemCount,
    this.dotSize,
    this.activeDotWidth,
    this.spacing,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final size = dotSize ?? 8.r;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? activeDotWidth ?? 32.w : size,
          height: size,
          margin: EdgeInsets.symmetric(horizontal: (spacing ?? 12.w) / 2),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor ?? colors.primary
                : (inactiveColor ?? colors.textHint).withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(size),
          ),
        );
      }),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double dashWidth = 4;
    const double dashSpace = 2;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DottedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}
