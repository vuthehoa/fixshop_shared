import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/manufacturer_entity.dart';
import '../../domain/repositories/manufacturer_repository.dart';
import '../../domain/value_objects/manufacturer_filter.dart';
import '../datasources/manufacturer_remote_datasource.dart';
import '../models/manufacturer_model.dart';

class ManufacturerRepositoryImpl implements ManufacturerRepository {
  final ManufacturerRemoteDataSource _dataSource;

  ManufacturerRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, ManufacturerEntity>> getManufacturer(String id) =>
      _run(() => _dataSource.getManufacturer(id));

  @override
  Future<Either<Failure, PaginatedResult<ManufacturerEntity>>> getManufacturers(
    ManufacturerFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    final result = await _run(
        () => _dataSource.getManufacturers(filter, startAfter: startAfter));
    return result.map(
      (page) => PaginatedResult<ManufacturerEntity>(
        items: page.items,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
      ),
    );
  }

  @override
  Future<Either<Failure, List<ManufacturerEntity>>> getActiveManufacturers() =>
      _run(() => _dataSource.getActiveManufacturers());

  @override
  Future<Either<Failure, ManufacturerEntity>> createManufacturer(
          ManufacturerEntity entity) =>
      _run(() =>
          _dataSource.createManufacturer(ManufacturerModel.fromEntity(entity)));

  @override
  Future<Either<Failure, ManufacturerEntity>> updateManufacturer(
          ManufacturerEntity entity) =>
      _run(() =>
          _dataSource.updateManufacturer(ManufacturerModel.fromEntity(entity)));

  @override
  Future<Either<Failure, void>> archiveManufacturer(String id) =>
      _runVoid(() => _dataSource.archiveManufacturer(id));

  @override
  Future<Either<Failure, void>> restoreManufacturer(String id) =>
      _runVoid(() => _dataSource.restoreManufacturer(id));

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
