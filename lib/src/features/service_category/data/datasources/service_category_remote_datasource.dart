import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/paginated_result.dart';
import '../../domain/value_objects/service_category_filter.dart';
import '../models/service_category_model.dart';

abstract class ServiceCategoryRemoteDataSource {
  Future<ServiceCategoryModel> getServiceCategory(String id);

  Future<PaginatedResult<ServiceCategoryModel>> getServiceCategories(
    ServiceCategoryFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<List<ServiceCategoryModel>> getActiveServiceCategories();

  Future<ServiceCategoryModel> createServiceCategory(
      ServiceCategoryModel entity);

  Future<ServiceCategoryModel> updateServiceCategory(
      ServiceCategoryModel entity);

  Future<void> archiveServiceCategory(String id);

  Future<void> restoreServiceCategory(String id);
}
