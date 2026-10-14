import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koins/core/errors/failures.dart';
import 'package:koins/core/errors/result.dart';
import 'package:koins/models/savings_product.dart';
import 'package:koins/providers/products/products_bloc.dart';
import 'package:koins/providers/view_status.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';

void main() {
  late MockProductRepository repository;
  const products = [tTargetProduct, tFlexibleProduct];

  setUp(() => repository = MockProductRepository());

  blocTest<ProductsBloc, ProductsState>(
    'loads products',
    setUp: () => when(
      () => repository.getProducts(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => const Ok(products)),
    build: () => ProductsBloc(repository),
    act: (bloc) => bloc.add(const ProductsRequested()),
    expect: () => const [
      ProductsState(status: ViewStatus.loading),
      ProductsState(status: ViewStatus.success, products: products),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'emits failure with the failure message',
    setUp: () => when(
      () => repository.getProducts(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => const Err(NetworkFailure())),
    build: () => ProductsBloc(repository),
    act: (bloc) => bloc.add(const ProductsRequested()),
    expect: () => [
      const ProductsState(status: ViewStatus.loading),
      ProductsState(status: ViewStatus.failure, errorMessage: const NetworkFailure().message),
    ],
  );

  group('visibleProducts', () {
    const loaded = ProductsState(status: ViewStatus.success, products: products);

    test('filters by search query (case-insensitive, name or description)', () {
      expect(loaded.copyWith(query: 'TARGET').visibleProducts, [tTargetProduct]);
      expect(loaded.copyWith(query: 'trip').visibleProducts, [tFlexibleProduct]);
      expect(loaded.copyWith(query: 'nothing').visibleProducts, isEmpty);
    });

    test('filters by tenor', () {
      expect(loaded.copyWith(filter: ProductTenor.fixed).visibleProducts, [tTargetProduct]);
      expect(loaded.copyWith(filter: ProductTenor.flexible).visibleProducts, [tFlexibleProduct]);
      expect(loaded.copyWith(filter: ProductTenor.all).visibleProducts, products);
    });
  });

  blocTest<ProductsBloc, ProductsState>(
    'updates query and filter from events',
    build: () => ProductsBloc(repository),
    act: (bloc) => bloc
      ..add(const ProductsSearchChanged('fixed'))
      ..add(const ProductsFilterChanged(ProductTenor.flexible)),
    expect: () => const [
      ProductsState(query: 'fixed'),
      ProductsState(query: 'fixed', filter: ProductTenor.flexible),
    ],
  );
}
