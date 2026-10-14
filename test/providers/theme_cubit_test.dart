import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:koins/core/errors/failures.dart';
import 'package:koins/core/errors/result.dart';
import 'package:koins/models/app_theme_mode.dart';
import 'package:koins/providers/theme/theme_cubit.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';

void main() {
  late MockSettingsRepository repository;

  setUpAll(() => registerFallbackValue(AppThemeMode.system));

  setUp(() {
    repository = MockSettingsRepository();
    when(() => repository.themeMode).thenReturn(AppThemeMode.system);
    when(() => repository.setThemeMode(any())).thenAnswer((_) async => const Ok(null));
  });

  test('starts with the saved preference', () {
    when(() => repository.themeMode).thenReturn(AppThemeMode.dark);
    expect(ThemeCubit(repository).state, AppThemeMode.dark);
  });

  blocTest<ThemeCubit, AppThemeMode>(
    'applies and persists a new mode',
    build: () => ThemeCubit(repository),
    act: (cubit) => cubit.setMode(AppThemeMode.dark),
    expect: () => [AppThemeMode.dark],
    verify: (_) => verify(() => repository.setThemeMode(AppThemeMode.dark)).called(1),
  );

  blocTest<ThemeCubit, AppThemeMode>(
    'keeps the new mode even if saving fails',
    setUp: () => when(
      () => repository.setThemeMode(any()),
    ).thenAnswer((_) async => const Err(CacheFailure())),
    build: () => ThemeCubit(repository),
    act: (cubit) => cubit.setMode(AppThemeMode.light),
    expect: () => [AppThemeMode.light],
  );

  blocTest<ThemeCubit, AppThemeMode>(
    'ignores selecting the current mode',
    build: () => ThemeCubit(repository),
    act: (cubit) => cubit.setMode(AppThemeMode.system),
    expect: () => <AppThemeMode>[],
    verify: (_) => verifyNever(() => repository.setThemeMode(any())),
  );
}
