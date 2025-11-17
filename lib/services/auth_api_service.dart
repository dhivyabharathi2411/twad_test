import 'package:twad/services/user_profile_service.dart';

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../utils/simple_encryption.dart';
import 'api_setup.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiSetup.apiClient;

  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      final requestBody = {"contact_no": phoneNumber};

      final response = await _apiClient.post(
        AppConfig.loginEndpoint,
        data: requestBody,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'OTP sent successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to send OTP',
          'data': response.data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send OTP: $e',
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String otp,
    String? deviceId,
    String? deviceToken,
    String type = 'public',
    String deviceType = 'mobile',
  }) async {
    try {
      // Get encrypt setting from .env file
      final encryptEnabled =
          dotenv.env['API_ENCRYPT_ENABLED']?.toLowerCase() == 'true';

      // Encrypt the OTP before sending
      String encryptedOtp = otp;
      if (encryptEnabled) {
        // Use server-compatible encryption method
        final encryptionResult = await SimpleEncryption.instance.encryptOtp(
          otp,
        );
        if (encryptionResult['success'] == 'true') {
          encryptedOtp = encryptionResult['data'] ?? otp;
        } else {}
      }

      // Prepare form data for login
      final requestBody = {
        "grant_type": "password",
        "username": username,
        "type": type,
        "encrypt": encryptEnabled ? "true" : "false",
        "device_id": deviceId ?? _getDeviceId(),
        "device_token": deviceToken ?? '0',
        "device_type": "Mobile",
        "otp": encryptedOtp,
      };

      final response = await _apiClient.post(
        AppConfig.verifyOtpEndpoint,
        data: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        final accessToken = responseData['access_token'];
        if (accessToken != null) {
          // Store token and the entire response data as user dat
          _apiClient.clearCache();

          _apiClient.updateToken(accessToken);

          return {
            'success': true,
            'message': responseData['message'] ?? 'Loggedin Sucessfully',
            'data': responseData,
          };
        } else {
          return {
            'success': false,
            'message': 'Login response missing access_token.',
            'data': responseData,
          };
        }
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Login failed',
          'data': response.data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: $e',
        'error': e.toString(),
      };
    }
  }

  /// Get device ID (simple implementation)
  String _getDeviceId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final encryptEnabled =
          dotenv.env['API_ENCRYPT_ENABLED']?.toLowerCase() == 'true';

      // Encrypt the OTP before sending
      String encryptedOtp = otp;
      if (encryptEnabled) {
        // Use server-compatible encryption method
        final encryptionResult = await SimpleEncryption.instance.encryptOtp(
          otp,
        );
        if (encryptionResult['success'] == 'true') {
          encryptedOtp = encryptionResult['data'] ?? otp;
        } else {}
      }

      final response = await _apiClient.post(
        AppConfig.verifyOtpEndpoint,
        data: {
          'phone_number': phoneNumber,
          'otp': encryptedOtp, // Now properly encrypted
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Get token from response
        final authToken = response.data['token'];
        final userData = response.data['user'];

        if (authToken != null) {
          // Store login data using simple encryption
          final Map<String, dynamic> userLoginData = Map.from(userData);
          userLoginData['phoneNumber'] = phoneNumber;

          await SimpleUsage.login(
            authToken: authToken,
            userData: userLoginData,
          );

          // Update API client token
          _apiClient.updateToken(authToken);

          return {
            'success': true,
            'message': 'Login successful',
            'user': userData,
          };
        }
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'OTP verification failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'OTP verification failed: $e',
        'error': e.toString(),
      };
    }
  }

  /// Validate OTP without logging in
  Future<Map<String, dynamic>> validateOtp(
    String phoneNumber,
    String otp,
  ) async {
    try {
      // Get encrypt setting from .env file
      final encryptEnabled =
          dotenv.env['API_ENCRYPT_ENABLED']?.toLowerCase() == 'true';

      // Encrypt the OTP before sending
      if (encryptEnabled) {
        final encryptionResult = await SimpleEncryption.instance.encryptOtp(
          otp,
        );
        if (encryptionResult['success'] == 'true') {
          // encryptedOtp = encryptionResult['data'] ?? otp;
        } else {}
      }

      final response = await _apiClient.post(
        AppConfig.validateOtp,
        data: {'contact_no': phoneNumber, 'otp': otp},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'OTP validated successfully',
          'data': response.data,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'OTP validation failed',
        'data': response.data,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'OTP validation failed: $e',
        'error': e.toString(),
      };
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String contactNo,
    required String email,
    required String otp,
  }) async {
    try {
      final requestBody = {
        'public_name': name,
        'public_contactno': contactNo,
        'public_emailid': email,
        'public_password': otp,
        'origin': 'Mobile',
      };

      final response = await _apiClient.post(
        AppConfig.createAccountEndpoint,
        data: requestBody,
        options: Options(extra: {'no_encrypt_header': true}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Registration successful',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Registration failed',
          'data': response.data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: $e',
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _apiClient.get(endpoint, params: params);
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'GET request failed: $e',
        'error': e.toString(),
      };
    }
  }

  /// Generic POST request
  Future<Map<String, dynamic>> post(String endpoint, {dynamic data}) async {
    try {
      final response = await _apiClient.post(endpoint, data: data);
      return {
        'success': true,
        'data': response.data,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'POST request failed: $e',
        'error': e.toString(),
      };
    }
  }
}

/// Usage examples for AuthApiService
class AuthApiUsageExamples {
  static final _authApiService = AuthApiService();

  static Future<bool> loginFlow(String phoneNumber, String otp) async {
    final otpResult = await _authApiService.sendOtp(phoneNumber);
    if (!otpResult['success']) {
      return false;
    }
    final verifyResult = await _authApiService.verifyOtp(phoneNumber, otp);
    if (verifyResult['success']) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> getUserData() async {
    final userProfileService = UserProfileService();
    final result = await userProfileService.getUserProfile();
    if (result['success']) {
    } else {}
  }
}
