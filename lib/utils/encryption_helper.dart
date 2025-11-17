import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import '../core/config/secure_config_manager.dart';

/// Master-level encryption helper with secure key management
class EncryptionHelper {
  static Key? _cachedKey;
  
  EncryptionHelper._(); // Private constructor

  /// Get encryption key securely from configuration
  static Future<Key> _getEncryptionKey() async {
    if (_cachedKey != null) return _cachedKey!;
    
    final secureConfig = SecureConfigManager.instance;
    final keyString = await secureConfig.getEncryptionKey();
    
    // Create key from secure string
    final keyBytes = keyString.length == 32 
        ? keyString.codeUnits 
        : base64.decode(keyString);
    
    _cachedKey = Key(Uint8List.fromList(keyBytes.take(32).toList()));
    return _cachedKey!;
  }

  /// Encrypts text with random IV for enhanced security
  static Future<EncryptionResult> encryptText(String plainText) async {
    try {
      if (plainText.isEmpty) {
        throw const EncryptionException('Plain text cannot be empty');
      }

      // Get secure encryption key
      final key = await _getEncryptionKey();
      
      // Generate random IV for each encryption
      final iv = _generateRandomIV();
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      
      return EncryptionResult(
        encryptedData: encrypted.base64,
        iv: iv.base64,
        isSuccess: true,
      );
    } catch (e) {
      throw EncryptionException('Encryption failed: ${e.toString()}');
    }
  }

  /// Decrypts text using provided IV
  static Future<String> decryptText(String encryptedText, String ivString) async {
    try {
      if (encryptedText.isEmpty || ivString.isEmpty) {
        throw const EncryptionException('Encrypted text and IV cannot be empty');
      }

      // Get secure encryption key
      final key = await _getEncryptionKey();
      
      final iv = IV.fromBase64(ivString);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
      
      return decrypted;
    } catch (e) {
      throw EncryptionException('Decryption failed: ${e.toString()}');
    }
  }

  /// Decrypts from EncryptionResult
  static Future<String> decryptFromResult(EncryptionResult result) async {
    return await decryptText(result.encryptedData, result.iv);
  }

  /// Generates secure hash for passwords
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generates random salt for password hashing
  static String generateSalt([int length = 16]) {
    final random = Random.secure();
    final values = List<int>.generate(length, (i) => random.nextInt(256));
    return base64.encode(values);
  }

  /// Generates random IV
  static IV _generateRandomIV() {
    final random = Random.secure();
    final values = Uint8List.fromList(
      List<int>.generate(16, (i) => random.nextInt(256))
    );
    return IV(values);
  }

  /// Validates encryption key strength
  static bool isKeySecure(String key) {
    return key.length >= 32 && 
           key.contains(RegExp(r'[A-Z]')) && 
           key.contains(RegExp(r'[a-z]')) && 
           key.contains(RegExp(r'[0-9]'));
  }
}

/// Encryption result model
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
}

/// Custom encryption exception
class EncryptionException implements Exception {
  final String message;
  const EncryptionException(this.message);
  
  @override
  String toString() => 'EncryptionException: $message';
}
