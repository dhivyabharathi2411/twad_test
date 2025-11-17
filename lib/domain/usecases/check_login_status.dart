import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Check login status use case
class CheckLoginStatus implements UseCaseNoParams<bool> {
  final AuthRepository repository;

  CheckLoginStatus(this.repository);

  @override
  Future<Either<Failure, bool>> call() async {
    return await repository.isLoggedIn();
  }
}
