import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_biky/feature/spare_parts/cart_item.dart';
import 'package:go_biky/feature/spare_parts/spare_part.dart';

/// القطع اللي في الطلب بترتيب إضافتها، والـ key رقم القطعة. متسجل singleton
/// في get_it عشان كارت القطعة وصفحة التفاصيل والسلة يشوفوا نفس الكميات
class CartCubit extends Cubit<Map<int, CartItem>> {
  CartCubit() : super(const {});

  List<CartItem> get items => state.values.toList();

  int quantityOf(int partId) => state[partId]?.quantity ?? 0;

  /// عدد الوحدات كلها، للرقم اللي على أيقونة السلة
  int get totalCount => state.values.fold(0, (sum, item) => sum + item.quantity);

  num get totalPrice =>
      state.values.fold<num>(0, (sum, item) => sum + item.total);

  void increment(SparePart part) =>
      setQuantity(part, quantityOf(part.id) + 1);

  void decrement(SparePart part) =>
      setQuantity(part, quantityOf(part.id) - 1);

  void remove(SparePart part) => setQuantity(part, 0);

  void clear() => emit(const {});

  /// لو الكمية صفر القطعة بتتشال من الطلب
  void setQuantity(SparePart part, int quantity) {
    final cart = Map.of(state);
    if (quantity > 0) {
      cart[part.id] = CartItem(part: part, quantity: quantity);
    } else {
      cart.remove(part.id);
    }
    emit(Map.unmodifiable(cart));
  }
}
