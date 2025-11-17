import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/auth_token.dart';
import '../entities/user.dart';

/// Authentication repository interface
/// This defines the contract for all authentication operations
abstract class AuthRepository {
  /// Login with OTP
  Future<Either<Failure, AuthToken>> loginWithOtp({
    required String phoneNumber,
    required String otp,
  });

  /// Send OTP to phone number
  Future<Either<Failure, bool>> sendOtp({required String phoneNumber});

  /// Get current user information
  Future<Either<Failure, User>> getCurrentUser();

  /// Save authentication token locally
  Future<Either<Failure, void>> saveAuthToken(AuthToken token);

  /// Get saved authentication token
  Future<Either<Failure, AuthToken?>> getSavedAuthToken();

  /// Clear authentication token (logout)
  Future<Either<Failure, void>> clearAuthToken();

  /// Refresh authentication token
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken);

  /// Check if user is currently logged in
  Future<Either<Failure, bool>> isLoggedIn();

  /// Verify OTP
  Future<Either<Failure, bool>> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  /// Save user information locally
  Future<Either<Failure, void>> saveUser(User user);

  /// Get saved user information
  Future<Either<Failure, User?>> getSavedUser();

  /// Clear saved user information
  Future<Either<Failure, void>> clearUser();

  /// Update user profile
  Future<Either<Failure, User>> updateUserProfile({
    required String userId,
    String? name,
    String? email,
  });

  /// Change password
  Future<Either<Failure, bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Forgot password - send reset OTP
  Future<Either<Failure, bool>> forgotPassword({required String phoneNumber});

  /// Reset password using OTP
  Future<Either<Failure, bool>> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  });

  /// Register new user
  Future<Either<Failure, bool>> register({
    required String name,
    required String contactNo,
    required String email,
    required String otp,
  });
}
