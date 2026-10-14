import '../core/errors/result.dart';
import '../models/app_theme_mode.dart';
import '../services/settings_storage_service.dart';

abstract interface class SettingsRepository {
  /// The saved theme preference, defaulting to [AppThemeMode.system].
  AppThemeMode get themeMode;

  Future<Result<void>> setThemeMode(AppThemeMode mode);
}

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._storage);

  final SettingsStorageService _storage;

  @override
  AppThemeMode get themeMode {
    final saved = _storage.readThemeMode();
    return AppThemeMode.values.where((m) => m.name == saved).firstOrNull ?? AppThemeMode.system;
  }

  @override
  Future<Result<void>> setThemeMode(AppThemeMode mode) =>
      guard(() => _storage.saveThemeMode(mode.name));
}
