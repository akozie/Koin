import 'package:equatable/equatable.dart';

/// User-facing failures returned by repositories.
///
/// The [message] is safe to show directly in the UI.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Check your network and try again.',
  ]);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'The request took too long. Please try again.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on our end. Please try again later.']);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Invalid email or password.']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'We could not save or read your data on this device.']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'We could not find what you were looking for.']);
}

/// A business rule was violated (e.g. contribution below the minimum deposit).
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred. Please try again.']);
}
