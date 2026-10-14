import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koins/core/di/injection.dart';
import 'package:koins/core/errors/failures.dart';
import 'package:koins/core/errors/result.dart';
import 'package:koins/repositories/auth_repository.dart';
import 'package:koins/screens/login/login_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';
import '../helpers/mocks.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    when(() => repository.canLoginWithBiometrics).thenAnswer((_) async => false);
    getIt.registerSingleton<AuthRepository>(repository);
  });

  tearDown(getIt.reset);

  Finder field(String key) =>
      find.descendant(of: find.byKey(Key(key)), matching: find.byType(TextFormField));

  Future<void> tapLogin(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('login_button')));
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pump();
  }

  testWidgets('shows required errors when submitted empty', (tester) async {
    await tester.pumpScreen(const LoginScreen());

    await tapLogin(tester);

    expect(find.text('Email address is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    verifyNever(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('validates email format and password length', (tester) async {
    await tester.pumpScreen(const LoginScreen());

    await tester.enterText(field('login_email'), 'not-an-email');
    await tester.enterText(field('login_password'), 'short');
    await tapLogin(tester);

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Password must be at least 8 characters'), findsOneWidget);
  });

  testWidgets('submits valid credentials', (tester) async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Ok(tUser));
    await tester.pumpScreen(const LoginScreen());

    await tester.enterText(field('login_email'), 'test@bank.com');
    await tester.enterText(field('login_password'), 'Password123');
    await tapLogin(tester);
    await tester.pumpAndSettle();

    verify(() => repository.login(email: 'test@bank.com', password: 'Password123')).called(1);
  });

  testWidgets('shows an error message for wrong credentials', (tester) async {
    when(
      () => repository.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => const Err(AuthFailure('Invalid email or password.')));
    await tester.pumpScreen(const LoginScreen());

    await tester.enterText(field('login_email'), 'test@bank.com');
    await tester.enterText(field('login_password'), 'WrongPass1');
    await tapLogin(tester);
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Invalid email or password.'), findsOneWidget);
  });
}
