import 'package:flutter/material.dart';
import 'package:go_biky/core/theme/app_theme_colors.dart';
import 'package:go_biky/feature/spare_parts/cart_item.dart';

/// مراحل الطلب بنفس ترتيبها في شريط التتبع
enum OrderStatus {
  sent('orders.statusSent', 'orderDetails.sentHint'),
  underReview('orders.statusUnderReview', 'orderDetails.underReviewHint'),
  readyForPickup('orders.statusReady', 'orderDetails.readyHint'),
  delivered('orders.statusDelivered', 'orderDetails.deliveredHint');

  const OrderStatus(this.labelKey, this.hintKey);

  final String labelKey;

  /// وصف المرحلة في رحلة الطلب لما مايبقاش ليها تاريخ
  final String hintKey;

  bool get isCompleted => this == OrderStatus.delivered;

  Color color(AppThemeColors colors) => switch (this) {
    OrderStatus.sent => colors.primary,
    OrderStatus.underReview => colors.warning,
    OrderStatus.readyForPickup || OrderStatus.delivered => colors.success,
  };

  Color containerColor(AppThemeColors colors) => switch (this) {
    OrderStatus.sent => colors.primaryContainer,
    OrderStatus.underReview => colors.warningContainer,
    OrderStatus.readyForPickup ||
    OrderStatus.delivered => colors.successContainer,
  };
}

/// طلب قطع اتبعت للمراجعة
class SparePartsOrder {
  const SparePartsOrder({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.pickupCenter,
    this.status = OrderStatus.sent,
    this.statusDates = const {},
    this.notes,
  });

  final int id;
  final DateTime createdAt;
  final List<CartItem> items;
  final String pickupCenter;
  final OrderStatus status;

  /// تاريخ وصول الطلب لكل مرحلة بعد الإرسال، والإرسال نفسه هو `createdAt`
  final Map<OrderStatus, DateTime> statusDates;

  DateTime? reachedAt(OrderStatus step) =>
      step == OrderStatus.sent ? createdAt : statusDates[step];

  /// ملاحظات الراكب على الطلب
  final String? notes;

  /// عدد الوحدات كلها، مش عدد القطع المختلفة
  int get unitsCount => items.fold(0, (sum, item) => sum + item.quantity);

  num get total => items.fold<num>(0, (sum, item) => sum + item.total);
}
