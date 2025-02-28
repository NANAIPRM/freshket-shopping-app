import 'package:equatable/equatable.dart';
import '../../../data/models/product.dart';

abstract class RecommendedProductState extends Equatable {
  const RecommendedProductState();

  @override
  List<Object?> get props => [];
}

class RecommendedProductInitial extends RecommendedProductState {}

class RecommendedProductLoading extends RecommendedProductState {}

class RecommendedProductLoaded extends RecommendedProductState {
  final List<Product> recommendedProducts;

  const RecommendedProductLoaded(this.recommendedProducts);

  @override
  List<Object?> get props => [recommendedProducts];
}

class RecommendedProductError extends RecommendedProductState {
  final String message;

  const RecommendedProductError(this.message);

  @override
  List<Object?> get props => [message];
}
