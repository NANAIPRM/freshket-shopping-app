import 'package:equatable/equatable.dart';
import '../../../data/models/product.dart';

abstract class LatestProductState extends Equatable {
  const LatestProductState();

  @override
  List<Object?> get props => [];
}

class LatestProductInitial extends LatestProductState {}

class LatestProductLoading extends LatestProductState {
  final List<Product> products;

  const LatestProductLoading({required this.products});

  @override
  List<Object?> get props => [products];
}

class LatestProductLoaded extends LatestProductState {
  final List<Product> products;
  final String? nextCursor;
  final bool hasReachedMax;

  const LatestProductLoaded({
    required this.products,
    this.nextCursor,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [products, nextCursor, hasReachedMax];
}

class LatestProductError extends LatestProductState {
  final String message;

  const LatestProductError(this.message);

  @override
  List<Object?> get props => [message];
}
