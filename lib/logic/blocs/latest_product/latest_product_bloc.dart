import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/product.dart';
import '../../../data/services/api_service.dart';
import 'latest_product_event.dart';
import 'latest_product_state.dart';

class LatestProductBloc extends Bloc<LatestProductEvent, LatestProductState> {
  final ApiService _apiService;
  String? _nextCursor;
  List<Product> _currentProducts = [];
  bool _hasReachedMax = false;

  LatestProductBloc({required ApiService apiService})
      : _apiService = apiService,
        super(LatestProductInitial()) {
    on<FetchLatestProductsEvent>(_onFetchLatestProducts);
    on<LoadMoreLatestProductsEvent>(_onLoadMoreLatestProducts);
    on<RefreshLatestProductsEvent>(_onRefreshLatestProducts);
  }

  Future<void> _onFetchLatestProducts(
    FetchLatestProductsEvent event,
    Emitter<LatestProductState> emit,
  ) async {
    emit(LatestProductLoading(products: []));
    await _fetchProducts(emit);
  }

  Future<void> _onLoadMoreLatestProducts(
    LoadMoreLatestProductsEvent event,
    Emitter<LatestProductState> emit,
  ) async {
    if (_nextCursor == null || _hasReachedMax || _currentProducts.length < 20) {
      return;
    }

    emit(LatestProductLoading(products: _currentProducts));
    await _fetchMoreProducts(emit);
  }

  Future<void> _onRefreshLatestProducts(
    RefreshLatestProductsEvent event,
    Emitter<LatestProductState> emit,
  ) async {
    _nextCursor = null;
    _currentProducts = [];
    _hasReachedMax = false;

    emit(const LatestProductLoading(products: []));

    await _fetchProducts(emit);
  }

  Future<void> _fetchProducts(Emitter<LatestProductState> emit) async {
    try {
      final result = await _apiService.getProducts(limit: 20);
      _currentProducts = result.items;
      _nextCursor = result.nextCursor;
      _hasReachedMax = result.nextCursor == null;

      emit(LatestProductLoaded(
        products: _currentProducts,
        nextCursor: _nextCursor,
        hasReachedMax: _hasReachedMax,
      ));
    } catch (e) {
      emit(LatestProductError(e.toString()));
    }
  }

  Future<void> _fetchMoreProducts(Emitter<LatestProductState> emit) async {
    try {
      final result = await _apiService.getProducts(
        cursor: _nextCursor,
        limit: 20,
      );

      _currentProducts = [..._currentProducts, ...result.items];
      _nextCursor = result.nextCursor;
      _hasReachedMax = result.nextCursor == null;

      emit(LatestProductLoaded(
        products: _currentProducts,
        nextCursor: _nextCursor,
        hasReachedMax: _hasReachedMax,
      ));
    } catch (e) {
      emit(LatestProductError(e.toString()));
    }
  }
}
