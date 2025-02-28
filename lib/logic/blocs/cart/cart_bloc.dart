import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartLoaded(items: [], total: 0.0)) {
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity);
  }

  void _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final existingItemIndex = currentState.items
          .indexWhere((item) => item.product.id == event.product.id);

      List<CartItem> updatedItems = List.from(currentState.items);

      if (existingItemIndex >= 0) {
        final existingItem = updatedItems[existingItemIndex];
        updatedItems[existingItemIndex] = CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
        );
      } else {
        updatedItems.add(CartItem(
          product: event.product,
          quantity: 1,
        ));
      }

      double newTotal = _calculateTotal(updatedItems);

      emit(CartLoaded(
        items: updatedItems,
        total: newTotal,
      ));
    }
  }

  void _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final updatedItems = currentState.items
          .where((item) => item.product.id != event.item.product.id)
          .toList();

      double newTotal = _calculateTotal(updatedItems);

      emit(CartLoaded(
        items: updatedItems,
        total: newTotal,
      ));
    }
  }

  void _onUpdateCartItemQuantity(
    UpdateCartItemQuantityEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final itemIndex = currentState.items
          .indexWhere((item) => item.product.id == event.item.product.id);

      if (itemIndex >= 0) {
        List<CartItem> updatedItems = List.from(currentState.items);

        if (event.quantity <= 0) {
          updatedItems.removeAt(itemIndex);
        } else {
          updatedItems[itemIndex] = CartItem(
            product: event.item.product,
            quantity: event.quantity,
          );
        }

        double newTotal = _calculateTotal(updatedItems);

        emit(CartLoaded(
          items: updatedItems,
          total: newTotal,
        ));
      }
    }
  }

  double _calculateTotal(List<CartItem> items) {
    return items.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));
  }
}
