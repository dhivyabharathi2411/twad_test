import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../error/exceptions.dart';

/// Master-level secure configuration manager
class SecureConfigManager {
  static SecureConfigManager? _instance;
  static SecureConfigManager get instance => _instance ??= SecureConfigManager._();
  
  SecureConfigManager._();

  // Secure storage for sensitive keys
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  bool _isInitialized = false;
  String? _runtimeEncryptionKey;

  /// Initialize configuration from environment and secure storage
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load environment variables
      await dotenv.load(fileName: ".env");
      
      // Generate or retrieve runtime encryption key
      await _initializeEncryptionKey();
      
      _isInitialized = true;
    } catch (e) {
      throw CacheException(
        'Failed to initialize secure configuration: ${e.toString()}',
        'CONFIG_INIT_ERROR',
      );
    }
  }

  /// Get encryption key securely
  Future<String> getEncryptionKey() async {
    await _ensureInitialized();
    
    if (_runtimeEncryptionKey == null) {
      throw CacheException(
        'Encryption key not available',
        'KEY_NOT_FOUND',
      );
    }
    
    return _runtimeEncryptionKey!;
  }

  /// Get environment variable with fallback
  String getEnvVar(String key, {String? defaultValue}) {
    _ensureInitializedSync();
    
    final value = dotenv.env[key] ?? defaultValue;
    if (value == null) {
      throw ValidationException(
        'Required environment variable $key not found',
        'ENV_VAR_MISSING',
      );
    }
    
    return value;
  }

  /// Get boolean environment variable
  bool getEnvBool(String key, {bool defaultValue = false}) {
    final value = dotenv.env[key]?.toLowerCase();
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Get integer environment variable
  int getEnvInt(String key, {int? defaultValue}) {
    final value = dotenv.env[key];
    if (value == null) {
      if (defaultValue != null) return defaultValue;
      throw ValidationException(
        'Required integer environment variable $key not found',
        'ENV_VAR_MISSING',
      );
    }
    
    final parsed = int.tryParse(value);
    if (parsed == null) {
      throw ValidationException(
        'Environment variable $key is not a valid integer: $value',
        'ENV_VAR_INVALID',
      );
    }
    
    return parsed;
  }

  /// Store sensitive data in secure storage
  Future<void> storeSecure(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw CacheException(
        'Failed to store secure data: ${e.toString()}',
        'SECURE_STORE_ERROR',
      );
    }
  }

  /// Retrieve sensitive data from secure storage
  Future<String?> getSecure(String key) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw CacheException(
        'Failed to retrieve secure data: ${e.toString()}',
        'SECURE_READ_ERROR',
      );
    }
  }

  /// Delete sensitive data from secure storage
  Future<void> deleteSecure(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw CacheException(
        'Failed to delete secure data: ${e.toString()}',
        'SECURE_DELETE_ERROR',
      );
    }
  }

  /// Clear all secure storage (use with caution)
  Future<void> clearAllSecure() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw CacheException(
        'Failed to clear secure storage: ${e.toString()}',
        'SECURE_CLEAR_ERROR',
      );
    }
  }

  /// Initialize encryption key with enhanced security
  Future<void> _initializeEncryptionKey() async {
    const keyName = 'app_encryption_key';
    
    try {
      // Try to get existing key from secure storage
      String? storedKey = await _secureStorage.read(key: keyName);
      
      if (storedKey != null && _isValidEncryptionKey(storedKey)) {
        _runtimeEncryptionKey = storedKey;
        return;
      }
      
      // Generate new secure key if none exists or invalid
      final newKey = _generateSecureKey();
      await _secureStorage.write(key: keyName, value: newKey);
      _runtimeEncryptionKey = newKey;
      
      if (kDebugMode) {
      }
      
    } catch (e) {
      // Fallback to environment key if secure storage fails
      final envKey = dotenv.env['ENCRYPTION_KEY'];
      if (envKey != null && _isValidEncryptionKey(envKey)) {
        _runtimeEncryptionKey = envKey;
        if (kDebugMode) {
        }
      } else {
        throw CacheException(
          'Failed to initialize encryption key: ${e.toString()}',
          'KEY_INIT_ERROR',
        );
      }
    }
  }

  /// Generate cryptographically secure encryption key
  String _generateSecureKey() {
    const int keyLength = 32; // 256 bits
    final random = Random.secure();
    final bytes = List<int>.generate(keyLength, (_) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Validate encryption key strength
  bool _isValidEncryptionKey(String key) {
    if (key.length < 32) return false;
    
    // Check if it's base64 encoded
    try {
      final decoded = base64.decode(key);
      return decoded.length >= 24; // At least 192 bits
    } catch (e) {
      // If not base64, check if it's a valid string key
      return key.length >= 32 &&
             key.contains(RegExp(r'[A-Z]')) &&
             key.contains(RegExp(r'[a-z]')) &&
             key.contains(RegExp(r'[0-9]'));
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  void _ensureInitializedSync() {
    if (!_isInitialized) {
      throw CacheException(
        'SecureConfigManager not initialized. Call initialize() first.',
        'NOT_INITIALIZED',
      );
    }
  }

  /// Get configuration for different environments
  bool get isProduction => getEnvVar('ENVIRONMENT', defaultValue: 'development') == 'production';
  bool get isDebugMode => getEnvBool('DEBUG_MODE', defaultValue: false);
  bool get useMockData => getEnvBool('USE_MOCK_DATA', defaultValue: false);
  
  String get apiBaseUrl => getEnvVar('API_BASE_URL', defaultValue: 'https://api.twad.com');
  int get apiTimeout => getEnvInt('API_TIMEOUT', defaultValue: 30000);
  String get apiKey => getEnvVar('API_KEY', defaultValue: '');
  
  int get sessionTimeout => getEnvInt('SESSION_TIMEOUT', defaultValue: 30000);
  int get passwordSaltLength => getEnvInt('PASSWORD_SALT_LENGTH', defaultValue: 16);
  int get hashIterations => getEnvInt('HASH_ITERATIONS', defaultValue: 10000);
}
