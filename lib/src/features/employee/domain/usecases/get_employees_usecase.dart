import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../repositories/employee_repository.dart';
import '../value_objects/employee_filter.dart';

class GetEmployeesUseCase
    extends UseCase<PaginatedResult<UserEntity>, GetEmployeesParams> {
  final EmployeeRepository _repository;

  GetEmployeesUseCase(this._repository);

  @override
  Future<Either<Failure, PaginatedResult<UserEntity>>> call(
    GetEmployeesParams params,
  ) {
    return _repository.getEmployees(
      params.filter,
      startAfter: params.startAfter,
    );
  }
}

class GetEmployeesParams extends Equatable {
  final EmployeeFilter filter;
  final DocumentSnapshot? startAfter;

  const GetEmployeesParams({
    required this.filter,
    this.startAfter,
  });

  @override
  List<Object?> get props => [filter, startAfter];
}
