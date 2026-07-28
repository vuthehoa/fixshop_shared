import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ResendVerificationEmailUseCase extends UseCase<void, NoParams> {
  final AuthRepository _repository;

  ResendVerificationEmailUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.resendVerificationEmail();
  }
}
