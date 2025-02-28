import 'package:equatable/equatable.dart';
import 'product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity.toDouble();

  @override
  List<Object?> get props => [product, quantity];
}
