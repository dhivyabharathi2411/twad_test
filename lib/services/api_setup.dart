import '../api/api_client.dart';
import '../utils/simple_encryption.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiSetup {
  static ApiClient? _apiClient;
  
  static Future<ApiClient> initializeApiClient({
    String? defaultAccessToken,
  }) async {
    if (_apiClient != null) return _apiClient!;
    
    _apiClient = ApiClient();

    if (defaultAccessToken != null) {
      _apiClient!.setDefaultAccessToken(defaultAccessToken);
    }
    
    try {
      final storedToken = await SimpleEncryption.instance.getToken();
      if (storedToken != null && storedToken.isNotEmpty) {
        _apiClient!.updateToken(storedToken);
      }
    } catch (e) {
     //
    }
    
    return _apiClient!;
  }
  
  static ApiClient get apiClient {
    if (_apiClient == null) {
      throw Exception('API client not initialized. Call initializeApiClient() first.');
    }
    return _apiClient!;
  }
  
  /// Update the authentication token for all future requests
  static void updateAuthToken(String token) {
    _apiClient?.updateToken(token);
  }
  
  static void clearAuthToken() {
    _apiClient?.updateToken(null);
  }
  
  /// Set default access token for public endpoints
  static void setDefaultAccessToken(String token) {
    _apiClient?.setDefaultAccessToken(token);
  }
  
  /// Get current encrypt setting from .env
  static bool get isEncryptionEnabled {
    return dotenv.env['API_ENCRYPT_ENABLED']?.toLowerCase() == 'true';
  }
  
  /// Get current encrypt header value
  static String get encryptHeaderValue {
    return isEncryptionEnabled ? 'true' : 'false';
  }
}
