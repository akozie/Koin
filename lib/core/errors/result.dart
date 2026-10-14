import 'dart:developer' as developer;

import 'exceptions.dart';
import 'failures.dart';

/// Either a value of type [T] or a [Failure].
///
/// Repositories return [Result] instead of throwing, so the presentation layer
/// is forced (by exhaustive `switch`) to handle the error path.
sealed class Result<T> {
  const Result();

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => switch (this) {
    Ok<T>(:final value) => onSuccess(value),
    Err<T>(:final failure) => onFailure(failure),
  };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}

/// Runs [action] and converts any thrown error into an [Err].
Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    return Ok(await action());
  } on AppException catch (e) {
    return Err(mapExceptionToFailure(e));
  } catch (e, stackTrace) {
    developer.log('Unexpected error', error: e, stackTrace: stackTrace, name: 'guard');
    return const Err(UnexpectedFailure());
  }
}

Failure mapExceptionToFailure(AppException exception) => switch (exception) {
  NetworkException() => const NetworkFailure(),
  RequestTimeoutException() => const TimeoutFailure(),
  ServerException() => const ServerFailure(),
  InvalidCredentialsException(:final message) => AuthFailure('$message.'),
  CacheException() => const CacheFailure(),
  NotFoundException() => const NotFoundFailure(),
};
