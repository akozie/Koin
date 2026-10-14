import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/app_theme_mode.dart';
import '../../repositories/settings_repository.dart';

/// App-wide appearance preference (System / Light / Dark).
class ThemeCubit extends Cubit<AppThemeMode> {
  ThemeCubit(this._repository) : super(_repository.themeMode);

  final SettingsRepository _repository;

  /// Applies the new mode immediately, then persists it. A failed write only
  /// means the choice isn't remembered next launch, so the UI is not blocked.
  Future<void> setMode(AppThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _repository.setThemeMode(mode);
  }
}
