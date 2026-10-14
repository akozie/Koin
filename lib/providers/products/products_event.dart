part of 'products_bloc.dart';

sealed class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

final class ProductsRequested extends ProductsEvent {
  const ProductsRequested({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

final class ProductsSearchChanged extends ProductsEvent {
  const ProductsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class ProductsFilterChanged extends ProductsEvent {
  const ProductsFilterChanged(this.filter);

  final ProductTenor filter;

  @override
  List<Object?> get props => [filter];
}
