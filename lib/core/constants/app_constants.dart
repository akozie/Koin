/// App-wide constants. Values that would normally come from flavors /
/// `--dart-define` live here so they are easy to locate and change.
abstract final class AppConstants {
  static const appName = 'Koins Savings';
  static const bankName = 'Koins Microfinance Bank';

  // Networking
  static const apiBaseUrl = 'https://dummyjson.com';
  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 15);
  static const reachabilityTimeout = Duration(seconds: 5);

  /// Simulated latency for the mock backend so loading states are visible.
  static const mockLatency = Duration(milliseconds: 900);

  // Currency
  static const currencySymbol = '₦';
  static const currencyLocale = 'en_NG';
}

/// Keys used for persisted values. Centralised to avoid typos and collisions.
abstract final class StorageKeys {
  static const sessionUser = 'session.user';
  static const biometricUser = 'session.biometric_user';
  static const biometricEnabled = 'settings.biometric_enabled';
  static const themeMode = 'settings.theme_mode';

  static const savingsPlansBox = 'savings_plans';
  static const cacheBox = 'api_cache';
}
