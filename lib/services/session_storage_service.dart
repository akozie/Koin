import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/exceptions.dart';
import '../models/user.dart';

/// Persists the logged-in user and auth-related settings (SharedPreferences).
abstract interface class SessionStorageService {
  Future<User?> readUser();

  Future<void> saveUser(User user);

  Future<void> clearUser();

  bool get isBiometricEnabled;

  /// The user that can be restored with biometrics after logging out.
  Future<User?> readBiometricUser();

  Future<void> enableBiometric(User user);

  Future<void> disableBiometric();
}

class SessionStorageServiceImpl implements SessionStorageService {
  SessionStorageServiceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<User?> readUser() async => _decodeUser(StorageKeys.sessionUser);

  @override
  Future<void> saveUser(User user) =>
      _write(() => _prefs.setString(StorageKeys.sessionUser, jsonEncode(user.toJson())));

  @override
  Future<void> clearUser() => _write(() => _prefs.remove(StorageKeys.sessionUser));

  @override
  bool get isBiometricEnabled => _prefs.getBool(StorageKeys.biometricEnabled) ?? false;

  @override
  Future<User?> readBiometricUser() async =>
      isBiometricEnabled ? _decodeUser(StorageKeys.biometricUser) : null;

  @override
  Future<void> enableBiometric(User user) => _write(() async {
    await _prefs.setString(StorageKeys.biometricUser, jsonEncode(user.toJson()));
    return _prefs.setBool(StorageKeys.biometricEnabled, true);
  });

  @override
  Future<void> disableBiometric() => _write(() async {
    await _prefs.remove(StorageKeys.biometricUser);
    return _prefs.setBool(StorageKeys.biometricEnabled, false);
  });

  User? _decodeUser(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      // Corrupted entry: treat as signed out rather than crashing.
      _prefs.remove(key);
      return null;
    }
  }

  Future<void> _write(Future<bool> Function() write) async {
    final ok = await write();
    if (!ok) throw const CacheException();
  }
}
