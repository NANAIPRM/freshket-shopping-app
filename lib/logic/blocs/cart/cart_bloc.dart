import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freshket_shopping_app/data/services/api_service.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../../../data/models/cart_item.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final ApiService _apiService;
  CartBloc({required ApiService apiService})
      : _apiService = apiService,
        super(const CartLoaded(items: [], total: 0.0, totalDiscount: 0.0)) {
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateCartItemQuantityEvent>(_onUpdateCartItemQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<CheckoutEvent>(_onCheckout);
  }

  void _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is! CartLoaded) return;

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

    final calculationResult = _calculateTotalWithPromotion(updatedItems);

    emit(CartLoaded(
      items: updatedItems,
      total: calculationResult.total,
      totalDiscount: calculationResult.discount,
    ));
  }

  void _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is! CartLoaded) return;

    final currentState = state as CartLoaded;

    // Find the item to remove
    final updatedItems = currentState.items
        .where((item) =>
            item.product.id != event.item.product.id ||
            item.quantity > event.item.quantity)
        .map((item) => item.product.id == event.item.product.id
            ? CartItem(
                product: item.product,
                quantity: item.quantity - event.item.quantity)
            : item)
        .toList();

    final calculationResult = _calculateTotalWithPromotion(updatedItems);

    emit(CartLoaded(
      items: updatedItems,
      total: calculationResult.total,
      totalDiscount: calculationResult.discount,
    ));
  }

  void _onUpdateCartItemQuantity(
    UpdateCartItemQuantityEvent event,
    Emitter<CartState> emit,
  ) {
    if (state is! CartLoaded) return;

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

      final calculationResult = _calculateTotalWithPromotion(updatedItems);

      emit(CartLoaded(
        items: updatedItems,
        total: calculationResult.total,
        totalDiscount: calculationResult.discount,
      ));
    }
  }

  void _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) {
    emit(const CartLoaded(items: [], total: 0.0, totalDiscount: 0.0));
  }

  CalculationResult _calculateTotalWithPromotion(List<CartItem> items) {
    // Group items by product
    final groupedItems = <dynamic, List<CartItem>>{};
    for (var item in items) {
      groupedItems.putIfAbsent(item.product.id, () => []).add(item);
    }

    double totalDiscount = 0.0;
    double total = 0.0;

    // Calculate discount and total for each product group
    for (var group in groupedItems.values) {
      final productPrice = group.first.product.price;
      final totalQuantity = group.fold(0, (sum, item) => sum + item.quantity);

      // Calculate pairs and remaining items
      final pairs = totalQuantity ~/ 2;
      final remainingItems = totalQuantity % 2;

      // Calculate discounted pairs
      final pairsTotal = pairs * (productPrice * 2);
      final pairsDiscount = pairsTotal * 0.05;

      // Calculate remaining items
      final remainingItemsTotal = remainingItems * productPrice;

      // Sum up total and discount
      total += pairsTotal - pairsDiscount + remainingItemsTotal;
      totalDiscount += pairsDiscount;
    }

    return CalculationResult(total: total, discount: totalDiscount);
  }

  void _onCheckout(CheckoutEvent event, Emitter<CartState> emit) async {
    if (state is! CartLoaded) return;

    final currentState = state as CartLoaded;

    try {
      // Convert cart items to product IDs
      final productIds =
          currentState.items.map((item) => item.product.id).toList();

      // Call the checkout method in ApiService
      await _apiService.checkout(productIds);

      // Clear the cart after successful checkout
      emit(const CartLoaded(items: [], total: 0.0, totalDiscount: 0.0));

      // Emit success state to trigger navigation
      emit(const CartCheckoutSuccess());
    } catch (e) {
      // Handle checkout error
      emit(CartError('ไม่สามารถชำระเงินได้: $e'));
    }
  }
}

class CalculationResult {
  final double total;
  final double discount;

  const CalculationResult({required this.total, required this.discount});
}
