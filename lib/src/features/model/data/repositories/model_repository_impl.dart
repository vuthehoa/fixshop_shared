import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/model_entity.dart';
import '../../domain/repositories/model_repository.dart';
import '../../domain/value_objects/model_filter.dart';
import '../datasources/model_remote_datasource.dart';
import '../models/model_model.dart';

class ModelRepositoryImpl implements ModelRepository {
  final ModelRemoteDataSource _dataSource;

  ModelRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, ModelEntity>> getModel(String id) =>
      _run(() => _dataSource.getModel(id));

  @override
  Future<Either<Failure, PaginatedResult<ModelEntity>>> getModels(
    ModelFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    final result =
        await _run(() => _dataSource.getModels(filter, startAfter: startAfter));
    return result.map(
      (page) => PaginatedResult<ModelEntity>(
        items: page.items,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
      ),
    );
  }

  @override
  Future<Either<Failure, List<ModelEntity>>> getActiveModels(
          {String? parentId}) =>
      _run(() => _dataSource.getActiveModels(parentId: parentId));

  @override
  Future<Either<Failure, ModelEntity>> createModel(ModelEntity entity) =>
      _run(() => _dataSource.createModel(ModelModel.fromEntity(entity)));

  @override
  Future<Either<Failure, ModelEntity>> updateModel(ModelEntity entity) =>
      _run(() => _dataSource.updateModel(ModelModel.fromEntity(entity)));

  @override
  Future<Either<Failure, void>> archiveModel(String id) =>
      _runVoid(() => _dataSource.archiveModel(id));

  @override
  Future<Either<Failure, void>> restoreModel(String id) =>
      _runVoid(() => _dataSource.restoreModel(id));

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
