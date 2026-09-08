import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/paginated_result.dart';
import '../entities/service_category_entity.dart';
import '../value_objects/service_category_filter.dart';

abstract class ServiceCategoryRepository {
  Future<Either<Failure, ServiceCategoryEntity>> getServiceCategory(String id);

  Future<Either<Failure, PaginatedResult<ServiceCategoryEntity>>>
      getServiceCategories(
    ServiceCategoryFilter filter, {
    DocumentSnapshot? startAfter,
  });

  /// Unpaginated, active-only list — feeds dropdowns and filter bars.
  Future<Either<Failure, List<ServiceCategoryEntity>>>
      getActiveServiceCategories();

  Future<Either<Failure, ServiceCategoryEntity>> createServiceCategory(
      ServiceCategoryEntity entity);

  Future<Either<Failure, ServiceCategoryEntity>> updateServiceCategory(
      ServiceCategoryEntity entity);

  Future<Either<Failure, void>> archiveServiceCategory(String id);

  Future<Either<Failure, void>> restoreServiceCategory(String id);
}
