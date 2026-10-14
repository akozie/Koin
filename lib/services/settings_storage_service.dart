import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/exceptions.dart';

/// Persists app preferences (SharedPreferences).
abstract interface class SettingsStorageService {
  String? readThemeMode();

  Future<void> saveThemeMode(String mode);
}

class SettingsStorageServiceImpl implements SettingsStorageService {
  SettingsStorageServiceImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  String? readThemeMode() => _prefs.getString(StorageKeys.themeMode);

  @override
  Future<void> saveThemeMode(String mode) async {
    if (!await _prefs.setString(StorageKeys.themeMode, mode)) {
      throw const CacheException('Theme preference could not be saved');
    }
  }
}
