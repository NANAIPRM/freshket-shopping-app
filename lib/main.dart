import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freshket_shopping_app/ui/pages/checkout_success_page.dart';
import 'package:go_router/go_router.dart';
import 'package:freshket_shopping_app/data/services/api_service.dart';
import 'package:freshket_shopping_app/logic/blocs/recommend_product/recommended_product_bloc.dart';
import 'package:freshket_shopping_app/logic/blocs/latest_product/latest_product_bloc.dart';
import 'package:freshket_shopping_app/logic/blocs/cart/cart_bloc.dart';
import 'package:freshket_shopping_app/ui/pages/cart_page.dart';
import 'package:freshket_shopping_app/ui/pages/home_page.dart';
import 'package:freshket_shopping_app/ui/widget/common/custom_bottom_navigation_bar.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return RootLayout(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) {
                return const HomePage();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cart',
              name: 'cart',
              builder: (context, state) {
                return const CartPage();
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/checkout-success',
      name: 'checkout-success',
      builder: (context, state) {
        return const CheckoutSuccessPage();
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var apiService = ApiService();
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecommendedProductBloc>(
          create: (context) => RecommendedProductBloc(apiService: apiService),
        ),
        BlocProvider<LatestProductBloc>(
          create: (context) => LatestProductBloc(apiService: apiService),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc(apiService: apiService),
        ),
      ],
      child: MaterialApp.router(
        title: 'Freshket Shopping App',
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.deepPurple,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            primary: Colors.deepPurple,
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}

class RootLayout extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const RootLayout({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final int currentIndex = navigationShell.currentIndex;

    final String location = GoRouterState.of(context).matchedLocation;
    final bool isCheckoutSuccess = location.startsWith('/checkout-success');

    return Scaffold(
      appBar: (currentIndex == 0 && !isCheckoutSuccess)
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('Freshket Shopping App'),
            )
          : null,
      body: navigationShell,
      bottomNavigationBar: isCheckoutSuccess
          ? null
          : CustomBottomNavigationBar(
              selectedIndex: currentIndex,
              onTap: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation: index == currentIndex,
                );
              },
            ),
    );
  }
}
