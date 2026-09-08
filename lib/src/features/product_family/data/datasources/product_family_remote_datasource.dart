import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/paginated_result.dart';
import '../../domain/value_objects/product_family_filter.dart';
import '../models/product_family_model.dart';

abstract class ProductFamilyRemoteDataSource {
  Future<ProductFamilyModel> getProductFamily(String id);

  Future<PaginatedResult<ProductFamilyModel>> getProductFamilies(
    ProductFamilyFilter filter, {
    DocumentSnapshot? startAfter,
  });

  Future<List<ProductFamilyModel>> getActiveProductFamilies({String? parentId});

  Future<ProductFamilyModel> createProductFamily(ProductFamilyModel entity);

  Future<ProductFamilyModel> updateProductFamily(ProductFamilyModel entity);

  Future<void> archiveProductFamily(String id);

  Future<void> restoreProductFamily(String id);
}
