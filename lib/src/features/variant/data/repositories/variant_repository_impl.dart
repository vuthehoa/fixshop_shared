import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/variant_entity.dart';
import '../../domain/repositories/variant_repository.dart';
import '../../domain/value_objects/variant_filter.dart';
import '../datasources/variant_remote_datasource.dart';
import '../models/variant_model.dart';

class VariantRepositoryImpl implements VariantRepository {
  final VariantRemoteDataSource _dataSource;

  VariantRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, VariantEntity>> getVariant(String id) =>
      _run(() => _dataSource.getVariant(id));

  @override
  Future<Either<Failure, PaginatedResult<VariantEntity>>> getVariants(
    VariantFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    final result = await _run(
        () => _dataSource.getVariants(filter, startAfter: startAfter));
    return result.map(
      (page) => PaginatedResult<VariantEntity>(
        items: page.items,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
      ),
    );
  }

  @override
  Future<Either<Failure, List<VariantEntity>>> getActiveVariants(
          {String? parentId}) =>
      _run(() => _dataSource.getActiveVariants(parentId: parentId));

  @override
  Future<Either<Failure, VariantEntity>> createVariant(VariantEntity entity) =>
      _run(() => _dataSource.createVariant(VariantModel.fromEntity(entity)));

  @override
  Future<Either<Failure, VariantEntity>> updateVariant(VariantEntity entity) =>
      _run(() => _dataSource.updateVariant(VariantModel.fromEntity(entity)));

  @override
  Future<Either<Failure, void>> archiveVariant(String id) =>
      _runVoid(() => _dataSource.archiveVariant(id));

  @override
  Future<Either<Failure, void>> restoreVariant(String id) =>
      _runVoid(() => _dataSource.restoreVariant(id));

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
