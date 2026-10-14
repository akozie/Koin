part of 'product_details_cubit.dart';

class ProductDetailsState extends Equatable {
  const ProductDetailsState({this.status = ViewStatus.initial, this.product, this.errorMessage});

  final ViewStatus status;
  final SavingsProduct? product;
  final String? errorMessage;

  ProductDetailsState copyWith({
    ViewStatus? status,
    SavingsProduct? product,
    String? errorMessage,
  }) => ProductDetailsState(
    status: status ?? this.status,
    product: product ?? this.product,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, product, errorMessage];
}
