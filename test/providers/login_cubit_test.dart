import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koins/core/errors/failures.dart';
import 'package:koins/core/errors/result.dart';
import 'package:koins/providers/login/login_cubit.dart';
import 'package:koins/providers/view_status.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  blocTest<LoginCubit, LoginState>(
    'emits [submitting, success] when credentials are valid',
    setUp: () => when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Ok(tUser)),
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.login(email: 'test@bank.com', password: 'Password123'),
    expect: () => const [
      LoginState(status: SubmitStatus.submitting),
      LoginState(status: SubmitStatus.success),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'emits [submitting, failure] with a message when credentials are wrong',
    setUp: () => when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Err(AuthFailure('Invalid email or password.'))),
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.login(email: 'test@bank.com', password: 'wrong-password'),
    expect: () => const [
      LoginState(status: SubmitStatus.submitting),
      LoginState(status: SubmitStatus.failure, errorMessage: 'Invalid email or password.'),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'exposes biometric availability',
    setUp: () => when(() => repository.canLoginWithBiometrics).thenAnswer((_) async => true),
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.checkBiometrics(),
    expect: () => const [LoginState(canUseBiometrics: true)],
  );

  test('ignores duplicate submissions while one is in flight', () async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Ok(tUser));
    final cubit = LoginCubit(repository);

    await Future.wait([
      cubit.login(email: 'a@b.com', password: 'Password123'),
      cubit.login(email: 'a@b.com', password: 'Password123'),
    ]);

    verify(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).called(1);
  });
}
