import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/product_family_entity.dart';
import '../../domain/repositories/product_family_repository.dart';
import '../../domain/value_objects/product_family_filter.dart';
import '../datasources/product_family_remote_datasource.dart';
import '../models/product_family_model.dart';

class ProductFamilyRepositoryImpl implements ProductFamilyRepository {
  final ProductFamilyRemoteDataSource _dataSource;

  ProductFamilyRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, ProductFamilyEntity>> getProductFamily(String id) =>
      _run(() => _dataSource.getProductFamily(id));

  @override
  Future<Either<Failure, PaginatedResult<ProductFamilyEntity>>>
      getProductFamilies(
    ProductFamilyFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    final result = await _run(
        () => _dataSource.getProductFamilies(filter, startAfter: startAfter));
    return result.map(
      (page) => PaginatedResult<ProductFamilyEntity>(
        items: page.items,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
      ),
    );
  }

  @override
  Future<Either<Failure, List<ProductFamilyEntity>>> getActiveProductFamilies(
          {String? parentId}) =>
      _run(() => _dataSource.getActiveProductFamilies(parentId: parentId));

  @override
  Future<Either<Failure, ProductFamilyEntity>> createProductFamily(
          ProductFamilyEntity entity) =>
      _run(() => _dataSource
          .createProductFamily(ProductFamilyModel.fromEntity(entity)));

  @override
  Future<Either<Failure, ProductFamilyEntity>> updateProductFamily(
          ProductFamilyEntity entity) =>
      _run(() => _dataSource
          .updateProductFamily(ProductFamilyModel.fromEntity(entity)));

  @override
  Future<Either<Failure, void>> archiveProductFamily(String id) =>
      _runVoid(() => _dataSource.archiveProductFamily(id));

  @override
  Future<Either<Failure, void>> restoreProductFamily(String id) =>
      _runVoid(() => _dataSource.restoreProductFamily(id));

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
