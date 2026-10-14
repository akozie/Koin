part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.status = SubmitStatus.idle,
    this.errorMessage,
    this.canUseBiometrics = false,
  });

  final SubmitStatus status;
  final String? errorMessage;
  final bool canUseBiometrics;

  LoginState copyWith({SubmitStatus? status, String? errorMessage, bool? canUseBiometrics}) =>
      LoginState(
        status: status ?? this.status,
        // The error only survives while the status is still `failure`.
        errorMessage: status == SubmitStatus.failure ? errorMessage : null,
        canUseBiometrics: canUseBiometrics ?? this.canUseBiometrics,
      );

  @override
  List<Object?> get props => [status, errorMessage, canUseBiometrics];
}
