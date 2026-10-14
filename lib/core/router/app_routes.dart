/// Route paths. Use these instead of string literals.
abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const products = '/products';
  static const profile = '/profile';
  static const createSavings = '/create-savings';

  static String productDetails(String id) => '$products/$id';

  static String createSavingsFor(String? productId) => productId == null
      ? createSavings
      : Uri(path: createSavings, queryParameters: {'productId': productId}).toString();
}
