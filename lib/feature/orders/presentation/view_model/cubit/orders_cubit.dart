import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_biky/feature/spare_parts/cart_item.dart';
import 'package:go_biky/feature/spare_parts/spare_part.dart';
import 'package:go_biky/feature/spare_parts/spare_parts_order.dart';

// TODO: الطلبات بتيجي من الـ API، والبيانات دي مؤقتة
const _pickupCenter = 'مدار • الياسمين';
final _tempOrders = [
  SparePartsOrder(
    id: 2036,
    createdAt: DateTime(2026, 10, 22, 9, 40),
    status: OrderStatus.readyForPickup,
    statusDates: {
      OrderStatus.underReview: DateTime(2026, 10, 22, 10, 5),
      OrderStatus.readyForPickup: DateTime(2026, 10, 23, 14, 30),
    },
    pickupCenter: _pickupCenter,
    items: const [
      CartItem(
        part: SparePart(
          id: 3,
          name: 'إطار خلفي رياضي',
          description: '',
          price: 220,
          category: SparePartCategory.tires,
          stock: StockStatus.available,
        ),
        quantity: 1,
      ),
    ],
  ),
  SparePartsOrder(
    id: 2019,
    createdAt: DateTime(2026, 10, 18, 13, 5),
    status: OrderStatus.underReview,
    statusDates: {OrderStatus.underReview: DateTime(2026, 10, 18, 13, 20)},
    notes: 'أفضّل الاستلام بعد العصر.',
    pickupCenter: _pickupCenter,
    items: const [
      CartItem(
        part: SparePart(
          id: 4,
          name: 'طقم سلسلة وتروس',
          description: '',
          price: 160,
          category: SparePartCategory.chains,
          stock: StockStatus.limited,
        ),
        quantity: 1,
      ),
    ],
  ),
  SparePartsOrder(
    id: 1987,
    createdAt: DateTime(2026, 10, 9, 17, 20),
    status: OrderStatus.delivered,
    statusDates: {
      OrderStatus.underReview: DateTime(2026, 10, 9, 18),
      OrderStatus.readyForPickup: DateTime(2026, 10, 10, 12, 15),
      OrderStatus.delivered: DateTime(2026, 10, 11, 16, 45),
    },
    pickupCenter: _pickupCenter,
    items: const [
      CartItem(
        part: SparePart(
          id: 1,
          name: 'زيت محرك ١٠ دبليو-٤٠',
          description: '',
          price: 45,
          category: SparePartCategory.oils,
          stock: StockStatus.available,
        ),
        quantity: 1,
      ),
    ],
  ),
];

/// طلبات القطع من الأحدث للأقدم. متسجل singleton في get_it عشان الطلب اللي
/// بيتبعت من السلة يظهر في طلباتي على طول
class OrdersCubit extends Cubit<List<SparePartsOrder>> {
  OrdersCubit() : super(List.unmodifiable(_tempOrders));

  // TODO: رقم الطلب بيرجع من الـ API
  int get nextTempId =>
      state.fold(2047, (id, order) => math.max(id, order.id)) + 1;

  /// الطلب الجديد بيبقى أول واحد
  void add(SparePartsOrder order) =>
      emit(List.unmodifiable([order, ...state]));
}
