import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/result.dart';
import '../../models/savings_plan.dart';
import '../../models/savings_product.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/savings_repository.dart';
import '../view_status.dart';

part 'create_savings_state.dart';

class CreateSavingsCubit extends Cubit<CreateSavingsState> {
  CreateSavingsCubit({required this._productRepository, required this._savingsRepository})
    : super(const CreateSavingsState());

  final ProductRepository _productRepository;
  final SavingsRepository _savingsRepository;

  /// Loads products for the dropdown, optionally pre-selecting one.
  Future<void> init({String? initialProductId}) async {
    emit(state.copyWith(productsStatus: ViewStatus.loading));
    final result = await _productRepository.getProducts();
    if (isClosed) return;
    switch (result) {
      case Ok(value: final products):
        final initial = products.where((p) => p.id == initialProductId).firstOrNull;
        emit(
          state.copyWith(
            productsStatus: ViewStatus.success,
            products: products,
            selectedProduct: initial,
          ),
        );
      case Err(:final failure):
        emit(state.copyWith(productsStatus: ViewStatus.failure, errorMessage: failure.message));
    }
  }

  void selectProduct(SavingsProduct? product) =>
      emit(state.copyWith(selectedProduct: product, clearSelection: product == null));

  Future<void> submit(CreateSavingsRequest request) async {
    if (state.submitStatus.isSubmitting) return;
    emit(state.copyWith(submitStatus: SubmitStatus.submitting));
    final result = await _savingsRepository.createPlan(request);
    if (isClosed) return;
    emit(switch (result) {
      Ok(value: final plan) => state.copyWith(
        submitStatus: SubmitStatus.success,
        createdPlan: plan,
      ),
      Err(:final failure) => state.copyWith(
        submitStatus: SubmitStatus.failure,
        errorMessage: failure.message,
      ),
    });
  }
}
