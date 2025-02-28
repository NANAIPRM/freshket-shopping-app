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

// Define routes using GoRouter
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return RootLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: HomePage(),
            );
          },
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: CartPage(),
            );
          },
        ),
        GoRoute(
          path: '/checkout-success',
          name: 'checkout-success',
          pageBuilder: (context, state) {
            return NoTransitionPage(
              child: CheckoutSuccessPage(),
            );
          },
        ),
      ],
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

// Root layout that contains the bottom navigation bar
class RootLayout extends StatelessWidget {
  final Widget child;

  const RootLayout({super.key, required this.child});

  @override
  // In your RootLayout class
  @override
  Widget build(BuildContext context) {
    // Get the current route location
    final String location = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;

    // Determine which tab is currently active
    if (location.startsWith('/cart')) {
      currentIndex = 1;
    }

    // Check if we're on the success page
    final bool isSuccessPage = location.startsWith('/checkout-success');

    return Scaffold(
      appBar: (currentIndex == 0 && !isSuccessPage)
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('Freshket Shopping App'),
            )
          : null,
      body: child,
      bottomNavigationBar: isSuccessPage
          ? null
          : CustomBottomNavigationBar(
              selectedIndex: currentIndex,
              onTap: (index) {
                // Handle navigation with GoRouter
                switch (index) {
                  case 0:
                    context.goNamed('home');
                    break;
                  case 1:
                    context.goNamed('cart');
                    break;
                }
              },
            ),
    );
  }
}
