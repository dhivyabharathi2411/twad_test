import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final String code;
  
  const Failure(this.message, this.code);
  
  @override
  List<Object> get props => [message, code];
  
  @override
  String toString() => 'Failure: $message (Code: $code)';
}

/// Server failure (5xx errors)
class ServerFailure extends Failure {
  const ServerFailure(super.message, super.code);
  
  factory ServerFailure.internalServerError() =>
      const ServerFailure('Internal server error occurred', 'SERVER_ERROR');
  
  factory ServerFailure.serviceUnavailable() =>
      const ServerFailure('Service temporarily unavailable', 'SERVICE_UNAVAILABLE');
}

/// Client failure (4xx errors)
class ClientFailure extends Failure {
  const ClientFailure(super.message, super.code);
  
  factory ClientFailure.badRequest() =>
      const ClientFailure('Invalid request data', 'BAD_REQUEST');
  
  factory ClientFailure.unauthorized() =>
      const ClientFailure('Authentication required', 'UNAUTHORIZED');
  
  factory ClientFailure.forbidden() =>
      const ClientFailure('Access denied', 'FORBIDDEN');
  
  factory ClientFailure.notFound() =>
      const ClientFailure('Resource not found', 'NOT_FOUND');
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, super.code);
  
  factory NetworkFailure.noConnection() =>
      const NetworkFailure('No internet connection available', 'NO_CONNECTION');
  
  factory NetworkFailure.timeout() =>
      const NetworkFailure('Request timeout occurred', 'TIMEOUT');
  
  factory NetworkFailure.connectionFailed() =>
      const NetworkFailure('Failed to connect to server', 'CONNECTION_FAILED');
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure(super.message, super.code);
  
  factory CacheFailure.notFound() =>
      const CacheFailure('Data not found in cache', 'CACHE_NOT_FOUND');
  
  factory CacheFailure.writeError() =>
      const CacheFailure('Failed to write to cache', 'CACHE_WRITE_ERROR');
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, super.code);
  
  factory ValidationFailure.invalidPhoneNumber() =>
      const ValidationFailure('Invalid phone number format', 'INVALID_PHONE');
  
  factory ValidationFailure.invalidOTP() =>
      const ValidationFailure('Invalid OTP format', 'INVALID_OTP');
  
  factory ValidationFailure.emptyField(String fieldName) =>
      ValidationFailure('$fieldName cannot be empty', 'EMPTY_FIELD');
}

/// General failure for unexpected errors
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String message) : super(message, 'UNEXPECTED_ERROR');
  
  factory UnexpectedFailure.fromException(Exception exception) =>
      UnexpectedFailure('An unexpected error occurred: ${exception.toString()}');
}
