import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freshket_shopping_app/logic/blocs/cart/cart_bloc.dart';
import 'package:freshket_shopping_app/logic/blocs/cart/cart_event.dart';
import 'package:freshket_shopping_app/logic/blocs/recommend_product/recommended_product_bloc.dart';
import 'package:freshket_shopping_app/logic/blocs/recommend_product/recommended_product_event.dart';
import 'package:freshket_shopping_app/logic/blocs/recommend_product/recommended_product_state.dart';
import 'package:freshket_shopping_app/logic/blocs/latest_product/latest_product_bloc.dart';
import 'package:freshket_shopping_app/logic/blocs/latest_product/latest_product_event.dart';
import 'package:freshket_shopping_app/logic/blocs/latest_product/latest_product_state.dart';
import 'package:freshket_shopping_app/data/models/product.dart';
import 'package:freshket_shopping_app/ui/widget/common/bottom_loading_indicator.dart';
import 'package:freshket_shopping_app/ui/widget/common/product_shimmer_item.dart';
import 'package:freshket_shopping_app/ui/widget/common/product_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    context.read<RecommendedProductBloc>().add(FetchRecommendedProductsEvent());
    context.read<LatestProductBloc>().add(FetchLatestProductsEvent());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    context.read<RecommendedProductBloc>().add(FetchRecommendedProductsEvent());
    context.read<LatestProductBloc>().add(RefreshLatestProductsEvent());

    context.read<CartBloc>().add(const ClearCartEvent());

    return await Future.delayed(const Duration(milliseconds: 1500));
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    final latestProductState = context.read<LatestProductBloc>().state;

    if (latestProductState is LatestProductLoaded &&
        latestProductState.products.length >= 20 &&
        !latestProductState.hasReachedMax &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      setState(() {
        _isLoadingMore = true;
      });

      context.read<LatestProductBloc>().add(LoadMoreLatestProductsEvent());

      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Theme.of(context).primaryColor,
      child: ListView(
        controller: _scrollController,
        children: [
          _buildRecommendedProductsSection(),
          _buildLatestProductsSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRecommendedProductsSection() {
    return BlocBuilder<RecommendedProductBloc, RecommendedProductState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Recommend Product',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (state is RecommendedProductInitial ||
                state is RecommendedProductLoading)
              const SimpleProductShimmer(itemCount: 4)
            else if (state is RecommendedProductLoaded)
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.recommendedProducts.length,
                itemBuilder: (context, index) {
                  return ProductListItem(
                    product: state.recommendedProducts[index],
                  );
                },
              )
            else if (state is RecommendedProductError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text('Something went wrong'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<RecommendedProductBloc>()
                              .add(FetchRecommendedProductsEvent());
                        },
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLatestProductsSection() {
    return BlocBuilder<LatestProductBloc, LatestProductState>(
      builder: (context, state) {
        List<Product> products = [];
        bool isLoading = false;

        if (state is LatestProductLoaded) {
          products = state.products;
        } else if (state is LatestProductLoading) {
          products = state.products;
          isLoading = true;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Latest Products',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if ((state is LatestProductInitial ||
                (state is LatestProductLoading && products.isEmpty)))
              const SimpleProductShimmer(itemCount: 6)
            else if (products.isNotEmpty)
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductListItem(
                    product: products[index],
                  );
                },
              )
            else if (state is LatestProductError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text('Something went wrong'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<LatestProductBloc>()
                              .add(FetchLatestProductsEvent());
                        },
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                ),
              ),
            if (isLoading && products.isNotEmpty)
              const BottomLoadingIndicator(),
          ],
        );
      },
    );
  }
}
