import 'package:equatable/equatable.dart';
import '../../../data/models/cart_item.dart';
import '../../../data/models/product.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCartEvent extends CartEvent {
  final Product product;

  const AddToCartEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveFromCartEvent extends CartEvent {
  final CartItem item;

  const RemoveFromCartEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateCartItemQuantityEvent extends CartEvent {
  final CartItem item;
  final int quantity;

  const UpdateCartItemQuantityEvent(this.item, this.quantity);

  @override
  List<Object?> get props => [item, quantity];
}
