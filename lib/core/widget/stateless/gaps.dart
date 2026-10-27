import 'package:flutter/widgets.dart';

/// المسافات بين العناصر، والقيمة بتتبعت بالـ extension: `Gaps.v(12.h)` / `Gaps.h(8.w)`
abstract final class Gaps {
  static SizedBox v(double value) => SizedBox(height: value);

  static SizedBox h(double value) => SizedBox(width: value);

  static SizedBox square(double size) => SizedBox.square(dimension: size);
}
