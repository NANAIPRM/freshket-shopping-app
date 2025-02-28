import 'package:flutter_test/flutter_test.dart';
import 'package:freshket_shopping_app/data/models/product.dart';
import 'package:freshket_shopping_app/data/services/api_service.dart';
import 'package:freshket_shopping_app/logic/blocs/cart/cart_bloc.dart';
import 'package:freshket_shopping_app/logic/blocs/cart/cart_event.dart';
import 'package:freshket_shopping_app/logic/blocs/cart/cart_state.dart';

void main() {
  group('CartBloc', () {
    late CartBloc cartBloc;
    var apiService = ApiService();

    setUp(() {
      cartBloc = CartBloc(apiService: apiService);
    });

    tearDown(() {
      cartBloc.close();
    });

    test('Calculates total correctly with promotions', () async {
      final productA = const Product(id: 1, name: 'Product A', price: 200);
      final productB = const Product(id: 2, name: 'Product B', price: 150);
      final productC = const Product(id: 3, name: 'Product C', price: 100);

      cartBloc.add(AddToCartEvent(productA));
      cartBloc.add(AddToCartEvent(productA));
      cartBloc.add(AddToCartEvent(productA));
      cartBloc.add(AddToCartEvent(productB));
      cartBloc.add(AddToCartEvent(productB));
      cartBloc.add(AddToCartEvent(productB));
      cartBloc.add(AddToCartEvent(productB));
      cartBloc.add(AddToCartEvent(productC));

      await Future.delayed(Duration.zero);

      final state = cartBloc.state;
      print('State: $state');

      expect(state, isA<CartLoaded>());
      final loadedState = state as CartLoaded;

      expect(loadedState.total, 1250);
      expect(loadedState.totalDiscount, 50);

      print('Test passed!');
    });
  });
}
