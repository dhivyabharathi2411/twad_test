import '../../utils/encryption_helper.dart';
import '../config/secure_config_manager.dart';

/// High-level encryption service for easy app integration
class AppEncryptionService {
  static AppEncryptionService? _instance;
  static AppEncryptionService get instance => _instance ??= AppEncryptionService._();
  
  AppEncryptionService._();

  /// Encrypt user data (passwords, tokens, sensitive info)
  Future<Map<String, String>> encryptUserData(String data) async {
    try {
      final result = await EncryptionHelper.encryptText(data);
      
      if (!result.isSuccess) {
        throw Exception('Encryption failed: ${result.error}');
      }
      
      return {
        'encrypted': result.encryptedData,
        'iv': result.iv,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      };
    } catch (e) {
      throw Exception('Failed to encrypt user data: $e');
    }
  }

  /// Decrypt user data
  Future<String> decryptUserData(Map<String, String> encryptedData) async {
    try {
      final encrypted = encryptedData['encrypted'];
      final iv = encryptedData['iv'];
      
      if (encrypted == null || iv == null) {
        throw Exception('Invalid encrypted data format');
      }
      
      return await EncryptionHelper.decryptText(encrypted, iv);
    } catch (e) {
      throw Exception('Failed to decrypt user data: $e');
    }
  }

  /// Encrypt and store in secure storage
  Future<void> encryptAndStore(String key, String data) async {
    try {
      final secureConfig = SecureConfigManager.instance;
      final encryptedData = await encryptUserData(data);
      
      // Store as JSON string in secure storage
      final jsonData = {
        'encrypted': encryptedData['encrypted']!,
        'iv': encryptedData['iv']!,
        'timestamp': encryptedData['timestamp']!,
      };
      
      await secureConfig.storeSecure(key, jsonData.toString());
    } catch (e) {
      throw Exception('Failed to encrypt and store: $e');
    }
  }

  /// Retrieve and decrypt from secure storage
  Future<String?> retrieveAndDecrypt(String key) async {
    try {
      final secureConfig = SecureConfigManager.instance;
      final storedData = await secureConfig.getSecure(key);
      
      if (storedData == null) return null;
      
      // Parse stored JSON data
      final Map<String, dynamic> jsonData = {};
      // Simple parsing for stored format
      final parts = storedData.replaceAll('{', '').replaceAll('}', '').split(', ');
      for (final part in parts) {
        final keyValue = part.split(': ');
        if (keyValue.length == 2) {
          jsonData[keyValue[0].trim()] = keyValue[1].trim();
        }
      }
      
      final encryptedData = {
        'encrypted': jsonData['encrypted']?.toString(),
        'iv': jsonData['iv']?.toString(),
        'timestamp': jsonData['timestamp']?.toString(),
      };
      
      return await decryptUserData({
        'encrypted': encryptedData['encrypted']!,
        'iv': encryptedData['iv']!,
      });
    } catch (e) {
      throw Exception('Failed to retrieve and decrypt: $e');
    }
  }

  /// Encrypt password with salt
  Future<Map<String, String>> encryptPassword(String password) async {
    try {
      final salt = EncryptionHelper.generateSalt();
      final hashedPassword = EncryptionHelper.hashPassword(password, salt);
      
      return {
        'hash': hashedPassword,
        'salt': salt,
        'algorithm': 'SHA-256',
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      };
    } catch (e) {
      throw Exception('Failed to encrypt password: $e');
    }
  }

  /// Verify password against stored hash
  bool verifyPassword(String password, Map<String, String> storedData) {
    try {
      final storedHash = storedData['hash'];
      final salt = storedData['salt'];
      
      if (storedHash == null || salt == null) return false;
      
      final computedHash = EncryptionHelper.hashPassword(password, salt);
      return computedHash == storedHash;
    } catch (e) {
      return false;
    }
  }

  /// Encrypt auth token for storage
  Future<void> storeAuthToken(String token) async {
    await encryptAndStore('auth_token', token);
  }

  /// Decrypt and retrieve auth token
  Future<String?> getAuthToken() async {
    return await retrieveAndDecrypt('auth_token');
  }

  /// Clear stored auth token
  Future<void> clearAuthToken() async {
    final secureConfig = SecureConfigManager.instance;
    await secureConfig.deleteSecure('auth_token');
  }

  /// Encrypt user credentials
  Future<void> storeUserCredentials({
    required String userId,
    required String phoneNumber,
    String? email,
  }) async {
    final userData = {
      'userId': userId,
      'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    
    await encryptAndStore('user_credentials', userData.toString());
  }

  /// Decrypt and retrieve user credentials
  Future<Map<String, String>?> getUserCredentials() async {
    try {
      final credentialsString = await retrieveAndDecrypt('user_credentials');
      if (credentialsString == null) return null;
      
      // Parse the credentials string back to map
      final Map<String, String> credentials = {};
      final parts = credentialsString.replaceAll('{', '').replaceAll('}', '').split(', ');
      
      for (final part in parts) {
        final keyValue = part.split(': ');
        if (keyValue.length == 2) {
          credentials[keyValue[0].trim()] = keyValue[1].trim();
        }
      }
      
      return credentials;
    } catch (e) {
      return null;
    }
  }

  /// Encrypt and store app settings
  Future<void> storeAppSettings(Map<String, dynamic> settings) async {
    await encryptAndStore('app_settings', settings.toString());
  }

  /// Decrypt and retrieve app settings
  Future<Map<String, dynamic>?> getAppSettings() async {
    try {
      final settingsString = await retrieveAndDecrypt('app_settings');
      if (settingsString == null) return null;
      
      // Simple parsing - in production, use proper JSON serialization
      return {'raw': settingsString};
    } catch (e) {
      return null;
    }
  }
}
