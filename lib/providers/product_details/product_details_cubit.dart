import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/result.dart';
import '../../models/savings_product.dart';
import '../../repositories/product_repository.dart';
import '../view_status.dart';

part 'product_details_state.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  /// [initial] lets the list screen hand over the product it already has, so
  /// the page renders instantly; deep links fall back to [load].
  ProductDetailsCubit(this._repository, {SavingsProduct? initial})
    : super(
        initial == null
            ? const ProductDetailsState()
            : ProductDetailsState(status: ViewStatus.success, product: initial),
      );

  final ProductRepository _repository;

  Future<void> load(String productId) async {
    emit(state.copyWith(status: ViewStatus.loading));
    final result = await _repository.getProduct(productId);
    if (isClosed) return;
    emit(switch (result) {
      Ok(value: final product) => state.copyWith(status: ViewStatus.success, product: product),
      Err(:final failure) => state.copyWith(
        status: ViewStatus.failure,
        errorMessage: failure.message,
      ),
    });
  }
}
