import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/product.dart';
import '../../../data/services/api_service.dart';
import 'recommended_product_event.dart';
import 'recommended_product_state.dart';

class RecommendedProductBloc
    extends Bloc<RecommendedProductEvent, RecommendedProductState> {
  final ApiService _apiService;

  RecommendedProductBloc({required ApiService apiService})
      : _apiService = apiService,
        super(RecommendedProductInitial()) {
    on<FetchRecommendedProductsEvent>(_onFetchRecommendedProducts);
    on<RefreshRecommendedProductsEvent>(_onRefreshRecommendedProducts);
  }

  Future<void> _onFetchRecommendedProducts(
    FetchRecommendedProductsEvent event,
    Emitter<RecommendedProductState> emit,
  ) async {
    emit(RecommendedProductLoading());
    await _fetchRecommendedProducts(emit);
  }

  Future<void> _onRefreshRecommendedProducts(
    RefreshRecommendedProductsEvent event,
    Emitter<RecommendedProductState> emit,
  ) async {
    await _fetchRecommendedProducts(emit);
  }

  Future<void> _fetchRecommendedProducts(
      Emitter<RecommendedProductState> emit) async {
    try {
      print('eiei');
      final List<Product> recommendedProducts =
          await _apiService.getRecommendedProducts();
      print(recommendedProducts);
      emit(RecommendedProductLoaded(recommendedProducts));
    } catch (e) {
      emit(RecommendedProductError(e.toString()));
    }
  }
}
