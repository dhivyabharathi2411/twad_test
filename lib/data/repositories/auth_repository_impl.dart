import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/remote_data_source.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';

/// Authentication repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;
  final LocalStorage localStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localStorage,
  });

  @override
  Future<Either<Failure, AuthToken>> loginWithOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      // Call remote data source
      final tokenModel = await remoteDataSource.loginWithOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );

      // Save token locally
      await localStorage.saveMap(
        StorageKeys.authToken,
        tokenModel.toLocalJson(),
      );

      // Mark as logged in
      await localStorage.saveBool(StorageKeys.isLoggedIn, true);
      
      // Save login timestamp
      await localStorage.saveInt(
        StorageKeys.lastLoginTime,
        DateTime.now().millisecondsSinceEpoch,
      );

      return Right(tokenModel.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> sendOtp({
    required String phoneNumber,
  }) async {
    try {
      final result = await remoteDataSource.sendOtp(phoneNumber: phoneNumber);
      return Right(result);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Try to get from cache first
      final cachedUserData = await localStorage.getMap(StorageKeys.user);
      if (cachedUserData != null) {
        final cachedUser = UserModel.fromLocalJson(cachedUserData);
        return Right(cachedUser.toEntity());
      }

      // Fetch from remote
      final userModel = await remoteDataSource.getCurrentUser();
      
      // Cache the user data
      await localStorage.saveMap(
        StorageKeys.user,
        userModel.toLocalJson(),
      );

      return Right(userModel.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> saveAuthToken(AuthToken token) async {
    try {
      final tokenModel = AuthTokenModel.fromEntity(token);
      await localStorage.saveMap(
        StorageKeys.authToken,
        tokenModel.toLocalJson(),
      );
      await localStorage.saveBool(StorageKeys.isLoggedIn, true);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AuthToken?>> getSavedAuthToken() async {
    try {
      final tokenData = await localStorage.getMap(StorageKeys.authToken);
      if (tokenData == null) {
        return const Right(null);
      }

      final tokenModel = AuthTokenModel.fromLocalJson(tokenData);
      
      // Check if token is expired
      if (tokenModel.isExpired) {
        // Try to refresh if refresh token exists
        if (tokenModel.refreshToken != null) {
          final refreshResult = await refreshToken(tokenModel.refreshToken!);
          return refreshResult.fold(
            (failure) => const Right(null), // Return null if refresh fails
            (newToken) => Right(newToken),
          );
        }
        return const Right(null);
      }

      return Right(tokenModel.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> clearAuthToken() async {
    try {
      // First try to call the logout API
      try {
        await remoteDataSource.logout();
      } catch (e) {
        // If API call fails, we still proceed with local cleanup
      }
      
      // Clear local storage
      await localStorage.remove(StorageKeys.authToken);
      await localStorage.remove(StorageKeys.user);
      await localStorage.saveBool(StorageKeys.isLoggedIn, false);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, AuthToken>> refreshToken(String refreshToken) async {
    try {
      final tokenModel = await remoteDataSource.refreshToken(refreshToken);
      
      // Save new token
      await localStorage.saveMap(
        StorageKeys.authToken,
        tokenModel.toLocalJson(),
      );

      return Right(tokenModel.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localStorage.getBool(StorageKeys.isLoggedIn) ?? false;
      
      if (!isLoggedIn) {
        return const Right(false);
      }

      // Check if we have a valid token
      final tokenResult = await getSavedAuthToken();
      return tokenResult.fold(
        (failure) => const Right(false),
        (token) => Right(token != null && !token.isExpired),
      );
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      final result = await remoteDataSource.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );
      return Right(result);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await localStorage.saveMap(
        StorageKeys.user,
        userModel.toLocalJson(),
      );
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, User?>> getSavedUser() async {
    try {
      final userData = await localStorage.getMap(StorageKeys.user);
      if (userData == null) {
        return const Right(null);
      }

      final userModel = UserModel.fromLocalJson(userData);
      return Right(userModel.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> clearUser() async {
    try {
      await localStorage.remove(StorageKeys.user);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(Exception(e.toString())));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile({
    required String userId,
    String? name,
    String? email,
  }) async {
    // TODO: Implement when API endpoint is available
    return Left(ServerFailure.serviceUnavailable());
  }

  @override
  Future<Either<Failure, bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // TODO: Implement when API endpoint is available
    return Left(ServerFailure.serviceUnavailable());
  }

  @override
  Future<Either<Failure, bool>> forgotPassword({
    required String phoneNumber,
  }) async {
    // TODO: Implement when API endpoint is available
    return Left(ServerFailure.serviceUnavailable());
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String phoneNumber,
    required String otp,
    required String newPassword,
  }) async {
    // TODO: Implement when API endpoint is available
    return Left(ServerFailure.serviceUnavailable());
  }

  @override
  Future<Either<Failure, bool>> register({
    required String name,
    required String contactNo,
    required String email,
    required String otp,
  }) async {
    try {
      final result = await remoteDataSource.register(
        name: name,
        contactNo: contactNo,
        email: email,
        otp: otp,
      );
      return Right(result);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(UnexpectedFailure.fromException(Exception(e.toString())));
    }
  }

  /// Map exceptions to failures
  Failure _mapExceptionToFailure(AppException exception) {
    switch (exception.runtimeType) {
      case ServerException:
        return ServerFailure(exception.message, exception.code);
      case ClientException:
        return ClientFailure(exception.message, exception.code);
      case NetworkException:
        return NetworkFailure(exception.message, exception.code);
      case CacheException:
        return CacheFailure(exception.message, exception.code);
      case ValidationException:
        return ValidationFailure(exception.message, exception.code);
      default:
        return UnexpectedFailure(exception.message);
    }
  }
}
