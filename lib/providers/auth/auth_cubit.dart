import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/user.dart';
import '../../repositories/auth_repository.dart';

part 'auth_state.dart';

/// App-wide session state. Drives the router's auth redirect.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState.unknown()) {
    _subscription = _repository.userChanges.listen(_onUserChanged);
  }

  final AuthRepository _repository;
  late final StreamSubscription<User?> _subscription;

  Future<void> checkSession() async {
    final user = await _repository.restoreSession();
    _onUserChanged(user);
  }

  Future<void> logout() => _repository.logout();

  void _onUserChanged(User? user) =>
      emit(user == null ? const AuthState.unauthenticated() : AuthState.authenticated(user));

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
