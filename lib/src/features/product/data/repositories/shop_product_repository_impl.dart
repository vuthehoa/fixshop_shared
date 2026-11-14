import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/shop_product_entity.dart';
import '../../domain/repositories/shop_product_repository.dart';
import '../../domain/value_objects/shop_product_filter.dart';
import '../datasources/shop_product_remote_datasource.dart';
import '../models/shop_product_model.dart';

class ShopProductRepositoryImpl implements ShopProductRepository {
  final ShopProductRemoteDataSource _dataSource;

  ShopProductRepositoryImpl(this._dataSource);

  @override
  String newProductId() => _dataSource.newProductId();

  @override
  Future<Either<Failure, ShopProductEntity>> getProduct(String id) =>
      _run(() => _dataSource.getProduct(id));

  @override
  Future<Either<Failure, PaginatedResult<ShopProductEntity>>> getProducts(
    ShopProductFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    final result = await _run(
      () => _dataSource.getProducts(filter, startAfter: startAfter),
    );
    return result.map(
      (page) => PaginatedResult<ShopProductEntity>(
        items: page.items,
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
      ),
    );
  }

  @override
  Future<Either<Failure, ShopProductEntity>> createProduct(
    ShopProductEntity entity,
  ) =>
      _run(
          () => _dataSource.createProduct(ShopProductModel.fromEntity(entity)));

  @override
  Future<Either<Failure, ShopProductEntity>> updateProduct(
    ShopProductEntity entity,
  ) =>
      _run(
          () => _dataSource.updateProduct(ShopProductModel.fromEntity(entity)));

  @override
  Future<Either<Failure, void>> setPublished(
    String id, {
    required bool isPublished,
    required String actorId,
  }) =>
      _runVoid(() => _dataSource.setPublished(
            id,
            isPublished: isPublished,
            actorId: actorId,
          ));

  @override
  Future<Either<Failure, void>> archiveProduct(String id,
          {required String actorId}) =>
      _runVoid(() => _dataSource.archiveProduct(id, actorId: actorId));

  @override
  Future<Either<Failure, void>> restoreProduct(String id,
          {required String actorId}) =>
      _runVoid(() => _dataSource.restoreProduct(id, actorId: actorId));

  @override
  Future<Either<Failure, void>> deleteProduct(String id) =>
      _runVoid(() => _dataSource.deleteProduct(id));

  Future<Either<Failure, T>> _run<T>(Future<T> Function() fn) async {
    try {
      return Right(await fn());
    } on CatalogValidationException catch (e) {
      return Left(CatalogValidationFailure(e.message));
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on FirebaseException catch (e, st) {
      // Keep the friendly message for the UI, but never swallow the root
      // cause — the raw Firestore code/plugin is what tells you a
      // `permission-denied` is a missing/stale `products` security rule
      // rather than a real authorization problem.
      if (kDebugMode) {
        debugPrint(
          '[ShopProductRepository] FirebaseException on `products` '
          'code=${e.code} plugin=${e.plugin} message=${e.message}\n$st',
        );
      }
      if (e.code == 'permission-denied') {
        return const Left(
          ServerFailure('Bạn không có quyền thực hiện thao tác này.'),
        );
      }
      if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        return const Left(
          NetworkFailure('Mất kết nối máy chủ. Vui lòng thử lại.'),
        );
      }
      return Left(ServerFailure(e.message ?? e.code));
    } catch (e, st) {
      // A StateError (Firestore query assertion), TypeError/FormatException
      // (legacy-document mapping) or AssertionError never reaches the caller
      // as itself — it collapses to ServerFailure. Keep the runtime type in
      // the debug log so it stays distinguishable from a real server error.
      if (kDebugMode) {
        debugPrint(
          '[ShopProductRepository] non-Firebase error on `products` '
          'type=${e.runtimeType} message=$e\n$st',
        );
      }
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> _runVoid(Future<void> Function() fn) =>
      _run<void>(fn);
}
