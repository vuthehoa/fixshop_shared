import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/product_family_entity.dart';
import '../value_objects/product_family_filter.dart';

abstract class ProductFamilyRepository {
  Future<Either<Failure, ProductFamilyEntity>> getProductFamily(String id);

  Future<Either<Failure, PaginatedResult<ProductFamilyEntity>>>
      getProductFamilies(
    ProductFamilyFilter filter, {
    DocumentSnapshot? startAfter,
  });

  /// Unpaginated, active-only list — feeds dropdowns and filter bars.
  Future<Either<Failure, List<ProductFamilyEntity>>> getActiveProductFamilies(
      {String? parentId});

  Future<Either<Failure, ProductFamilyEntity>> createProductFamily(
      ProductFamilyEntity entity);

  Future<Either<Failure, ProductFamilyEntity>> updateProductFamily(
      ProductFamilyEntity entity);

  Future<Either<Failure, void>> archiveProductFamily(String id);

  Future<Either<Failure, void>> restoreProductFamily(String id);
}
