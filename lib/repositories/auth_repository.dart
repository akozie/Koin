import 'dart:async';

import '../core/errors/failures.dart';
import '../core/errors/result.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../services/session_storage_service.dart';

abstract interface class AuthRepository {
  /// Emits the signed-in user, or `null` after logout.
  Stream<User?> get userChanges;

  User? get currentUser;

  /// Loads a persisted session, if any.
  Future<User?> restoreSession();

  Future<Result<User>> login({required String email, required String password});

  Future<Result<void>> logout();

  /// True when the device supports biometrics and the user opted in.
  Future<bool> get canLoginWithBiometrics;

  Future<bool> get isBiometricAvailable;

  bool get isBiometricEnabled;

  Future<Result<User>> loginWithBiometrics();

  Future<Result<void>> setBiometricEnabled({required bool enabled});
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._authService,
    required this._sessionStorage,
    required this._biometricService,
  });

  final AuthService _authService;
  final SessionStorageService _sessionStorage;
  final BiometricService _biometricService;

  final _controller = StreamController<User?>.broadcast();
  User? _currentUser;

  @override
  Stream<User?> get userChanges => _controller.stream;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<User?> restoreSession() async {
    try {
      _currentUser = await _sessionStorage.readUser();
    } on Object {
      _currentUser = null;
    }
    return _currentUser;
  }

  @override
  Future<Result<User>> login({required String email, required String password}) => guard(() async {
    final user = await _authService.login(email: email, password: password);
    await _startSession(user);
    return user;
  });

  @override
  Future<Result<void>> logout() => guard(() async {
    await _sessionStorage.clearUser();
    _currentUser = null;
    _controller.add(null);
  });

  @override
  Future<bool> get isBiometricAvailable => _biometricService.isAvailable;

  @override
  bool get isBiometricEnabled => _sessionStorage.isBiometricEnabled;

  @override
  Future<bool> get canLoginWithBiometrics async =>
      isBiometricEnabled && await _biometricService.isAvailable;

  @override
  Future<Result<User>> loginWithBiometrics() async {
    final result = await guard(_sessionStorage.readBiometricUser);
    final user = switch (result) {
      Ok(:final value) => value,
      Err() => null,
    };
    if (user == null) {
      return const Err(AuthFailure('Biometric login is not set up on this device.'));
    }
    final authenticated = await _biometricService.authenticate(
      reason: 'Confirm your identity to sign in to Koins',
    );
    if (!authenticated) {
      return const Err(AuthFailure('Biometric authentication was not completed.'));
    }
    return guard(() async {
      await _startSession(user);
      return user;
    });
  }

  @override
  Future<Result<void>> setBiometricEnabled({required bool enabled}) async {
    if (!enabled) return guard(_sessionStorage.disableBiometric);

    final user = _currentUser;
    if (user == null) {
      return const Err(AuthFailure('Sign in before enabling biometric login.'));
    }
    // The device owner must prove their identity before biometrics can be
    // used to sign in to this account.
    final authenticated = await _biometricService.authenticate(
      reason: 'Confirm your identity to enable biometric login',
    );
    if (!authenticated) {
      return const Err(AuthFailure('Biometric login was not enabled.'));
    }
    return guard(() => _sessionStorage.enableBiometric(user));
  }

  Future<void> _startSession(User user) async {
    await _sessionStorage.saveUser(user);
    _currentUser = user;
    _controller.add(user);
  }
}
