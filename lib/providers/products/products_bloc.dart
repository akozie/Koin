import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/result.dart';
import '../../models/savings_product.dart';
import '../../repositories/product_repository.dart';
import '../view_status.dart';

part 'products_event.dart';
part 'products_state.dart';

/// Products catalogue with search and tenor filtering.
///
/// A full [Bloc] (rather than a Cubit) because the screen produces several
/// distinct user intents that are worth modelling as explicit events.
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  ProductsBloc(this._repository) : super(const ProductsState()) {
    on<ProductsRequested>(_onRequested);
    on<ProductsSearchChanged>(_onSearchChanged);
    on<ProductsFilterChanged>(_onFilterChanged);
  }

  final ProductRepository _repository;

  Future<void> _onRequested(ProductsRequested event, Emitter<ProductsState> emit) async {
    if (state.products.isEmpty || !event.forceRefresh) {
      emit(state.copyWith(status: ViewStatus.loading));
    }
    final result = await _repository.getProducts(forceRefresh: event.forceRefresh);
    emit(switch (result) {
      Ok(value: final products) => state.copyWith(status: ViewStatus.success, products: products),
      Err(:final failure) => state.copyWith(
        status: ViewStatus.failure,
        errorMessage: failure.message,
      ),
    });
  }

  void _onSearchChanged(ProductsSearchChanged event, Emitter<ProductsState> emit) =>
      emit(state.copyWith(query: event.query));

  void _onFilterChanged(ProductsFilterChanged event, Emitter<ProductsState> emit) =>
      emit(state.copyWith(filter: event.filter));
}
