import '../core/constants/app_constants.dart';
import '../core/errors/exceptions.dart';
import '../models/user.dart';

/// Authentication data source.
abstract interface class AuthService {
  /// Returns the authenticated [User] or throws [InvalidCredentialsException].
  Future<User> login({required String email, required String password});
}

/// Mock implementation: no backend, credentials are validated locally.
class MockAuthService implements AuthService {
  MockAuthService({this.latency = AppConstants.mockLatency});

  final Duration latency;

  static const demoEmail = 'test@bank.com';
  static const demoPassword = 'Password123';

  static const demoUser = User(
    id: 'usr_001',
    fullName: 'John Doe',
    email: demoEmail,
    phone: '+234 803 123 4567',
  );

  @override
  Future<User> login({required String email, required String password}) async {
    await Future<void>.delayed(latency);
    final emailMatches = email.trim().toLowerCase() == demoEmail;
    if (!emailMatches || password != demoPassword) {
      throw const InvalidCredentialsException();
    }
    return demoUser;
  }
}
