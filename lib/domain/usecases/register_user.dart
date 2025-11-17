import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:twad/core/error/failures.dart';
import 'package:twad/core/usecases/usecase.dart';
import 'package:twad/domain/repositories/auth_repository.dart';

class RegisterUser implements UseCase<bool, RegisterUserParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, bool>> call(RegisterUserParams params) async {
    return await repository.register(
      name: params.name,
      contactNo: params.contactNo,
      email: params.email,
      otp: params.otp,
    );
  }
}

class RegisterUserParams extends Equatable {
  final String name;
  final String contactNo;
  final String email;
  final String otp;

  const RegisterUserParams({
    required this.name,
    required this.contactNo,
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [name, contactNo, email, otp];
}
