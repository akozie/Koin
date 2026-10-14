import 'package:flutter_test/flutter_test.dart';
import 'package:koins/core/errors/exceptions.dart';
import 'package:koins/core/errors/failures.dart';
import 'package:koins/core/errors/result.dart';
import 'package:koins/models/user.dart';
import 'package:koins/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';

void main() {
  late MockAuthService authService;
  late MockSessionStorageService storage;
  late MockBiometricService biometrics;
  late AuthRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(tUser));

  setUp(() {
    authService = MockAuthService();
    storage = MockSessionStorageService();
    biometrics = MockBiometricService();
    repository = AuthRepositoryImpl(
      authService: authService,
      sessionStorage: storage,
      biometricService: biometrics,
    );
    when(() => storage.saveUser(any())).thenAnswer((_) async {});
    when(() => storage.clearUser()).thenAnswer((_) async {});
  });

  group('login', () {
    test('persists the session and emits the user', () async {
      when(
        () => authService.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => tUser);

      final emitted = expectLater(repository.userChanges, emits(tUser));
      final result = await repository.login(email: 'test@bank.com', password: 'Password123');

      expect((result as Ok<User>).value, tUser);
      expect(repository.currentUser, tUser);
      verify(() => storage.saveUser(tUser)).called(1);
      await emitted;
    });

    test('maps invalid credentials to AuthFailure', () async {
      when(
        () => authService.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const InvalidCredentialsException());

      final result = await repository.login(email: 'x@y.com', password: 'wrongpass');

      expect((result as Err).failure, isA<AuthFailure>());
      verifyNever(() => storage.saveUser(any()));
    });
  });

  test('logout clears the session and emits null', () async {
    final emitted = expectLater(repository.userChanges, emits(isNull));

    await repository.logout();

    verify(() => storage.clearUser()).called(1);
    expect(repository.currentUser, isNull);
    await emitted;
  });

  test('restoreSession returns the persisted user', () async {
    when(() => storage.readUser()).thenAnswer((_) async => tUser);

    expect(await repository.restoreSession(), tUser);
    expect(repository.currentUser, tUser);
  });

  group('setBiometricEnabled', () {
    setUp(() async {
      when(() => storage.readUser()).thenAnswer((_) async => tUser);
      when(() => storage.enableBiometric(any())).thenAnswer((_) async {});
      when(() => storage.disableBiometric()).thenAnswer((_) async {});
      await repository.restoreSession();
    });

    test('requires biometric confirmation before enabling', () async {
      when(
        () => biometrics.authenticate(reason: any(named: 'reason')),
      ).thenAnswer((_) async => true);

      final result = await repository.setBiometricEnabled(enabled: true);

      expect(result, isA<Ok<void>>());
      verify(() => storage.enableBiometric(tUser)).called(1);
    });

    test('does not enable when confirmation is cancelled', () async {
      when(
        () => biometrics.authenticate(reason: any(named: 'reason')),
      ).thenAnswer((_) async => false);

      final result = await repository.setBiometricEnabled(enabled: true);

      expect((result as Err).failure, isA<AuthFailure>());
      verifyNever(() => storage.enableBiometric(any()));
    });

    test('disables without a prompt', () async {
      await repository.setBiometricEnabled(enabled: false);

      verify(() => storage.disableBiometric()).called(1);
      verifyNever(() => biometrics.authenticate(reason: any(named: 'reason')));
    });
  });

  group('loginWithBiometrics', () {
    test('fails when biometrics were never enabled', () async {
      when(() => storage.readBiometricUser()).thenAnswer((_) async => null);

      final result = await repository.loginWithBiometrics();

      expect((result as Err).failure, isA<AuthFailure>());
      verifyNever(() => biometrics.authenticate(reason: any(named: 'reason')));
    });

    test('starts a session after successful authentication', () async {
      when(() => storage.readBiometricUser()).thenAnswer((_) async => tUser);
      when(
        () => biometrics.authenticate(reason: any(named: 'reason')),
      ).thenAnswer((_) async => true);

      final result = await repository.loginWithBiometrics();

      expect((result as Ok<User>).value, tUser);
      verify(() => storage.saveUser(tUser)).called(1);
    });

    test('fails when the user cancels the prompt', () async {
      when(() => storage.readBiometricUser()).thenAnswer((_) async => tUser);
      when(
        () => biometrics.authenticate(reason: any(named: 'reason')),
      ).thenAnswer((_) async => false);

      final result = await repository.loginWithBiometrics();

      expect((result as Err).failure, isA<AuthFailure>());
      verifyNever(() => storage.saveUser(any()));
    });
  });
}
