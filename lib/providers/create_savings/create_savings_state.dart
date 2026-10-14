part of 'create_savings_cubit.dart';

class CreateSavingsState extends Equatable {
  const CreateSavingsState({
    this.productsStatus = ViewStatus.initial,
    this.products = const [],
    this.selectedProduct,
    this.submitStatus = SubmitStatus.idle,
    this.createdPlan,
    this.errorMessage,
  });

  final ViewStatus productsStatus;
  final List<SavingsProduct> products;
  final SavingsProduct? selectedProduct;
  final SubmitStatus submitStatus;
  final SavingsPlan? createdPlan;
  final String? errorMessage;

  CreateSavingsState copyWith({
    ViewStatus? productsStatus,
    List<SavingsProduct>? products,
    SavingsProduct? selectedProduct,
    bool clearSelection = false,
    SubmitStatus? submitStatus,
    SavingsPlan? createdPlan,
    String? errorMessage,
  }) => CreateSavingsState(
    productsStatus: productsStatus ?? this.productsStatus,
    products: products ?? this.products,
    selectedProduct: clearSelection ? null : selectedProduct ?? this.selectedProduct,
    submitStatus: submitStatus ?? this.submitStatus,
    createdPlan: createdPlan ?? this.createdPlan,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [
    productsStatus,
    products,
    selectedProduct,
    submitStatus,
    createdPlan,
    errorMessage,
  ];
}
