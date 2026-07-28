import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/employee_repository.dart';

class UpdateEmployeeUseCase extends UseCase<UserEntity, UserEntity> {
  final EmployeeRepository _repository;

  UpdateEmployeeUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(UserEntity params) {
    return _repository.updateEmployee(params);
  }
}
