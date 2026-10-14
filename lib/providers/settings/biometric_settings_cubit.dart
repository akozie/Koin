import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/result.dart';
import '../../repositories/auth_repository.dart';

part 'biometric_settings_state.dart';

class BiometricSettingsCubit extends Cubit<BiometricSettingsState> {
  BiometricSettingsCubit(this._repository) : super(const BiometricSettingsState());

  final AuthRepository _repository;

  Future<void> load() async {
    final available = await _repository.isBiometricAvailable;
    if (isClosed) return;
    emit(
      BiometricSettingsState(
        isAvailable: available,
        isEnabled: available && _repository.isBiometricEnabled,
      ),
    );
  }

  Future<void> toggle({required bool enabled}) async {
    final result = await _repository.setBiometricEnabled(enabled: enabled);
    if (isClosed) return;
    emit(switch (result) {
      Ok() => state.copyWith(isEnabled: enabled),
      Err(:final failure) => state.copyWith(errorMessage: failure.message),
    });
  }
}
