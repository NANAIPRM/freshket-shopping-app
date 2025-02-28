import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/product.dart';
import '../../../../data/models/cart_item.dart';
import '../../../../logic/blocs/cart/cart_bloc.dart';
import '../../../../logic/blocs/cart/cart_event.dart';
import '../../../../logic/blocs/cart/cart_state.dart';

class ProductListItem extends StatelessWidget {
  final Product product;

  const ProductListItem({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.topLeft,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://s3-alpha-sig.figma.com/img/cfe7/5363/3a073c55eeee417a70d9d8af308497c4?Expires=1741564800&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=IRdZpp9f56FyveknggxK45IblJpiluA9Dv62nG0z7Ss8TgjWoTr2J4dSZKNJzIUazFpGKxUIsVBlxLc4MwD2UvpE9~pKcXOQ0jdNB8tloTA2I9UjqodqxfMS~I8OGv6wUcq4tOjie99uNRp3footBeCJZh86xapFD9x81GMaq1waiJ8SqTy8z0gz1VjO6KvyNz9QzEMpv7UvDT23MJTq5RDzxjANFEabNI1xpWuC8ZIPLVy6LbjbLYMRknXTITr586LD2tsVZpH-7Bgj-SruTu7fQ7BSYWq2Ie1gDEO9yIS4lUS4wAsNsLr0UZZc0gC2PHLqguQgrx5XBIaP~Td35w__',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color.fromRGBO(33, 0, 93, 1)),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      product.price.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(79, 55, 139, 1),
                      ),
                    ),
                    const Text(
                      ' / unit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded) {
                final cartItem = state.items.firstWhere(
                  (item) => item.product.id == product.id,
                  orElse: () => CartItem(product: product, quantity: 0),
                );

                if (cartItem.quantity > 0) {
                  return _buildQuantityControls(context, cartItem);
                }
              }

              return _buildAddToCartButton(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        context.read<CartBloc>().add(AddToCartEvent(product));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color.fromRGBO(101, 85, 143, 1),
        foregroundColor: Colors.white,
      ),
      child: const Text("Add to cart"),
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartItem cartItem) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color.fromRGBO(101, 85, 143, 1),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.remove,
              size: 16,
              color: Colors.white,
            ),
            onPressed: () {
              context.read<CartBloc>().add(
                    UpdateCartItemQuantityEvent(
                      cartItem,
                      cartItem.quantity - 1,
                    ),
                  );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '${cartItem.quantity}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color.fromRGBO(101, 85, 143, 1),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.add, size: 16, color: Colors.white),
            onPressed: () {
              context.read<CartBloc>().add(
                    UpdateCartItemQuantityEvent(
                      cartItem,
                      cartItem.quantity + 1,
                    ),
                  );
            },
          ),
        ),
      ],
    );
  }
}
