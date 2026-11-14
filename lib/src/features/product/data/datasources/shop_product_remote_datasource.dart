import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/utils/paginated_result.dart';
import '../../domain/enums/product_status.dart';
import '../../domain/value_objects/shop_product_filter.dart';
import '../models/shop_product_model.dart';

abstract class ShopProductRemoteDataSource {
  Future<ShopProductModel> getProduct(String id);

  Future<PaginatedResult<ShopProductModel>> getProducts(
    ShopProductFilter filter, {
    DocumentSnapshot? startAfter,
  });

  String newProductId();

  Future<ShopProductModel> createProduct(ShopProductModel model);

  Future<ShopProductModel> updateProduct(ShopProductModel model);

  Future<void> setPublished(
    String id, {
    required bool isPublished,
    required String actorId,
  });

  Future<void> archiveProduct(String id, {required String actorId});

  Future<void> restoreProduct(String id, {required String actorId});

  /// Generic status change along [ProductStatusTransitions] (decision 4).
  Future<void> changeStatus(
    String id, {
    required ProductStatus to,
    required String actorId,
  });

  Future<void> deleteProduct(String id);
}
