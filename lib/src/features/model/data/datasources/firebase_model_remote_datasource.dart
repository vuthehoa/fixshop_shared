import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/value_objects/model_filter.dart';
import '../models/model_model.dart';
import 'model_remote_datasource.dart';

class FirebaseModelRemoteDataSource implements ModelRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseModelRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.models);

  @override
  Future<ModelModel> getModel(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy bản ghi: $id');
    }
    return ModelModel.fromFirestore(doc);
  }

  @override
  Future<PaginatedResult<ModelModel>> getModels(
    ModelFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (filter.parentId != null) {
      query = query.where('productFamilyId', isEqualTo: filter.parentId);
    }

    if (filter.status != null) {
      query = query.where('status', isEqualTo: filter.status!.name);
    }

    query = query.orderBy('name').limit(filter.pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final models = snapshot.docs.map((ModelModel.fromFirestore)).toList();

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
  Future<List<ModelModel>> getActiveModels({String? parentId}) async {
    Query<Map<String, dynamic>> query =
        _collection.where('status', isEqualTo: CatalogStatus.active.name);

    if (parentId != null) {
      query = query.where('productFamilyId', isEqualTo: parentId);
    }

    final snapshot = await query.orderBy('name').get();
    return snapshot.docs.map((ModelModel.fromFirestore)).toList();
  }

  @override
  Future<ModelModel> createModel(ModelModel entity) async {
    await _ensureUniqueCode(entity.code,
        productFamilyId: entity.productFamilyId);

    final ref = _collection.doc();
    final now = DateTime.now();
    final created = ModelModel(
      id: ref.id,
      code: entity.code,
      name: entity.name,
      productFamilyId: entity.productFamilyId,
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
  Future<ModelModel> updateModel(ModelModel entity) async {
    await _ensureUniqueCode(entity.code,
        exceptId: entity.id, productFamilyId: entity.productFamilyId);

    await _collection.doc(entity.id).update(entity.toUpdateMap());
    final doc = await _collection.doc(entity.id).get();
    if (!doc.exists) {
      throw NotFoundException(
        'Không tìm thấy bản ghi sau khi cập nhật: ${entity.id}',
      );
    }
    return ModelModel.fromFirestore(doc);
  }

  @override
  Future<void> archiveModel(String id) async {
    await _ensureNoActiveChildren(id);
    await _collection.doc(id).update({
      'status': CatalogStatus.archived.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> restoreModel(String id) async {
    await _collection.doc(id).update({
      'status': CatalogStatus.active.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Client-side uniqueness guard, executed immediately before the write.
  /// Not transactional — a narrow race window is accepted (see sprint notes).
  Future<void> _ensureUniqueCode(String code,
      {String? exceptId, required String productFamilyId}) async {
    final snapshot = await _collection
        .where('code', isEqualTo: code.trim())
        .where('productFamilyId', isEqualTo: productFamilyId)
        .get();
    final clashes = snapshot.docs.where((d) => d.id != exceptId);
    if (clashes.isNotEmpty) {
      throw DuplicateCodeException(
          'Mã "$code" đã tồn tại trong dòng sản phẩm này.');
    }
  }

  /// Archiving is blocked while any ACTIVE child record still references this
  /// document. Already-archived children never block.
  Future<void> _ensureNoActiveChildren(String id) async {
    final variantsSnapshot = await _firestore
        .collection(FirestoreConstants.variants)
        .where('modelId', isEqualTo: id)
        .where('status', isEqualTo: CatalogStatus.active.name)
        .limit(1)
        .get();
    if (variantsSnapshot.docs.isNotEmpty) {
      throw const HasActiveChildrenException(
        'Không thể lưu trữ vì vẫn còn phiên bản đang hoạt động. '
        'Vui lòng lưu trữ các bản ghi con trước.',
      );
    }
    final repairServicesSnapshot = await _firestore
        .collection(FirestoreConstants.repairServices)
        .where('modelId', isEqualTo: id)
        .where('status', isEqualTo: CatalogStatus.active.name)
        .limit(1)
        .get();
    if (repairServicesSnapshot.docs.isNotEmpty) {
      throw const HasActiveChildrenException(
        'Không thể lưu trữ vì vẫn còn dịch vụ sửa chữa đang hoạt động. '
        'Vui lòng lưu trữ các bản ghi con trước.',
      );
    }
  }
}
