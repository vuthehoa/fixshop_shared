import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/value_objects/product_family_filter.dart';
import '../models/product_family_model.dart';
import 'product_family_remote_datasource.dart';

class FirebaseProductFamilyRemoteDataSource
    implements ProductFamilyRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseProductFamilyRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.productFamilies);

  @override
  Future<ProductFamilyModel> getProductFamily(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy bản ghi: $id');
    }
    return ProductFamilyModel.fromFirestore(doc);
  }

  @override
  Future<PaginatedResult<ProductFamilyModel>> getProductFamilies(
    ProductFamilyFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (filter.parentId != null) {
      query = query.where('manufacturerId', isEqualTo: filter.parentId);
    }

    if (filter.status != null) {
      query = query.where('status', isEqualTo: filter.status!.name);
    }

    query = query.orderBy('name').limit(filter.pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final models =
        snapshot.docs.map((ProductFamilyModel.fromFirestore)).toList();

    // Client-side text search — Firestore has no native full-text search.
    final filtered =
        filter.searchQuery == null || filter.searchQuery!.trim().isEmpty
            ? models
            : models.where((m) {
                final q = filter.searchQuery!.trim().toLowerCase();
                return m.code.toLowerCase().contains(q) ||
                    m.name.toLowerCase().contains(q);
              }).toList();

    return PaginatedResult(
      items: filtered,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == filter.pageSize,
    );
  }

  @override
  Future<List<ProductFamilyModel>> getActiveProductFamilies(
      {String? parentId}) async {
    Query<Map<String, dynamic>> query =
        _collection.where('status', isEqualTo: CatalogStatus.active.name);

    if (parentId != null) {
      query = query.where('manufacturerId', isEqualTo: parentId);
    }

    final snapshot = await query.orderBy('name').get();
    return snapshot.docs.map((ProductFamilyModel.fromFirestore)).toList();
  }

  @override
  Future<ProductFamilyModel> createProductFamily(
      ProductFamilyModel entity) async {
    await _ensureUniqueCode(entity.code, manufacturerId: entity.manufacturerId);

    final ref = _collection.doc();
    final now = DateTime.now();
    final created = ProductFamilyModel(
      id: ref.id,
      code: entity.code,
      name: entity.name,
      manufacturerId: entity.manufacturerId,
      description: entity.description,
      imageUrl: entity.imageUrl,
      status: CatalogStatus.active,
      createdAt: now,
      updatedAt: now,
      createdBy: entity.createdBy,
    );

    await ref.set(created.toFirestore());
    return created;
  }

  @override
  Future<ProductFamilyModel> updateProductFamily(
      ProductFamilyModel entity) async {
    await _ensureUniqueCode(entity.code,
        exceptId: entity.id, manufacturerId: entity.manufacturerId);

    await _collection.doc(entity.id).update(entity.toUpdateMap());
    final doc = await _collection.doc(entity.id).get();
    if (!doc.exists) {
      throw NotFoundException(
        'Không tìm thấy bản ghi sau khi cập nhật: ${entity.id}',
      );
    }
    return ProductFamilyModel.fromFirestore(doc);
  }

  @override
  Future<void> archiveProductFamily(String id) async {
    await _ensureNoActiveChildren(id);
    await _collection.doc(id).update({
      'status': CatalogStatus.archived.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> restoreProductFamily(String id) async {
    await _collection.doc(id).update({
      'status': CatalogStatus.active.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Client-side uniqueness guard, executed immediately before the write.
  /// Not transactional — a narrow race window is accepted (see sprint notes).
  Future<void> _ensureUniqueCode(String code,
      {String? exceptId, required String manufacturerId}) async {
    final snapshot = await _collection
        .where('code', isEqualTo: code.trim())
        .where('manufacturerId', isEqualTo: manufacturerId)
        .get();
    final clashes = snapshot.docs.where((d) => d.id != exceptId);
    if (clashes.isNotEmpty) {
      throw DuplicateCodeException(
          'Mã "$code" đã tồn tại trong hãng sản xuất này.');
    }
  }

  /// Archiving is blocked while any ACTIVE child record still references this
  /// document. Already-archived children never block.
  Future<void> _ensureNoActiveChildren(String id) async {
    final modelsSnapshot = await _firestore
        .collection(FirestoreConstants.models)
        .where('productFamilyId', isEqualTo: id)
        .where('status', isEqualTo: CatalogStatus.active.name)
        .limit(1)
        .get();
    if (modelsSnapshot.docs.isNotEmpty) {
      throw const HasActiveChildrenException(
        'Không thể lưu trữ vì vẫn còn model máy đang hoạt động. '
        'Vui lòng lưu trữ các bản ghi con trước.',
      );
    }
  }
}
