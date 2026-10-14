/// Exceptions thrown by the data layer (services).
///
/// They never reach the UI: repositories translate them into [Failure]s.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

final class RequestTimeoutException extends AppException {
  const RequestTimeoutException([super.message = 'The request timed out']);
}

final class ServerException extends AppException {
  const ServerException(super.message, {this.statusCode});

  final int? statusCode;
}

final class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException([super.message = 'Invalid email or password']);
}

final class CacheException extends AppException {
  const CacheException([super.message = 'Could not access local storage']);
}

final class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Item not found']);
}
