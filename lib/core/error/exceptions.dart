/// Base class for all exceptions in the application
abstract class AppException implements Exception {
  final String message;
  final String code;
  final dynamic originalError;
  
  const AppException(
    this.message, 
    this.code, 
    [this.originalError]
  );
  
  @override
  String toString() => 'AppException: $message (Code: $code)';
}

/// Server-related exceptions (5xx errors)
class ServerException extends AppException {
  const ServerException(super.message, super.code, [super.originalError]);
  
  factory ServerException.internalServerError([dynamic originalError]) =>
      ServerException(
        'Internal server error occurred',
        'SERVER_ERROR',
        originalError,
      );
  
  factory ServerException.serviceUnavailable([dynamic originalError]) =>
      ServerException(
        'Service temporarily unavailable',
        'SERVICE_UNAVAILABLE',
        originalError,
      );
}

/// Client-related exceptions (4xx errors)
class ClientException extends AppException {
  const ClientException(super.message, super.code, [super.originalError]);
  
  factory ClientException.badRequest([dynamic originalError]) =>
      ClientException(
        'Invalid request data',
        'BAD_REQUEST',
        originalError,
      );
  
  factory ClientException.unauthorized([dynamic originalError]) =>
      ClientException(
        'Authentication required',
        'UNAUTHORIZED',
        originalError,
      );
  
  factory ClientException.forbidden([dynamic originalError]) =>
      ClientException(
        'Access denied',
        'FORBIDDEN',
        originalError,
      );
  
  factory ClientException.notFound([dynamic originalError]) =>
      ClientException(
        'Resource not found',
        'NOT_FOUND',
        originalError,
      );
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, super.code, [super.originalError]);
  
  factory NetworkException.noConnection([dynamic originalError]) =>
      NetworkException(
        'No internet connection available',
        'NO_CONNECTION',
        originalError,
      );
  
  factory NetworkException.timeout([dynamic originalError]) =>
      NetworkException(
        'Request timeout occurred',
        'TIMEOUT',
        originalError,
      );
  
  factory NetworkException.connectionFailed([dynamic originalError]) =>
      NetworkException(
        'Failed to connect to server',
        'CONNECTION_FAILED',
        originalError,
      );
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException(super.message, super.code, [super.originalError]);
  
  factory CacheException.notFound([dynamic originalError]) =>
      CacheException(
        'Data not found in cache',
        'CACHE_NOT_FOUND',
        originalError,
      );
  
  factory CacheException.writeError([dynamic originalError]) =>
      CacheException(
        'Failed to write to cache',
        'CACHE_WRITE_ERROR',
        originalError,
      );
}

/// Validation-related exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, super.code, [super.originalError]);
  
  factory ValidationException.invalidPhoneNumber([dynamic originalError]) =>
      ValidationException(
        'Invalid phone number format',
        'INVALID_PHONE',
        originalError,
      );
  
  factory ValidationException.invalidOTP([dynamic originalError]) =>
      ValidationException(
        'Invalid OTP format',
        'INVALID_OTP',
        originalError,
      );
  
  factory ValidationException.emptyField(String fieldName, [dynamic originalError]) =>
      ValidationException(
        '$fieldName cannot be empty',
        'EMPTY_FIELD',
        originalError,
      );
}
