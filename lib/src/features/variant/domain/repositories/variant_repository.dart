import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/variant_entity.dart';
import '../value_objects/variant_filter.dart';

abstract class VariantRepository {
  Future<Either<Failure, VariantEntity>> getVariant(String id);

  Future<Either<Failure, PaginatedResult<VariantEntity>>> getVariants(
    VariantFilter filter, {
    DocumentSnapshot? startAfter,
  });

  /// Unpaginated, active-only list — feeds dropdowns and filter bars.
  Future<Either<Failure, List<VariantEntity>>> getActiveVariants(
      {String? parentId});

  Future<Either<Failure, VariantEntity>> createVariant(VariantEntity entity);

  Future<Either<Failure, VariantEntity>> updateVariant(VariantEntity entity);

  Future<Either<Failure, void>> archiveVariant(String id);

  Future<Either<Failure, void>> restoreVariant(String id);
}
