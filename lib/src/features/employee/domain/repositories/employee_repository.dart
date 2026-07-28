import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../value_objects/employee_filter.dart';

abstract class EmployeeRepository {
  Future<Either<Failure, UserEntity>> getEmployee(String id);

  Future<Either<Failure, PaginatedResult<UserEntity>>> getEmployees(
    EmployeeFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<Either<Failure, UserEntity>> createEmployee({
    required String email,
    required String password,
    required UserEntity employee,
  });

  Future<Either<Failure, UserEntity>> updateEmployee(UserEntity employee);

  Future<Either<Failure, void>> deleteEmployee(String id);

  Future<Either<Failure, void>> updateEmployeeStatus(String id, UserStatus status);

  Future<Either<Failure, void>> resetEmployeePassword(String email);
}
