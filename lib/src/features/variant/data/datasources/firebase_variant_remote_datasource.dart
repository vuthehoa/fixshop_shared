import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/value_objects/variant_filter.dart';
import '../models/variant_model.dart';
import 'variant_remote_datasource.dart';

class FirebaseVariantRemoteDataSource implements VariantRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseVariantRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.variants);

  @override
  Future<VariantModel> getVariant(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy bản ghi: $id');
    }
    return VariantModel.fromFirestore(doc);
  }

  @override
  Future<PaginatedResult<VariantModel>> getVariants(
    VariantFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (filter.parentId != null) {
      query = query.where('modelId', isEqualTo: filter.parentId);
    }

    if (filter.status != null) {
      query = query.where('status', isEqualTo: filter.status!.name);
    }

    query = query.orderBy('name').limit(filter.pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final models = snapshot.docs.map((VariantModel.fromFirestore)).toList();

    // Client-side text search — Firestore has no native full-text search.
    final filtered =
        filter.searchQuery == null || filter.searchQuery!.trim().isEmpty
            ? models
            : models.where((m) {
                final q = filter.searchQuery!.trim().toLowerCase();
                return m.name.toLowerCase().contains(q);
              }).toList();

    return PaginatedResult(
      items: filtered,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == filter.pageSize,
    );
  }

  @override
  Future<List<VariantModel>> getActiveVariants({String? parentId}) async {
    Query<Map<String, dynamic>> query =
        _collection.where('status', isEqualTo: CatalogStatus.active.name);

    if (parentId != null) {
      query = query.where('modelId', isEqualTo: parentId);
    }

    final snapshot = await query.orderBy('name').get();
    return snapshot.docs.map((VariantModel.fromFirestore)).toList();
  }

  @override
  Future<VariantModel> createVariant(VariantModel entity) async {
    await _ensureUniqueName(entity.name, modelId: entity.modelId);

    final ref = _collection.doc();
    final now = DateTime.now();
    final created = VariantModel(
      id: ref.id,
      name: entity.name,
      modelId: entity.modelId,
      status: CatalogStatus.active,
      createdAt: now,
      updatedAt: now,
      createdBy: entity.createdBy,
    );

    await ref.set(created.toFirestore());
    return created;
  }

  @override
  Future<VariantModel> updateVariant(VariantModel entity) async {
    await _ensureUniqueName(entity.name,
        exceptId: entity.id, modelId: entity.modelId);

    await _collection.doc(entity.id).update(entity.toUpdateMap());
    final doc = await _collection.doc(entity.id).get();
    if (!doc.exists) {
      throw NotFoundException(
        'Không tìm thấy bản ghi sau khi cập nhật: ${entity.id}',
      );
    }
    return VariantModel.fromFirestore(doc);
  }

  @override
  Future<void> archiveVariant(String id) async {
    await _collection.doc(id).update({
      'status': CatalogStatus.archived.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> restoreVariant(String id) async {
    await _collection.doc(id).update({
      'status': CatalogStatus.active.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Client-side uniqueness guard, executed immediately before the write.
  /// Not transactional — a narrow race window is accepted (see sprint notes).
  Future<void> _ensureUniqueName(String name,
      {String? exceptId, required String modelId}) async {
    final snapshot = await _collection
        .where('name', isEqualTo: name.trim())
        .where('modelId', isEqualTo: modelId)
        .get();
    final clashes = snapshot.docs.where((d) => d.id != exceptId);
    if (clashes.isNotEmpty) {
      throw DuplicateCodeException(
          'Tên "$name" đã tồn tại trong model máy này.');
    }
  }
}
