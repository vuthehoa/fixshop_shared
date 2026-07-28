import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../domain/value_objects/employee_filter.dart';
import '../datasources/employee_remote_datasource.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource _dataSource;

  EmployeeRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, UserEntity>> getEmployee(String id) =>
      _run(() => _dataSource.getEmployee(id));

  @override
  Future<Either<Failure, PaginatedResult<UserEntity>>> getEmployees(
    EmployeeFilter filter, {
    DocumentSnapshot? startAfter,
  }) =>
      _run(() => _dataSource.getEmployees(filter, startAfter: startAfter));

  @override
  Future<Either<Failure, UserEntity>> createEmployee({
    required String email,
    required String password,
    required UserEntity employee,
  }) =>
      _run(
        () => _dataSource.createEmployee(
          email: email,
          password: password,
          employee: UserModel.fromEntity(employee),
        ),
      );

  @override
  Future<Either<Failure, UserEntity>> updateEmployee(UserEntity employee) =>
      _run(() => _dataSource.updateEmployee(UserModel.fromEntity(employee)));

  @override
  Future<Either<Failure, void>> deleteEmployee(String id) =>
      _runVoid(() => _dataSource.deleteEmployee(id));

  @override
  Future<Either<Failure, void>> updateEmployeeStatus(
    String id,
    UserStatus status,
  ) =>
      _runVoid(() => _dataSource.updateEmployeeStatus(id, status));

  @override
  Future<Either<Failure, void>> resetEmployeePassword(String email) =>
      _runVoid(() => _dataSource.resetEmployeePassword(email));

  Future<Either<Failure, T>> _run<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on DuplicateEmailException catch (e) {
      return Left(DuplicateEmailFailure(e.message));
    } on OperationNotAllowedException catch (e) {
      return Left(OperationNotAllowedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> _runVoid(Future<void> Function() fn) =>
      _run<void>(fn);
}
