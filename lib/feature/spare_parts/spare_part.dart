import 'package:flutter/material.dart';
import 'package:go_biky/core/theme/app_theme_colors.dart';

/// تصنيفات القطع بنفس ترتيبها في الفلتر
enum SparePartCategory {
  oils('spareParts.oils', Icons.oil_barrel_outlined),
  brakes('spareParts.brakes', Icons.album_outlined),
  tires('spareParts.tires', Icons.tire_repair_outlined),
  chains('spareParts.chains', Icons.link_rounded),
  filters('spareParts.filters', Icons.filter_alt_outlined),
  lighting('spareParts.lighting', Icons.lightbulb_outline_rounded),
  batteries('spareParts.batteries', Icons.battery_charging_full_rounded);

  const SparePartCategory(this.labelKey, this.icon);

  final String labelKey;

  /// بتظهر مكان صورة القطعة لو مش موجودة
  final IconData icon;
}

/// توفر القطعة، واللي مش متوفرة مابتتضافش للطلب
enum StockStatus {
  available('spareParts.available', 'spareParts.inWarehouse'),
  limited('spareParts.limited', 'spareParts.limited'),
  outOfStock('spareParts.outOfStock', 'spareParts.currentlyUnavailable');

  const StockStatus(this.labelKey, this.detailsLabelKey);

  /// النص اللي في كارت القطعة
  final String labelKey;

  /// النص اللي في صفحة التفاصيل
  final String detailsLabelKey;

  bool get canOrder => this != StockStatus.outOfStock;

  Color color(AppThemeColors colors) => switch (this) {
    StockStatus.available => colors.success,
    StockStatus.limited => colors.warning,
    StockStatus.outOfStock => colors.error,
  };

  Color containerColor(AppThemeColors colors) => switch (this) {
    StockStatus.available => colors.successContainer,
    StockStatus.limited => colors.warningContainer,
    StockStatus.outOfStock => colors.errorContainer,
  };
}

class SparePart {
  const SparePart({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    this.images = const [],
    this.compatibleBike,
  });

  final int id;
  final String name;
  final String description;

  /// بالريال وشامل الضريبة
  final num price;
  final SparePartCategory category;
  final StockStatus stock;

  /// لينكات الصور، وأول واحدة هي اللي في الكارت
  final List<String> images;

  /// اسم دراجة الراكب لو القطعة متوافقة معاها
  final String? compatibleBike;
}
