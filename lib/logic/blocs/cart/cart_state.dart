import 'package:equatable/equatable.dart';
import '../../../data/models/cart_item.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double total;

  const CartLoaded({
    required this.items,
    required this.total,
  });

  @override
  List<Object?> get props => [items, total];

  CartLoaded copyWith({
    List<CartItem>? items,
    double? total,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}
