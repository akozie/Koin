import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/result.dart';
import '../../models/user.dart';
import '../../repositories/auth_repository.dart';
import '../view_status.dart';

part 'login_state.dart';

/// Handles the login form submission. Field validation lives in the form;
/// navigation happens via [AuthCubit] once the session starts.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._repository) : super(const LoginState());

  final AuthRepository _repository;

  Future<void> checkBiometrics() async {
    final available = await _repository.canLoginWithBiometrics;
    if (!isClosed) emit(state.copyWith(canUseBiometrics: available));
  }

  Future<void> login({required String email, required String password}) =>
      _submit(() => _repository.login(email: email, password: password));

  Future<void> loginWithBiometrics() => _submit(_repository.loginWithBiometrics);

  Future<void> _submit(Future<Result<User>> Function() action) async {
    if (state.status.isSubmitting) return;
    emit(state.copyWith(status: SubmitStatus.submitting));
    final result = await action();
    if (isClosed) return;
    emit(switch (result) {
      Ok() => state.copyWith(status: SubmitStatus.success),
      Err(:final failure) => state.copyWith(
        status: SubmitStatus.failure,
        errorMessage: failure.message,
      ),
    });
  }
}
