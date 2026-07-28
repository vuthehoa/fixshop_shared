import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/employee_repository.dart';

class CreateEmployeeUseCase extends UseCase<UserEntity, CreateEmployeeParams> {
  final EmployeeRepository _repository;

  CreateEmployeeUseCase(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(CreateEmployeeParams params) {
    return _repository.createEmployee(
      email: params.email,
      password: params.password,
      employee: params.employee,
    );
  }
}

class CreateEmployeeParams extends Equatable {
  final String email;
  final String password;
  final UserEntity employee;

  const CreateEmployeeParams({
    required this.email,
    required this.password,
    required this.employee,
  });

  @override
  List<Object> get props => [email, password, employee];
}
