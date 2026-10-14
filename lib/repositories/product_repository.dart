import '../core/errors/result.dart';
import '../models/savings_product.dart';
import '../services/savings_service.dart';

abstract interface class ProductRepository {
  Future<Result<List<SavingsProduct>>> getProducts({bool forceRefresh = false});

  Future<Result<SavingsProduct>> getProduct(String id);
}

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._service);

  final SavingsService _service;

  /// Products rarely change, so they are cached for the app session.
  List<SavingsProduct>? _cache;

  @override
  Future<Result<List<SavingsProduct>>> getProducts({bool forceRefresh = false}) {
    final cached = _cache;
    if (cached != null && !forceRefresh) return Future.value(Ok(cached));
    return guard(() async => _cache = await _service.fetchProducts());
  }

  @override
  Future<Result<SavingsProduct>> getProduct(String id) {
    final cached = _cache?.where((p) => p.id == id).firstOrNull;
    if (cached != null) return Future.value(Ok(cached));
    return guard(() => _service.fetchProduct(id));
  }
}
