import 'package:go_biky/feature/spare_parts/spare_part.dart';

/// قطعة في الطلب بكميتها
class CartItem {
  const CartItem({required this.part, required this.quantity});

  final SparePart part;
  final int quantity;

  num get total => part.price * quantity;
}
