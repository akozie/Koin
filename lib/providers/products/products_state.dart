part of 'products_bloc.dart';

class ProductsState extends Equatable {
  const ProductsState({
    this.status = ViewStatus.initial,
    this.products = const [],
    this.query = '',
    this.filter = ProductTenor.all,
    this.errorMessage,
  });

  final ViewStatus status;
  final List<SavingsProduct> products;
  final String query;
  final ProductTenor filter;
  final String? errorMessage;

  bool get hasActiveSearch => query.trim().isNotEmpty || filter != ProductTenor.all;

  /// Products after applying the search query and tenor filter.
  List<SavingsProduct> get visibleProducts {
    final q = query.trim().toLowerCase();
    return products.where((p) {
      final matchesFilter = switch (filter) {
        ProductTenor.all => true,
        ProductTenor.fixed => !p.isFlexible,
        ProductTenor.flexible => p.isFlexible,
      };
      final matchesQuery =
          q.isEmpty || p.name.toLowerCase().contains(q) || p.description.toLowerCase().contains(q);
      return matchesFilter && matchesQuery;
    }).toList();
  }

  ProductsState copyWith({
    ViewStatus? status,
    List<SavingsProduct>? products,
    String? query,
    ProductTenor? filter,
    String? errorMessage,
  }) => ProductsState(
    status: status ?? this.status,
    products: products ?? this.products,
    query: query ?? this.query,
    filter: filter ?? this.filter,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, products, query, filter, errorMessage];
}
