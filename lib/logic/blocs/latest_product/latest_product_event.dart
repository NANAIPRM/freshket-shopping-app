import 'package:equatable/equatable.dart';

abstract class LatestProductEvent extends Equatable {
  const LatestProductEvent();
  
  @override
  List<Object?> get props => [];
}

class FetchLatestProductsEvent extends LatestProductEvent {}

class LoadMoreLatestProductsEvent extends LatestProductEvent {}

class RefreshLatestProductsEvent extends LatestProductEvent {}