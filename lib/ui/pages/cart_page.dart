import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../logic/blocs/cart/cart_bloc.dart';
import '../../../logic/blocs/cart/cart_state.dart';
import '../../../logic/blocs/cart/cart_event.dart';
import '../../../data/models/cart_item.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = context.read<CartBloc>().state;

      if (currentState is CartCheckoutSuccess) {
        context.read<CartBloc>().add(const ResetCartStateEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartCheckoutSuccess) {
          context.goNamed('checkout-success');
        }

        if (state is CartError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Something went wrong'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Try again',
                textColor: Colors.white,
                onPressed: () {
                  final currentState = context.read<CartBloc>().state;
                  if (currentState is CartLoaded &&
                      currentState.items.isNotEmpty) {
                    context.read<CartBloc>().add(const CheckoutEvent());
                  }
                },
              ),
            ),
          );
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartCheckoutSuccess) {
            return _buildEmptyCart(context);
          }

          if (state is CartError) {
            final cartBloc = context.read<CartBloc>();

            final CartState previousState = cartBloc.state;

            if (previousState is CartLoaded) {
              return previousState.items.isEmpty
                  ? _buildEmptyCart(context)
                  : _buildCartList(context, previousState);
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Cart'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'เกิดข้อผิดพลาด',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CartBloc>().add(const CheckoutEvent());
                      },
                      child: const Text('ลองอีกครั้ง'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is CartLoaded) {
            return state.items.isEmpty
                ? _buildEmptyCart(context)
                : _buildCartList(context, state);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Empty Cart',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.go('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(101, 85, 143, 1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Go to shopping',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartList(BuildContext context, CartLoaded state) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
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
    return Dismissible(
      key: Key(item.product.id.toString()),
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE94235),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        alignment: Alignment.centerRight,
        child: const Padding(
          padding: EdgeInsets.only(right: 20),
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove Item'),
            content: Text(
                'Are you sure you want to remove ${item.product.name} from your cart?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<CartBloc>().add(
              UpdateCartItemQuantityEvent(
                item,
                0,
              ),
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.product.name} removed from cart'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                context.read<CartBloc>().add(
                      UpdateCartItemQuantityEvent(
                        item,
                        1,
                      ),
                    );
              },
            ),
          ),
        );
      },
      child: Container(
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
                borderRadius: BorderRadius.circular(12),
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
                      color: Color.fromRGBO(33, 0, 93, 1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        item.product.price.toStringAsFixed(2),
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
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color.fromRGBO(101, 85, 143, 1),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.remove, size: 16, color: Colors.white),
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
                  backgroundColor: const Color.fromRGBO(101, 85, 143, 1),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.add, size: 16, color: Colors.white),
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
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, CartLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(232, 222, 248, 1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(79, 55, 138, 1),
                  ),
                ),
                Text(
                  '${(state.total + state.totalDiscount).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(79, 55, 138, 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Promotion discount',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(79, 55, 138, 1),
                  ),
                ),
                Text(
                  '-${state.totalDiscount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.red[800],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '${state.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(79, 55, 138, 1),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: state.items.isNotEmpty
                      ? () {
                          _showCheckoutDialog(context);

                          context.read<CartBloc>().add(const CheckoutEvent());
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color.fromRGBO(101, 85, 143, 1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocListener<CartBloc, CartState>(
          listener: (context, state) {
            if (state is CartCheckoutSuccess || state is CartError) {
              Navigator.of(dialogContext).pop();

              if (state is CartError) {
                _showErrorDialog(context, state.message);
              }
            }
          },
          child: AlertDialog(
            title: const Text('Payment processing'),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Please wait...',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Something went wrong'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Try again',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();

              context.read<CartBloc>().add(const CheckoutEvent());
            },
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
