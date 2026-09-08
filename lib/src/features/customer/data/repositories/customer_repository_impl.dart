import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/value_objects/customer_filter.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource _dataSource;

  CustomerRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, CustomerEntity>> getCustomer(String id) =>
      _run(() => _dataSource.getCustomer(id));

  @override
  Future<Either<Failure, PaginatedResult<CustomerEntity>>> getCustomers(
    CustomerFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    final result = await _run(
        () => _dataSource.getCustomers(filter, startAfter: startAfter));
    return result.map(
      (page) => PaginatedResult<CustomerEntity>(
        items: page.items,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
      ),
    );
  }

  @override
  Future<Either<Failure, List<CustomerEntity>>> getActiveCustomers() =>
      _run(() => _dataSource.getActiveCustomers());

  @override
  Future<Either<Failure, CustomerEntity>> createCustomer(
          CustomerEntity entity) =>
      _run(() => _dataSource.createCustomer(CustomerModel.fromEntity(entity)));

  @override
  Future<Either<Failure, CustomerEntity>> updateCustomer(
          CustomerEntity entity) =>
      _run(() => _dataSource.updateCustomer(CustomerModel.fromEntity(entity)));

  @override
  Future<Either<Failure, void>> archiveCustomer(String id) =>
      _runVoid(() => _dataSource.archiveCustomer(id));

  @override
  Future<Either<Failure, void>> restoreCustomer(String id) =>
      _runVoid(() => _dataSource.restoreCustomer(id));

  Future<Either<Failure, T>> _run<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on DuplicateCodeException catch (e) {
      return Left(DuplicateCodeFailure(e.message));
    } on DuplicatePhoneException catch (e) {
      return Left(DuplicatePhoneFailure(e.message));
    } on DuplicateEmailException catch (e) {
      return Left(DuplicateEmailFailure(e.message));
    } on HasActiveChildrenException catch (e) {
      return Left(HasActiveChildrenFailure(e.message));
    } on OperationNotAllowedException catch (e) {
      return Left(OperationNotAllowedFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
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
