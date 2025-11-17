import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Simple encryption utility for TWAD app - using .env configuration
class SimpleEncryption {
  static SimpleEncryption? _instance;
  static SimpleEncryption get instance => _instance ??= SimpleEncryption._();
  SimpleEncryption._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  late Encrypter _encrypter;
  late IV _fixedIV;
  bool _initialized = false;

  /// Initialize encryption (call once in main.dart)
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await dotenv.load(fileName: ".env");
      
      // Get encryption key from .env
      String keyString = dotenv.env['ENCRYPTION_KEY'] ?? 'smar@nexusglobalsolutions1234567';
      
      // Get IV from .env
      String ivString = dotenv.env['ENCRYPTION_IV'] ?? 'smar@nexus123456';
      
      // Ensure proper lengths
      if (keyString.length < 32) {
        keyString = keyString.padRight(32, '0');
      } else if (keyString.length > 32) {
        keyString = keyString.substring(0, 32);
      }
      
      if (ivString.length < 16) {
        ivString = ivString.padRight(16, '0');
      } else if (ivString.length > 16) {
        ivString = ivString.substring(0, 16);
      }
      
      final keyBytes = utf8.encode(keyString);
      final ivBytes = utf8.encode(ivString);
      
      final key = Key(Uint8List.fromList(keyBytes));
      _fixedIV = IV(Uint8List.fromList(ivBytes));
      _encrypter = Encrypter(AES(key));
      _initialized = true;

    } catch (e) {
      // Fallback setup
      final key = Key.fromSecureRandom(32);
      _fixedIV = IV.fromSecureRandom(16);
      _encrypter = Encrypter(AES(key));
      _initialized = true;
    }
  }
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token_data');
    await _storage.delete(key: 'auth_token_iv');
  }
  /// Encrypt text using .env configuration
  Future<Map<String, String>> encrypt(String text) async {
    if (!_initialized) await initialize();
    
    try {
      final encrypted = _encrypter.encrypt(text, iv: _fixedIV);
      
      return {
        'data': encrypted.base64,
        'iv': _fixedIV.base64,
        'success': 'true',
      };
    } catch (e) {
      return {
        'success': 'false',
        'error': e.toString(),
      };
    }
  }

  /// Encrypt OTP with the exact method that matches server expectations
  Future<Map<String, String>> encryptOtp(String otp) async {
    if (!_initialized) await initialize();
    
    try {
      // Use exact .env values (these are confirmed to work)
      final keyString = dotenv.env['ENCRYPTION_KEY'] ?? 'smar@nexusglobalsolutions1234567';
      final ivString = dotenv.env['ENCRYPTION_IV'] ?? 'smar@nexus123456';
      
      // Ensure proper lengths (32 bytes key, 16 bytes IV)
      String keyPadded = keyString.length >= 32 ? keyString.substring(0, 32) : keyString.padRight(32, '0');
      String ivPadded = ivString.length >= 16 ? ivString.substring(0, 16) : ivString.padRight(16, '0');
      
      final keyBytes = utf8.encode(keyPadded);
      final ivBytes = utf8.encode(ivPadded);
      
      final key = Key(Uint8List.fromList(keyBytes));
      final iv = IV(Uint8List.fromList(ivBytes));
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      
      final encrypted = encrypter.encrypt(otp, iv: iv);
      final result = encrypted.base64;
      
      return {
        'data': result,
        'iv': base64Encode(ivBytes),
        'success': 'true',
        'method': 'server-compatible',
      };
    } catch (e) {
      return {
        'success': 'false',
        'error': e.toString(),
        'method': 'server-compatible',
      };
    }
  }

  /// Encrypt text using CryptoJS-compatible method with .env values
  Future<Map<String, String>> encryptCryptoJS(String text) async {
    if (!_initialized) await initialize();
    
    try {
      // Use .env values exactly as they would be used in CryptoJS
      final keyString = dotenv.env['ENCRYPTION_KEY'] ?? 'smar@nexusglobalsolutions1234567';
      final ivString = dotenv.env['ENCRYPTION_IV'] ?? 'smar@nexus123456';
      
      // Pad/truncate key to exactly 32 bytes (256 bits)
      String keyPadded;
      if (keyString.length > 32) {
        keyPadded = keyString.substring(0, 32);
      } else {
        keyPadded = keyString.padRight(32, '0');
      }
      
      // Pad/truncate IV to exactly 16 bytes (128 bits)  
      String ivPadded;
      if (ivString.length > 16) {
        ivPadded = ivString.substring(0, 16);
      } else {
        ivPadded = ivString.padRight(16, '0');
      }
      
      // Convert to bytes
      final keyBytes = utf8.encode(keyPadded);
      final ivBytes = utf8.encode(ivPadded);
      
      // Create encrypter
      final key = Key(Uint8List.fromList(keyBytes));
      final iv = IV(Uint8List.fromList(ivBytes));
      
      // Use AES-256-CBC with PKCS7 padding (CryptoJS default)
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      
      // Encrypt
      final encrypted = encrypter.encrypt(text, iv: iv);
      final result = encrypted.base64;
      
      return {
        'data': result,
        'iv': base64Encode(ivBytes),
        'success': 'true',
        'method': 'cryptojs-flutter-encrypt',
      };
    } catch (e) {
      return {
        'success': 'false',
        'error': e.toString(),
        'method': 'cryptojs-flutter-encrypt',
      };
    }
  }

  /// Decrypt text using CryptoJS-compatible method with .env values
  Future<String?> decryptCryptoJS(String encryptedData, String ivString) async {
    if (!_initialized) await initialize();
    
    try {
      // Use .env values exactly like in encryptCryptoJS
      final keyString = dotenv.env['ENCRYPTION_KEY'] ?? 'smar@nexusglobalsolutions1234567';
      final envIvString = dotenv.env['ENCRYPTION_IV'] ?? 'smar@nexus123456';
      
      // Pad/truncate key to exactly 32 bytes (same as encryptCryptoJS)
      final keyPadded = keyString.length >= 32 ? keyString.substring(0, 32) : keyString.padRight(32, '0');
      
      // Use the IV from .env (not the parameter), pad/truncate to exactly 16 bytes
      final ivPadded = envIvString.length >= 16 ? envIvString.substring(0, 16) : envIvString.padRight(16, '0');
      
      // Create key and IV exactly like encryptCryptoJS
      final keyBytes = utf8.encode(keyPadded);
      final ivBytes = utf8.encode(ivPadded);
      final key = Key(Uint8List.fromList(keyBytes));
      final iv = IV(Uint8List.fromList(ivBytes));
      
      final encrypted = Encrypted.fromBase64(encryptedData);
      
      // Use same AES settings as encryptCryptoJS
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      final result = encrypter.decrypt(encrypted, iv: iv);
      
      return result;
    } catch (e) {
      return null;
    }
  }

  /// Decrypt text using .env configuration
  Future<String?> decrypt(String encryptedData, String ivString) async {
    if (!_initialized) await initialize();
    
    try {
      final iv = IV.fromBase64(ivString);
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      return null;
    }
  }


  /// Store auth token
  Future<void> storeToken(String token) async {
    final result = await encrypt(token);
    if (result['success'] == 'true') {
      await _storage.write(key: 'auth_token_data', value: result['data']);
      await _storage.write(key: 'auth_token_iv', value: result['iv']);
    }
  }

  /// Get auth token
  Future<String?> getToken() async {
    try {
      final data = await _storage.read(key: 'auth_token_data');
      final iv = await _storage.read(key: 'auth_token_iv');
      
      if (data != null && iv != null) {
        return await decrypt(data, iv);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Store user data
  Future<void> storeUserData(Map<String, dynamic> userData) async {
    final jsonString = jsonEncode(userData);
    final result = await encrypt(jsonString);
    
    if (result['success'] == 'true') {
      await _storage.write(key: 'user_data', value: result['data']);
      await _storage.write(key: 'user_data_iv', value: result['iv']);
    }
  }

  /// Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final data = await _storage.read(key: 'user_data');
      final iv = await _storage.read(key: 'user_data_iv');
      
      if (data != null && iv != null) {
        final decrypted = await decrypt(data, iv);
        if (decrypted != null) {
          final Map<String, dynamic> userData = jsonDecode(decrypted);
          return userData;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Logout (clear all data)
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token_data');
    await _storage.delete(key: 'auth_token_iv');
    await _storage.delete(key: 'user_data');
    await _storage.delete(key: 'user_data_iv');
  }

  /// Hash password for storage
  String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate salt
  String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(saltBytes);
  }

  /// Store encrypted password
  Future<void> storePassword(String password) async {
    final salt = generateSalt();
    final hashedPassword = hashPassword(password, salt);
    
    await _storage.write(key: 'password_hash', value: hashedPassword);
    await _storage.write(key: 'password_salt', value: salt);
  }

  /// Verify password
  Future<bool> verifyPassword(String password) async {
    try {
      final storedHash = await _storage.read(key: 'password_hash');
      final salt = await _storage.read(key: 'password_salt');
      
      if (storedHash == null || salt == null) return false;
      
      final computedHash = hashPassword(password, salt);
      return computedHash == storedHash;
    } catch (e) {
      return false;
    }
  }
}

/// Simple usage class for easy access
class SimpleUsage {
  static final _encryption = SimpleEncryption.instance;

  /// Initialize encryption system
  static Future<void> initialize() async {
    await _encryption.initialize();
  }

  /// Login example
  static Future<bool> login({
    required String authToken,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // Store token and user data
      await _encryption.storeToken(authToken);
      await _encryption.storeUserData(userData);
    
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check login status
  static Future<bool> checkLogin() async {
    return await _encryption.isLoggedIn();
  }

  /// Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    return await _encryption.getUserData();
  }

  /// Logout
  static Future<void> logout() async {
    await _encryption.logout();
  }

  /// Encrypt any text using .env configuration
  static Future<Map<String, String>> encryptText(String text) async {
    return await _encryption.encrypt(text);
  }

  /// Encrypt text using CryptoJS-compatible method with .env values
  static Future<Map<String, String>> encryptTextCryptoJS(String text) async {
    return await _encryption.encryptCryptoJS(text);
  }

  /// Decrypt text using .env configuration
  static Future<String?> decryptText(String encryptedData, String iv) async {
    return await _encryption.decrypt(encryptedData, iv);
  }

  /// Decrypt text using CryptoJS-compatible method with .env values
  static Future<String?> decryptTextCryptoJS(String encryptedData, String iv) async {
    return await _encryption.decryptCryptoJS(encryptedData, iv);
  }
}

