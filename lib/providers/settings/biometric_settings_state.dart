part of 'biometric_settings_cubit.dart';

class BiometricSettingsState extends Equatable {
  const BiometricSettingsState({
    this.isAvailable = false,
    this.isEnabled = false,
    this.errorMessage,
  });

  final bool isAvailable;
  final bool isEnabled;
  final String? errorMessage;

  BiometricSettingsState copyWith({bool? isEnabled, String? errorMessage}) =>
      BiometricSettingsState(
        isAvailable: isAvailable,
        isEnabled: isEnabled ?? this.isEnabled,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [isAvailable, isEnabled, errorMessage];
}
