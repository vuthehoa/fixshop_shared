import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/repair_service_entity.dart';
import '../../domain/repositories/repair_service_repository.dart';
import '../../domain/value_objects/repair_service_filter.dart';
import '../../domain/value_objects/repair_service_write_context.dart';
import '../datasources/repair_service_remote_datasource.dart';
import '../models/repair_service_model.dart';

class RepairServiceRepositoryImpl implements RepairServiceRepository {
  final RepairServiceRemoteDataSource _dataSource;

  RepairServiceRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, RepairServiceEntity>> getRepairService(String id) =>
      _run(() => _dataSource.getRepairService(id));

  @override
  Future<Either<Failure, PaginatedResult<RepairServiceEntity>>>
      getRepairServices(
    RepairServiceFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    final result = await _run(
        () => _dataSource.getRepairServices(filter, startAfter: startAfter));
    return result.map(
      (page) => PaginatedResult<RepairServiceEntity>(
        items: page.items,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
      ),
    );
  }

  @override
  Future<Either<Failure, List<RepairServiceEntity>>> getActiveRepairServices(
          {String? parentId}) =>
      _run(() => _dataSource.getActiveRepairServices(parentId: parentId));

  @override
  Future<Either<Failure, RepairServiceEntity>> createRepairService(
    RepairServiceEntity entity, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  }) =>
      _run(() => _dataSource.createRepairService(
            RepairServiceModel.fromEntity(entity),
            context: context,
          ));

  @override
  Future<Either<Failure, RepairServiceEntity>> updateRepairService(
    RepairServiceEntity entity, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  }) =>
      _run(() => _dataSource.updateRepairService(
            RepairServiceModel.fromEntity(entity),
            context: context,
          ));

  @override
  Future<Either<Failure, void>> archiveRepairService(
    String id, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  }) =>
      _runVoid(() => _dataSource.archiveRepairService(id, context: context));

  @override
  Future<Either<Failure, void>> restoreRepairService(
    String id, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  }) =>
      _runVoid(() => _dataSource.restoreRepairService(id, context: context));

  Future<Either<Failure, T>> _run<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on DuplicateCodeException catch (e) {
      return Left(DuplicateCodeFailure(e.message));
    } on HasActiveChildrenException catch (e) {
      return Left(HasActiveChildrenFailure(e.message));
    } on CatalogValidationException catch (e) {
      return Left(CatalogValidationFailure(e.message));
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
