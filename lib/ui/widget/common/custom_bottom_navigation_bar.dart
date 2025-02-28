import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freshket_shopping_app/logic/blocs/cart/cart_bloc.dart';
import 'package:freshket_shopping_app/logic/blocs/cart/cart_state.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Bottom navigation tabs
              Row(
                children: [
                  // Shopping tab
                  Expanded(
                    child: InkWell(
                      onTap: () => onTap(0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedIndex == 0
                              ? Color(
                                  0xFFF3E5F5) // Light purple background when selected
                              : Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.purple[800],
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Shopping',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.purple[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Cart tab with item count from CartBloc
                  Expanded(
                    child: InkWell(
                      onTap: () => onTap(1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedIndex == 1
                              ? Color(0xFFF3E5F5)
                              : Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.purple[800],
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            BlocBuilder<CartBloc, CartState>(
                              builder: (context, state) {
                                int itemCount = 0;
                                if (state is CartLoaded) {
                                  // Sum up the quantities of all items
                                  itemCount = state.items.fold(
                                    0,
                                    (sum, item) => sum + item.quantity,
                                  );
                                }

                                return Text(
                                  itemCount > 0 ? 'Cart ($itemCount)' : 'Cart',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.purple[800],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
