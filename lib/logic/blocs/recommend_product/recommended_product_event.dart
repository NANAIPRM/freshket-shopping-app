import 'package:equatable/equatable.dart';

abstract class RecommendedProductEvent extends Equatable {
  const RecommendedProductEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecommendedProductsEvent extends RecommendedProductEvent {}

class RefreshRecommendedProductsEvent extends RecommendedProductEvent {}
