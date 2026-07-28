import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/employee_repository.dart';

class UpdateEmployeeStatusUseCase
    extends UseCase<void, UpdateEmployeeStatusParams> {
  final EmployeeRepository _repository;

  UpdateEmployeeStatusUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(UpdateEmployeeStatusParams params) {
    return _repository.updateEmployeeStatus(params.employeeId, params.status);
  }
}

class UpdateEmployeeStatusParams extends Equatable {
  final String employeeId;
  final UserStatus status;

  const UpdateEmployeeStatusParams({
    required this.employeeId,
    required this.status,
  });

  @override
  List<Object> get props => [employeeId, status];
}
