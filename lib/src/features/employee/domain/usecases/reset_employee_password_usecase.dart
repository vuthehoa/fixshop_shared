import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/employee_repository.dart';

class ResetEmployeePasswordUseCase
    extends UseCase<void, ResetEmployeePasswordParams> {
  final EmployeeRepository _repository;

  ResetEmployeePasswordUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(ResetEmployeePasswordParams params) {
    return _repository.resetEmployeePassword(params.email);
  }
}

class ResetEmployeePasswordParams extends Equatable {
  final String email;

  const ResetEmployeePasswordParams(this.email);

  @override
  List<Object> get props => [email];
}
