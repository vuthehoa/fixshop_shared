import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/enums/product_status.dart';
import '../../domain/value_objects/shop_product_filter.dart';
import '../models/shop_product_model.dart';
import 'shop_product_remote_datasource.dart';

/// Firestore-backed `products` collection access.
///
/// Server-side `where` clauses stay on the denormalized relation ids and
/// the status/publish flags (all equality, all index-friendly, always
/// paired with `orderBy('updatedAt', descending)`); the free-text search,
/// the price range and the `quantity > 0` shopfront check are applied to
/// the fetched page client-side — Firestore has no full-text search and
/// the dataset per query is bounded by the equality filters above.
class FirebaseShopProductRemoteDataSource
    implements ShopProductRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseShopProductRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.products);

  @override
  String newProductId() => _collection.doc().id;

  @override
  Future<ShopProductModel> getProduct(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy sản phẩm: $id');
    }
    return ShopProductModel.fromFirestore(doc);
  }

  @override
  Future<PaginatedResult<ShopProductModel>> getProducts(
    ShopProductFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (filter.publishedOnly) {
      query = query.where('isPublished', isEqualTo: true);
    }
    if (filter.status != null) {
      query = query.where('status', isEqualTo: filter.status!.wireName);
    }
    if (filter.manufacturerId != null) {
      query = query.where('manufacturerId', isEqualTo: filter.manufacturerId);
    }
    if (filter.productFamilyId != null) {
      query = query.where('productFamilyId', isEqualTo: filter.productFamilyId);
    }
    if (filter.modelId != null) {
      query = query.where('modelId', isEqualTo: filter.modelId);
    }
    if (filter.condition != null) {
      query = query.where('condition', isEqualTo: filter.condition!.wireName);
    }

    query = query.orderBy('updatedAt', descending: true).limit(filter.pageSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    if (kDebugMode) {
      // The exact server-side query that goes to Firestore — not the raw
      // ShopProductFilter. All clauses are equality + one orderBy, so this
      // needs no composite index; anything that fails here is rules or data.
      debugPrint(
        '[ProductQueryPlan] collection=products '
        'publishedOnly=${filter.publishedOnly} '
        'status=${filter.status?.wireName} '
        'manufacturerId=${filter.manufacturerId} '
        'productFamilyId=${filter.productFamilyId} '
        'modelId=${filter.modelId} '
        'condition=${filter.condition?.wireName} '
        'orderBy=updatedAt_desc limit=${filter.pageSize} '
        'cursor=${startAfter != null} '
        '(clientSide: search=${filter.searchQuery?.trim().isNotEmpty ?? false} '
        'minPrice=${filter.minPrice} maxPrice=${filter.maxPrice} '
        'inStockOnly=${filter.inStockOnly})',
      );
    }

    final snapshot = await query.get();
    var models = snapshot.docs.map(ShopProductModel.fromFirestore).toList();

    if (filter.inStockOnly) {
      models = models.where((p) => p.quantity > 0).toList();
    }
    final min = filter.minPrice;
    if (min != null) {
      models = models.where((p) => p.listingPrice >= min).toList();
    }
    final max = filter.maxPrice;
    if (max != null) {
      models = models.where((p) => p.listingPrice <= max).toList();
    }
    final rawQuery = filter.searchQuery?.trim().toLowerCase();
    if (rawQuery != null && rawQuery.isNotEmpty) {
      models = models.where((p) {
        return p.title.toLowerCase().contains(rawQuery) ||
            p.modelName.toLowerCase().contains(rawQuery) ||
            p.manufacturerName.toLowerCase().contains(rawQuery);
      }).toList();
    }

    return PaginatedResult(
      items: models,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == filter.pageSize,
    );
  }

  @override
  Future<ShopProductModel> createProduct(ShopProductModel model) async {
    final ref = _collection.doc(model.id);
    final existing = await ref.get();
    if (existing.exists) {
      throw const ServerException('Sản phẩm với mã này đã tồn tại.');
    }
    await ref.set(model.toCreateMap());
    return getProduct(model.id);
  }

  @override
  Future<ShopProductModel> updateProduct(ShopProductModel model) async {
    final ref = _collection.doc(model.id);
    final existing = await ref.get();
    if (!existing.exists) {
      throw NotFoundException('Không tìm thấy sản phẩm: ${model.id}');
    }
    await ref.update(model.toUpdateMap());
    return getProduct(model.id);
  }

  /// Decision 4: products are internal; "publish" now means "Đang bán".
  /// `isPublished` is kept in sync (== selling) only for legacy readers.
  @override
  Future<void> setPublished(
    String id, {
    required bool isPublished,
    required String actorId,
  }) =>
      changeStatus(
        id,
        to: isPublished ? ProductStatus.selling : ProductStatus.draft,
        actorId: actorId,
      );

  @override
  Future<void> archiveProduct(String id, {required String actorId}) =>
      changeStatus(id, to: ProductStatus.discontinued, actorId: actorId);

  @override
  Future<void> restoreProduct(String id, {required String actorId}) =>
      changeStatus(id, to: ProductStatus.draft, actorId: actorId);

  @override
  Future<void> changeStatus(
    String id, {
    required ProductStatus to,
    required String actorId,
  }) async {
    final ref = _collection.doc(id);
    final snap = await ref.get();
    if (!snap.exists) throw NotFoundException('Không tìm thấy sản phẩm: $id');
    final raw = snap.data()?['status'] as String?;
    final from = ProductStatus.fromName(raw);
    // A legacy (pre-migration) value may move to any new status.
    if (!ProductStatus.isLegacyWireValue(raw) &&
        !ProductStatusTransitions.canTransition(from, to)) {
      throw CatalogValidationException(
        'Không thể chuyển từ "${from.displayName}" sang "${to.displayName}".',
      );
    }
    await ref.update({
      'status': to.wireName,
      'isPublished': to == ProductStatus.selling,
      'updatedBy': actorId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _collection.doc(id).delete();
  }
}
