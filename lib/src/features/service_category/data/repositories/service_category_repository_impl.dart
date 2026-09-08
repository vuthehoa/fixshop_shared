import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/service_category_entity.dart';
import '../../domain/repositories/service_category_repository.dart';
import '../../domain/value_objects/service_category_filter.dart';
import '../datasources/service_category_remote_datasource.dart';
import '../models/service_category_model.dart';

class ServiceCategoryRepositoryImpl implements ServiceCategoryRepository {
  final ServiceCategoryRemoteDataSource _dataSource;

  ServiceCategoryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, ServiceCategoryEntity>> getServiceCategory(
          String id) =>
      _run(() => _dataSource.getServiceCategory(id));

  @override
  Future<Either<Failure, PaginatedResult<ServiceCategoryEntity>>>
      getServiceCategories(
    ServiceCategoryFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    final result = await _run(
        () => _dataSource.getServiceCategories(filter, startAfter: startAfter));
    return result.map(
      (page) => PaginatedResult<ServiceCategoryEntity>(
        items: page.items,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
      ),
    );
  }

  @override
  Future<Either<Failure, List<ServiceCategoryEntity>>>
      getActiveServiceCategories() =>
          _run(() => _dataSource.getActiveServiceCategories());

  @override
  Future<Either<Failure, ServiceCategoryEntity>> createServiceCategory(
          ServiceCategoryEntity entity) =>
      _run(() => _dataSource
          .createServiceCategory(ServiceCategoryModel.fromEntity(entity)));

  @override
  Future<Either<Failure, ServiceCategoryEntity>> updateServiceCategory(
          ServiceCategoryEntity entity) =>
      _run(() => _dataSource
          .updateServiceCategory(ServiceCategoryModel.fromEntity(entity)));

  @override
  Future<Either<Failure, void>> archiveServiceCategory(String id) =>
      _runVoid(() => _dataSource.archiveServiceCategory(id));

  @override
  Future<Either<Failure, void>> restoreServiceCategory(String id) =>
      _runVoid(() => _dataSource.restoreServiceCategory(id));

  Future<Either<Failure, T>> _run<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on DuplicateCodeException catch (e) {
      return Left(DuplicateCodeFailure(e.message));
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
