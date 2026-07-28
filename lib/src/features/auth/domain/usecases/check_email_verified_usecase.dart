import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class CheckEmailVerifiedUseCase extends UseCase<bool, NoParams> {
  final AuthRepository _repository;

  CheckEmailVerifiedUseCase(this._repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) {
    return _repository.checkEmailVerified();
  }
}
