import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Ultra-fast encryption service with aggressive caching for dashboard performance
class FastEncryptionService {
  static final FastEncryptionService _instance = FastEncryptionService._internal();
  factory FastEncryptionService() => _instance;
  FastEncryptionService._internal();

  // Cached encryption components
  static Encrypter? _cachedEncrypter;
  static IV? _cachedIV;
  static bool? _encryptionEnabled;
  static bool _initialized = false;

  /// Initialize encryption components once
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Cache encryption enabled flag
      _encryptionEnabled = dotenv.env['API_ENCRYPT_ENABLED']?.toLowerCase() == 'true';
      
      if (_encryptionEnabled!) {
        // Get encryption settings from .env
        final encryptionKey = dotenv.env['ENCRYPTION_KEY'];
        final encryptionIv = dotenv.env['ENCRYPTION_IV'];

        if (encryptionKey != null && encryptionIv != null) {
          // Create encryption components once and cache them
          final key = Key.fromBase64(encryptionKey);
          _cachedIV = IV.fromBase64(encryptionIv);
          _cachedEncrypter = Encrypter(AES(key));
        }
      }

      _initialized = true;
    } catch (e) {
      _initialized = true; // Mark as initialized even if it fails
    }
  }

  /// Ultra-fast encryption - uses cached components
  static Future<Map<String, dynamic>> encryptFast(String data) async {
    await initialize();

    if (!_encryptionEnabled! || _cachedEncrypter == null || _cachedIV == null) {
      return {
        'success': 'false',
        'data': data,
      };
    }

    try {
      final encrypted = _cachedEncrypter!.encrypt(data, iv: _cachedIV!);
      return {
        'success': 'true',
        'data': encrypted.base64,
      };
    } catch (e) {
      return {
        'success': 'false',
        'data': data,
      };
    }
  }

  /// Ultra-fast decryption - uses cached components
  static Future<String?> decryptFast(String encryptedData) async {
    await initialize();

    if (!_encryptionEnabled! || _cachedEncrypter == null || _cachedIV == null) {
      return encryptedData;
    }

    try {
      final encrypted = Encrypted.fromBase64(encryptedData);
      return _cachedEncrypter!.decrypt(encrypted, iv: _cachedIV!);
    } catch (e) {
      return encryptedData;
    }
  }

  /// Check if encryption is enabled (cached)
  static bool get isEncryptionEnabled {
    return _encryptionEnabled ?? false;
  }
}
