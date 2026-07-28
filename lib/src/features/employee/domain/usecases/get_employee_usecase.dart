import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/employee_repository.dart';

class GetEmployeeUseCase extends UseCase<UserEntity, GetEmployeeParams> {
  final EmployeeRepository _repository;

  GetEmployeeUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(GetEmployeeParams params) {
    return _repository.getEmployee(params.id);
  }
}

class GetEmployeeParams extends Equatable {
  final String id;

  const GetEmployeeParams(this.id);

  @override
  List<Object> get props => [id];
}
