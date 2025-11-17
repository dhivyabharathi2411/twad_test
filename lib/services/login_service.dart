import '../services/auth_api_service.dart';

class LoginService {
  final AuthApiService _authApiService;

  LoginService({AuthApiService? authApiService})
    : _authApiService = authApiService ?? AuthApiService();


  Future<LoginResult> sendOtp(String phoneNumber) async {
    try {
      // Validate phone number format
      if (!_isValidPhoneNumber(phoneNumber)) {
        return LoginResult.failure('Invalid phone number format');
      }

      // Call auth API service
      final result = await _authApiService.sendOtp(phoneNumber);

      if (result['success'] == true) {
        return LoginResult.success(
          message: result['message'] ?? 'OTP sent successfully',
          data: result['data'],
        );
      } else {
        return LoginResult.failure(result['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      return LoginResult.failure('Error sending OTP: ${e.toString()}');
    }
  }

  Future<LoginResult> verifyOtpAndLogin({
    required String phoneNumber,
    required String otp,
    String? deviceId,
    String? deviceToken,
  }) async {
    try {
      // Validate inputs
      if (!_isValidPhoneNumber(phoneNumber)) {
        return LoginResult.failure('Invalid phone number format');
      }

      if (!_isValidOtp(otp)) {
        return LoginResult.failure('Invalid OTP format');
      }

      final result = await _authApiService.login(
        username: phoneNumber,
        otp: otp,
        deviceId: deviceId,
        deviceToken: deviceToken,
      );

      if (result['success'] == true) {
        final responseData = result['data'];
        return LoginResult.success(
          message: result['message'] ?? 'Login successful',
          data: responseData,
          statusCode: responseData?['statuscode'],
          status: responseData?['status'],
        );
      } else {
        return LoginResult.failure(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      return LoginResult.failure('Login error: ${e.toString()}');
    }
  }

  Future<LoginResult> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      // Validate inputs
      if (!_isValidPhoneNumber(phoneNumber)) {
        return LoginResult.failure('Invalid phone number format');
      }

      if (!_isValidOtp(otp)) {
        return LoginResult.failure('Invalid OTP format');
      }

      final result = await _authApiService.verifyOtp(phoneNumber, otp);

      if (result['success'] == true) {
        return LoginResult.success(
          message: result['message'] ?? 'OTP verified successfully',
          data: result['user'],
        );
      } else {
        return LoginResult.failure(
          result['message'] ?? 'OTP verification failed',
        );
      }
    } catch (e) {
      return LoginResult.failure('OTP verification error: ${e.toString()}');
    }
  }

  Future<LoginResult> completeLoginFlow({
    required String phoneNumber,
    required String otp,
    String? deviceId,
    String? deviceToken,
  }) async {
    try {
      final loginResult = await verifyOtpAndLogin(
        phoneNumber: phoneNumber,
        otp: otp,
        deviceId: deviceId,
        deviceToken: deviceToken,
      );

      return loginResult;
    } catch (e) {
      return LoginResult.failure('Complete login flow error: ${e.toString()}');
    }
  }
  bool _isValidPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid length (10-15 digits)
    return digitsOnly.length >= 10 && digitsOnly.length <= 15;
  }

  /// Validate OTP format
  bool _isValidOtp(String otp) {
    // Check if OTP is numeric and 4-8 digits
    final digitsOnly = otp.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length >= 4 &&
        digitsOnly.length <= 8 &&
        digitsOnly == otp;
  }
}

class LoginResult {
  final bool isSuccess;
  final String message;
  final dynamic data;
  final String? status;
  final int? statusCode;
  final String? error;

  const LoginResult._({
    required this.isSuccess,
    required this.message,
    this.data,
    this.status,
    this.statusCode,
    this.error,
  });

  /// Create success result
  factory LoginResult.success({
    required String message,
    dynamic data,
    String? status,
    int? statusCode,
  }) {
    return LoginResult._(
      isSuccess: true,
      message: message,
      data: data,
      status: status,
      statusCode: statusCode,
    );
  }

  /// Create failure result
  factory LoginResult.failure(String message, {String? error}) {
    return LoginResult._(isSuccess: false, message: message, error: error);
  }

  @override
  String toString() {
    return 'LoginResult{isSuccess: $isSuccess, message: $message, data: $data}';
  }
}

/// Usage Examples for LoginService
class LoginServiceExamples {
  static final _loginService = LoginService();

  /// Example: Send OTP
  static Future<void> exampleSendOtp() async {
    final result = await _loginService.sendOtp('+919876543210');

    if (result.isSuccess) {
    } else {
    }
  }

  /// Example: Complete login
  static Future<void> exampleLogin() async {
    final result = await _loginService.verifyOtpAndLogin(
      phoneNumber: '+919876543210',
      otp: '123456',
    );

    if (result.isSuccess) {
    } else {
    }
  }

}
