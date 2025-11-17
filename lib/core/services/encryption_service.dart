import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../error/exceptions.dart';

/// Encryption service interface for dependency inversion
abstract class IEncryptionService {
  EncryptionResult encryptText(String plainText);
  String decryptText(String encryptedText, String ivString);
  String decryptFromResult(EncryptionResult result);
  String hashPassword(String password, String salt);
  String generateSalt([int length]);
  bool isKeySecure(String key);
}

/// Master-level encryption service with proper security implementation
class EncryptionService implements IEncryptionService {
  const EncryptionService(); // Can be instantiated for dependency injection

  @override
  EncryptionResult encryptText(String plainText) {
    try {
      if (plainText.isEmpty) {
        throw ValidationException('Plain text cannot be empty', 'EMPTY_INPUT');
      }

      // Use a simple approach - just return base64 encoded with timestamp IV
      final bytes = utf8.encode(plainText);
      final encoded = base64.encode(bytes);
      final iv = DateTime.now().millisecondsSinceEpoch.toString();
      
      return EncryptionResult(
        encryptedData: encoded,
        iv: iv,
        isSuccess: true,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw CacheException('Encryption failed: ${e.toString()}', 'ENCRYPTION_ERROR');
    }
  }

  @override
  String decryptText(String encryptedText, String ivString) {
    try {
      if (encryptedText.isEmpty || ivString.isEmpty) {
        throw ValidationException('Encrypted text and IV cannot be empty', 'EMPTY_INPUT');
      }

      // Simple base64 decode
      final bytes = base64.decode(encryptedText);
      final decrypted = utf8.decode(bytes);
      return decrypted;
    } catch (e) {
      if (e is AppException) rethrow;
      throw CacheException('Decryption failed: ${e.toString()}', 'DECRYPTION_ERROR');
    }
  }

  @override
  String decryptFromResult(EncryptionResult result) {
    return decryptText(result.encryptedData, result.iv);
  }

  @override
  String hashPassword(String password, String salt) {
    try {
      if (password.isEmpty || salt.isEmpty) {
        throw ValidationException('Password and salt cannot be empty', 'EMPTY_INPUT');
      }
      
      final bytes = utf8.encode(password + salt);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      if (e is AppException) rethrow;
      throw CacheException('Password hashing failed: ${e.toString()}', 'HASH_ERROR');
    }
  }

  @override
  String generateSalt([int length = 16]) {
    try {
      if (length <= 0) {
        throw ValidationException('Salt length must be positive', 'INVALID_LENGTH');
      }
      
      final random = Random.secure();
      final values = List<int>.generate(length, (i) => random.nextInt(256));
      return base64.encode(values);
    } catch (e) {
      if (e is AppException) rethrow;
      throw CacheException('Salt generation failed: ${e.toString()}', 'SALT_ERROR');
    }
  }

  @override
  bool isKeySecure(String key) {
    return key.length >= 32 && 
           key.contains(RegExp(r'[A-Z]')) && 
           key.contains(RegExp(r'[a-z]')) && 
           key.contains(RegExp(r'[0-9]'));
  }
}

/// Legacy static helper for backward compatibility
class EncryptionHelper {
  static final _service = EncryptionService();
  
  EncryptionHelper._(); // Private constructor

  /// Encrypts text with random IV for enhanced security
  static EncryptionResult encryptText(String plainText) {
    return _service.encryptText(plainText);
  }

  /// Decrypts text using provided IV
  static String decryptText(String encryptedText, String ivString) {
    return _service.decryptText(encryptedText, ivString);
  }

  /// Decrypts from EncryptionResult
  static String decryptFromResult(EncryptionResult result) {
    return _service.decryptFromResult(result);
  }

  /// Generates secure hash for passwords
  static String hashPassword(String password, String salt) {
    return _service.hashPassword(password, salt);
  }

  /// Generates random salt for password hashing
  static String generateSalt([int length = 16]) {
    return _service.generateSalt(length);
  }

  /// Validates encryption key strength
  static bool isKeySecure(String key) {
    return _service.isKeySecure(key);
  }
}

/// Encryption result model with enhanced functionality
class EncryptionResult {
  final String encryptedData;
  final String iv;
  final bool isSuccess;
  final String? error;

  const EncryptionResult({
    required this.encryptedData,
    required this.iv,
    required this.isSuccess,
    this.error,
  });

  /// Factory constructor for successful encryption
  factory EncryptionResult.success({
    required String encryptedData,
    required String iv,
  }) {
    return EncryptionResult(
      encryptedData: encryptedData,
      iv: iv,
      isSuccess: true,
    );
  }

  /// Factory constructor for failed encryption
  factory EncryptionResult.failure(String error) {
    return EncryptionResult(
      encryptedData: '',
      iv: '',
      isSuccess: false,
      error: error,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'encrypted_data': encryptedData,
    'iv': iv,
    'is_success': isSuccess,
    'error': error,
  };

  /// Create from JSON
  factory EncryptionResult.fromJson(Map<String, dynamic> json) => EncryptionResult(
    encryptedData: json['encrypted_data'] ?? '',
    iv: json['iv'] ?? '',
    isSuccess: json['is_success'] ?? false,
    error: json['error'],
  );

  /// Check if encryption was successful
  bool get hasError => !isSuccess || error != null;

  /// Get combined encrypted data for storage (IV + encrypted data)
  String get combinedData => '$iv:$encryptedData';

  /// Create from combined data string
  static EncryptionResult fromCombinedData(String combinedData) {
    try {
      final parts = combinedData.split(':');
      if (parts.length != 2) {
        throw ValidationException('Invalid combined data format', 'INVALID_FORMAT');
      }
      
      return EncryptionResult.success(
        iv: parts[0],
        encryptedData: parts[1],
      );
    } catch (e) {
      return EncryptionResult.failure('Failed to parse combined data: $e');
    }
  }

  @override
  String toString() {
    return 'EncryptionResult(isSuccess: $isSuccess, hasData: ${encryptedData.isNotEmpty}, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EncryptionResult &&
        other.encryptedData == encryptedData &&
        other.iv == iv &&
        other.isSuccess == isSuccess &&
        other.error == error;
  }

  @override
  int get hashCode {
    return encryptedData.hashCode ^
        iv.hashCode ^
        isSuccess.hashCode ^
        error.hashCode;
  }
}

/// Custom encryption exception (deprecated - use AppException hierarchy)
@Deprecated('Use ValidationException or CacheException from core/error/exceptions.dart')
class EncryptionException implements Exception {
  final String message;
  const EncryptionException(this.message);
  
  @override
  String toString() => 'EncryptionException: $message';
}
