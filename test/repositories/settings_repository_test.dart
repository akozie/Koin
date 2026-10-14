import 'package:flutter_test/flutter_test.dart';
import 'package:koins/core/errors/exceptions.dart';
import 'package:koins/core/errors/failures.dart';
import 'package:koins/core/errors/result.dart';
import 'package:koins/models/app_theme_mode.dart';
import 'package:koins/repositories/settings_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mocks.dart';

void main() {
  late MockSettingsStorageService storage;
  late SettingsRepositoryImpl repository;

  setUp(() {
    storage = MockSettingsStorageService();
    repository = SettingsRepositoryImpl(storage);
  });

  group('themeMode', () {
    test('defaults to system when nothing is saved', () {
      when(() => storage.readThemeMode()).thenReturn(null);
      expect(repository.themeMode, AppThemeMode.system);
    });

    test('defaults to system for an unknown value', () {
      when(() => storage.readThemeMode()).thenReturn('sepia');
      expect(repository.themeMode, AppThemeMode.system);
    });

    test('returns the saved mode', () {
      when(() => storage.readThemeMode()).thenReturn('dark');
      expect(repository.themeMode, AppThemeMode.dark);
    });
  });

  test('setThemeMode stores the mode name', () async {
    when(() => storage.saveThemeMode(any())).thenAnswer((_) async {});

    final result = await repository.setThemeMode(AppThemeMode.light);

    expect(result, isA<Ok<void>>());
    verify(() => storage.saveThemeMode('light')).called(1);
  });

  test('setThemeMode maps storage errors to CacheFailure', () async {
    when(() => storage.saveThemeMode(any())).thenThrow(const CacheException());

    final result = await repository.setThemeMode(AppThemeMode.dark);

    expect((result as Err).failure, isA<CacheFailure>());
  });
}
