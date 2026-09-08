import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/shop_product_entity.dart';
import '../value_objects/shop_product_filter.dart';

abstract class ShopProductRepository {
  Future<Either<Failure, ShopProductEntity>> getProduct(String id);

  Future<Either<Failure, PaginatedResult<ShopProductEntity>>> getProducts(
    ShopProductFilter filter, {
    DocumentSnapshot? startAfter,
  });

  /// Reserves a document id so the CMS can upload images to
  /// `products/{id}/images/...` before the document exists.
  String newProductId();

  /// Writes a brand-new document at [entity.id] (which must be a value from
  /// [newProductId]). Sets createdAt/updatedAt server-side.
  Future<Either<Failure, ShopProductEntity>> createProduct(
    ShopProductEntity entity,
  );

  Future<Either<Failure, ShopProductEntity>> updateProduct(
    ShopProductEntity entity,
  );

  /// Flips publish state (and the paired status) without touching the rest
  /// of the document.
  Future<Either<Failure, void>> setPublished(
    String id, {
    required bool isPublished,
    required String actorId,
  });

  /// Soft delete — `status = archived`, `isPublished = false`.
  Future<Either<Failure, void>> archiveProduct(String id,
      {required String actorId});

  Future<Either<Failure, void>> restoreProduct(String id,
      {required String actorId});

  /// Hard delete — removes the Firestore document. Storage cleanup is the
  /// caller's responsibility (via [ProductImageStorageService]).
  Future<Either<Failure, void>> deleteProduct(String id);
}
