import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/permissions/permission.dart';
import '../../../../core/permissions/permission_resolver.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/employee_repository.dart';

class DeleteEmployeeUseCase extends UseCase<void, DeleteEmployeeParams> {
  final EmployeeRepository _repository;

  DeleteEmployeeUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteEmployeeParams params) {
    if (!PermissionResolver.hasPermission(
      params.actorRole,
      Permission.deleteEmployee,
    )) {
      return Future.value(
        const Left(
          OperationNotAllowedFailure(
              'You do not have permission to delete employees.'),
        ),
      );
    }
    return _repository.deleteEmployee(params.employeeId);
  }
}

class DeleteEmployeeParams extends Equatable {
  final String employeeId;
  final UserRole actorRole;

  const DeleteEmployeeParams({
    required this.employeeId,
    required this.actorRole,
  });

  @override
  List<Object> get props => [employeeId, actorRole];
}
