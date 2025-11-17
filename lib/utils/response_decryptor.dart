import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'simple_encryption.dart';

/// Master-level response decryption utility for scalable and reusable architecture
class ResponseDecryptor {
  static final ResponseDecryptor _instance = ResponseDecryptor._internal();
  factory ResponseDecryptor() => _instance;
  ResponseDecryptor._internal();

  static ResponseDecryptor get instance => _instance;

  /// Decrypt API response data if encryption is enabled
  Future<ResponseDecryptionResult> decryptResponse(dynamic responseData) async {
    try {
      // Check if encryption is enabled from .env
      if (!_isEncryptionEnabled()) {
        return ResponseDecryptionResult.success(responseData);
      }

      // If data is null or not a string, return as-is
      if (responseData == null || responseData is! String) {
        return ResponseDecryptionResult.success(responseData);
      }

      // Attempt decryption using .env IV directly
      final decrypted = await SimpleEncryption.instance.decryptCryptoJS(
        responseData,
        'unused_iv_parameter', // The method uses .env IV internally
      );

      if (decrypted == null) {
        return ResponseDecryptionResult.error('Decryption failed: Invalid encrypted data');
      }

      // Try to parse as JSON
      try {
        final jsonData = jsonDecode(decrypted);
        return ResponseDecryptionResult.success(jsonData);
      } catch (e) {
        // If not JSON, return the decrypted string
        return ResponseDecryptionResult.success(decrypted);
      }
    } catch (e) {
      return ResponseDecryptionResult.error('Decryption error: ${e.toString()}');
    }
  }

  /// Batch decrypt multiple response data items
  Future<List<ResponseDecryptionResult>> decryptBatch(List<dynamic> responseDataList) async {
    final results = <ResponseDecryptionResult>[];
    for (final data in responseDataList) {
      results.add(await decryptResponse(data));
    }
    return results;
  }

  /// Check if encryption is enabled from .env configuration
  bool _isEncryptionEnabled() {
    final encryptEnabled = dotenv.env['API_ENCRYPT_ENABLED']?.toLowerCase();
    return encryptEnabled == 'true' || encryptEnabled == '1';
  }

  /// Extract typed data from decryption result with error handling
  T? extractData<T>(ResponseDecryptionResult result) {
    if (!result.isSuccess || result.data == null) {
      return null;
    }
    
    try {
      return result.data as T;
    } catch (e) {
      return null;
    }
  }
}

/// Result wrapper for decryption operations
class ResponseDecryptionResult {
  final dynamic data;
  final String? error;
  final bool isSuccess;

  ResponseDecryptionResult.success(this.data) 
    : error = null, 
      isSuccess = true;

  ResponseDecryptionResult.error(this.error) 
    : data = null, 
      isSuccess = false;
}
