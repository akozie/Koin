import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Thin wrapper around `local_auth` so it can be mocked in tests.
abstract interface class BiometricService {
  Future<bool> get isAvailable;

  Future<bool> authenticate({required String reason});
}

class BiometricServiceImpl implements BiometricService {
  BiometricServiceImpl(this._auth);

  final LocalAuthentication _auth;

  @override
  Future<bool> get isAvailable async {
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(localizedReason: reason, biometricOnly: true);
    } on LocalAuthException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
