import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';

/// Login with OTP use case
class LoginWithOtp implements UseCase<AuthToken, LoginWithOtpParams> {
  final AuthRepository repository;

  LoginWithOtp(this.repository);

  @override
  Future<Either<Failure, AuthToken>> call(LoginWithOtpParams params) async {
    if (!_isValidPhoneNumber(params.phoneNumber)) {
      return Left(ValidationFailure.invalidPhoneNumber());
    }
    if (!_isValidOTP(params.otp)) {
      return Left(ValidationFailure.invalidOTP());
    }
    return await repository.loginWithOtp(
      phoneNumber: params.phoneNumber,
      otp: params.otp,
    );
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^[6-9]\d{9}$');
    return regex.hasMatch(phoneNumber);
  }

  bool _isValidOTP(String otp) {
    final regex = RegExp(r'^\d{6}$');
    return regex.hasMatch(otp);
  }
}

class LoginWithOtpParams extends Equatable {
  final String phoneNumber;
  final String otp;

  const LoginWithOtpParams({required this.phoneNumber, required this.otp});

  @override
  List<Object> get props => [phoneNumber, otp];

  factory LoginWithOtpParams.create({required String phoneNumber, required String otp}) {
    return LoginWithOtpParams(
      phoneNumber: phoneNumber.trim(),
      otp: otp.trim(),
    );
  }
}
