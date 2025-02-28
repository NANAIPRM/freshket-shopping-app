import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/blocs/cart/cart_bloc.dart';
import '../../../logic/blocs/cart/cart_state.dart';
import '../../../logic/blocs/cart/cart_event.dart';
import '../../../data/models/cart_item.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoaded) {
          return state.items.isEmpty
              ? _buildEmptyCart(context)
              : _buildCartList(context, state);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'ตะกร้าสินค้าว่างเปล่า',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8),
          Text(
            'เพิ่มสินค้าในหน้าแนะนำสินค้าเพื่อเริ่มการสั่งซื้อ',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, CartLoaded state) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                return _buildCartItem(context, state.items[index]);
              },
            ),
          ),
          _buildCheckoutSection(context, state),
        ],
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://s3-alpha-sig.figma.com/img/cfe7/5363/3a073c55eeee417a70d9d8af308497c4?Expires=1741564800&Key-Pair-Id=APKAQ4GOSFWCW27IBOMQ&Signature=IRdZpp9f56FyveknggxK45IblJpiluA9Dv62nG0z7Ss8TgjWoTr2J4dSZKNJzIUazFpGKxUIsVBlxLc4MwD2UvpE9~pKcXOQ0jdNB8tloTA2I9UjqodqxfMS~I8OGv6wUcq4tOjie99uNRp3footBeCJZh86xapFD9x81GMaq1waiJ8SqTy8z0gz1VjO6KvyNz9QzEMpv7UvDT23MJTq5RDzxjANFEabNI1xpWuC8ZIPLVy6LbjbLYMRknXTITr586LD2tsVZpH-7Bgj-SruTu7fQ7BSYWq2Ie1gDEO9yIS4lUS4wAsNsLr0UZZc0gC2PHLqguQgrx5XBIaP~Td35w__',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '฿${item.product.price.toStringAsFixed(2)} / unit',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.purple[100],
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.remove, size: 16, color: Colors.purple[800]),
                  onPressed: () {
                    context.read<CartBloc>().add(
                          UpdateCartItemQuantityEvent(
                            item,
                            item.quantity - 1,
                          ),
                        );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.purple[100],
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.add, size: 16, color: Colors.purple[800]),
                  onPressed: () {
                    context.read<CartBloc>().add(
                          UpdateCartItemQuantityEvent(
                            item,
                            item.quantity + 1,
                          ),
                        );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '฿${state.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 120,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
