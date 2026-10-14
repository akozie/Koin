import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../repositories/auth_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/quotes_repository.dart';
import '../../repositories/savings_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../services/cache_storage_service.dart';
import '../../services/savings_service.dart';
import '../../services/savings_storage_service.dart';
import '../../services/session_storage_service.dart';
import '../../services/settings_storage_service.dart';
import '../constants/app_constants.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../network/reachability.dart';

/// Service locator. Only the composition root (main / router) reads from it;
/// every class below receives its dependencies through its constructor.
final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  await Hive.initFlutter();
  final plansBox = await Hive.openBox<String>(StorageKeys.savingsPlansBox);
  final cacheBox = await Hive.openBox<String>(StorageKeys.cacheBox);

  getIt
    // Core
    ..registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(Connectivity(), httpReachabilityProbe()),
    )
    ..registerLazySingleton<Dio>(
      () => DioClient.create(interceptors: [ReachabilityInterceptor(getIt())]),
    )
    // Services (data sources)
    ..registerLazySingleton<AuthService>(MockAuthService.new)
    ..registerLazySingleton<SavingsService>(MockSavingsService.new)
    ..registerLazySingleton<ApiService>(() => ApiServiceImpl(getIt(), getIt()))
    ..registerLazySingleton<SessionStorageService>(() => SessionStorageServiceImpl(prefs))
    ..registerLazySingleton<SavingsStorageService>(() => SavingsStorageServiceImpl(plansBox))
    ..registerLazySingleton<SettingsStorageService>(() => SettingsStorageServiceImpl(prefs))
    ..registerLazySingleton<CacheStorageService>(() => CacheStorageServiceImpl(cacheBox))
    ..registerLazySingleton<BiometricService>(() => BiometricServiceImpl(LocalAuthentication()))
    // Repositories
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        authService: getIt(),
        sessionStorage: getIt(),
        biometricService: getIt(),
      ),
    )
    ..registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(getIt()))
    ..registerLazySingleton<SavingsRepository>(
      () => SavingsRepositoryImpl(service: getIt(), storage: getIt(), networkInfo: getIt()),
    )
    ..registerLazySingleton<QuotesRepository>(() => QuotesRepositoryImpl(getIt(), getIt()))
    ..registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(getIt()));
}
