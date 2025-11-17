import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Send OTP use case
class SendOtp implements UseCase<bool, SendOtpParams> {
  final AuthRepository repository;

  SendOtp(this.repository);

  @override
  Future<Either<Failure, bool>> call(SendOtpParams params) async {
    // Validate phone number
    if (!_isValidPhoneNumber(params.phoneNumber)) {
      return Left(ValidationFailure.invalidPhoneNumber());
    }

    // Send OTP
    return await repository.sendOtp(phoneNumber: params.phoneNumber);
  }

  /// Validate phone number format
  bool _isValidPhoneNumber(String phoneNumber) {
    final regex = RegExp(r'^[6-9]\d{9}$');
    return regex.hasMatch(phoneNumber);
  }
}

/// Parameters for SendOtp use case
class SendOtpParams extends Equatable {
  final String phoneNumber;

  const SendOtpParams({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];

  /// Create params with validation
  factory SendOtpParams.create({required String phoneNumber}) {
    return SendOtpParams(phoneNumber: phoneNumber.trim());
  }
}
