import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          create: (context) => CartBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Freshket Shopping App',
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: Colors.purple,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            primary: Colors.purple,
          ),
        ),
        home: const MyHomePage(title: 'Freshket Shopping App'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: Text(widget.title),
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          HomePage(),
          CartPage(),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
