import 'package:twad/services/logout_service.dart';
import 'package:twad/services/user_profile_service.dart';

import '../../../core/error/exceptions.dart';
import '../../../services/auth_api_service.dart';
import '../../models/auth_token_model.dart';
import '../../models/user_model.dart';

/// Remote API data source interface
abstract class RemoteDataSource {
  Future<AuthTokenModel> loginWithOtp({
    required String phoneNumber,
    required String otp,
  });

  Future<bool> sendOtp({required String phoneNumber});
  Future<UserModel> getCurrentUser();
  Future<AuthTokenModel> refreshToken(String refreshToken);
  Future<bool> verifyOtp({required String phoneNumber, required String otp});
  Future<bool> register({
    required String name,
    required String contactNo,
    required String email,
    required String otp,
  });
  Future<bool> logout();
}

/// Remote API data source implementation
class RemoteDataSourceImpl implements RemoteDataSource {
  final AuthApiService _authApiService;

  const RemoteDataSourceImpl({required AuthApiService apiService})
    : _authApiService = apiService;

  @override
  Future<AuthTokenModel> loginWithOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      // Use the configured AuthApiService which has encryption and proper setup
      final result = await _authApiService.login(
        username: phoneNumber,
        otp: otp,
      );

      if (result['success'] == true) {
        // Convert the response data to AuthTokenModel
        final data = result['data'];
        return AuthTokenModel.fromJson(data);
      } else {
        throw ServerException(
          result['message'] ?? 'Login failed',
          'LOGIN_FAILED',
          result['error'],
        );
      }
    } catch (e) {
      throw ServerException(
        'Failed to login: ${e.toString()}',
        'LOGIN_FAILED',
        e,
      );
    }
  }

  @override
  Future<bool> sendOtp({required String phoneNumber}) async {
    try {
      // Use the configured AuthApiService which has encryption and proper setup
      final result = await _authApiService.sendOtp(phoneNumber);

      // The ApiService returns a Map<String, dynamic> with success info
      return result['success'] == true;
    } catch (e) {
      throw ServerException(
        'Failed to send OTP: ${e.toString()}',
        'SEND_OTP_FAILED',
        e,
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      // Use the configured AuthApiService
      final userProfileService = UserProfileService();
      final result = await userProfileService.getUserProfile();

      if (result['success'] == true) {
        return UserModel.fromJson(result['data']);
      } else {
        throw ServerException(
          result['message'] ?? 'Get user failed',
          'GET_USER_FAILED',
          result['error'],
        );
      }
    } catch (e) {
      throw ServerException(
        'Failed to get user: ${e.toString()}',
        'GET_USER_FAILED',
        e,
      );
    }
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    try {
      // Use the configured AuthApiService for refresh token
      final result = await _authApiService.post(
        '/refresh-token',
        data: {'refresh_token': refreshToken},
      );

      if (result['success'] == true) {
        return AuthTokenModel.fromJson(result['data']);
      } else {
        throw ServerException(
          result['message'] ?? 'Refresh token failed',
          'REFRESH_TOKEN_FAILED',
          result['error'],
        );
      }
    } catch (e) {
      throw ServerException(
        'Failed to refresh token: ${e.toString()}',
        'REFRESH_TOKEN_FAILED',
        e,
      );
    }
  }

  @override
  Future<bool> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      // Use the configured AuthApiService for verifyOtp
      final result = await _authApiService.verifyOtp(phoneNumber, otp);

      return result['success'] == true;
    } catch (e) {
      throw ServerException(
        'Failed to verify OTP: ${e.toString()}',
        'VERIFY_OTP_FAILED',
        e,
      );
    }
  }

  @override
  Future<bool> register({
    required String name,
    required String contactNo,
    required String email,
    required String otp,
  }) async {
    try {
      final result = await _authApiService.register(
        name: name,
        contactNo: contactNo,
        email: email,
        otp: otp,
      );
      return result['success'] == true;
    } catch (e) {
      throw ServerException(
        'Failed to register: ${e.toString()}',
        'REGISTRATION_FAILED',
        e,
      );
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final logoutService = LogoutService();
      final result = await logoutService.logout();
      return result['success'] == true;
    } catch (e) {
      throw ServerException(
        'Failed to logout: ${e.toString()}',
        'LOGOUT_FAILED',
        e,
      );
    }
  }
}
