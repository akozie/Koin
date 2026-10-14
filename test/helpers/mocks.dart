import 'dart:async';

import 'package:koins/core/network/network_info.dart';
import 'package:koins/repositories/auth_repository.dart';
import 'package:koins/repositories/product_repository.dart';
import 'package:koins/repositories/quotes_repository.dart';
import 'package:koins/repositories/savings_repository.dart';
import 'package:koins/repositories/settings_repository.dart';
import 'package:koins/services/api_service.dart';
import 'package:koins/services/auth_service.dart';
import 'package:koins/services/biometric_service.dart';
import 'package:koins/services/cache_storage_service.dart';
import 'package:koins/services/savings_service.dart';
import 'package:koins/services/savings_storage_service.dart';
import 'package:koins/services/session_storage_service.dart';
import 'package:koins/services/settings_storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockSavingsRepository extends Mock implements SavingsRepository {}

class MockQuotesRepository extends Mock implements QuotesRepository {}

class MockAuthService extends Mock implements AuthService {}

class MockSessionStorageService extends Mock implements SessionStorageService {}

class MockBiometricService extends Mock implements BiometricService {}

class MockSavingsService extends Mock implements SavingsService {}

class MockSavingsStorageService extends Mock implements SavingsStorageService {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockSettingsStorageService extends Mock implements SettingsStorageService {}

class MockApiService extends Mock implements ApiService {}

class MockCacheStorageService extends Mock implements CacheStorageService {}

/// Controllable connectivity for tests: flip [connected] to simulate the
/// device going offline or coming back online.
class FakeNetworkInfo implements NetworkInfo {
  FakeNetworkInfo({this._connected = true});

  bool _connected;
  final _controller = StreamController<bool>.broadcast();

  set connected(bool value) {
    _connected = value;
    _controller.add(value);
  }

  @override
  Future<bool> get isConnected async => _connected;

  @override
  Future<bool> checkNow() async => _connected;

  @override
  Stream<bool> get onConnectivityChanged => _controller.stream;

  @override
  void reportReachable() => connected = true;

  @override
  void reportUnreachable() => connected = false;
}
