import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/value_objects/service_category_filter.dart';
import '../models/service_category_model.dart';
import 'service_category_remote_datasource.dart';

class FirebaseServiceCategoryRemoteDataSource
    implements ServiceCategoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseServiceCategoryRemoteDataSource(
      {required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.serviceCategories);

  @override
  Future<ServiceCategoryModel> getServiceCategory(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy bản ghi: $id');
    }
    return ServiceCategoryModel.fromFirestore(doc);
  }

  @override
  Future<PaginatedResult<ServiceCategoryModel>> getServiceCategories(
    ServiceCategoryFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (filter.status != null) {
      query = query.where('status', isEqualTo: filter.status!.name);
    }

    if (filter.enabled != null) {
      query = query.where('enabled', isEqualTo: filter.enabled);
    }

    // Category lists are small (a few dozen at most) and driven by `order`,
    // matching the CMS default sort — see Sprint handoff notes for the
    // catalog collections' `orderBy('name')` convention this deviates from.
    query = query.orderBy('order').orderBy('name').limit(filter.pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final models =
        snapshot.docs.map((ServiceCategoryModel.fromFirestore)).toList();

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
  Future<List<ServiceCategoryModel>> getActiveServiceCategories() async {
    final snapshot = await _collection
        .where('status', isEqualTo: CatalogStatus.active.name)
        .orderBy('order')
        .orderBy('name')
        .get();
    return snapshot.docs.map((ServiceCategoryModel.fromFirestore)).toList();
  }

  @override
  Future<ServiceCategoryModel> createServiceCategory(
      ServiceCategoryModel entity) async {
    await _ensureUniqueCode(entity.code);

    final ref = _collection.doc();
    final now = DateTime.now();
    final created = ServiceCategoryModel(
      id: ref.id,
      code: entity.code,
      name: entity.name,
      description: entity.description,
      enabled: entity.enabled,
      order: entity.order,
      status: CatalogStatus.active,
      createdAt: now,
      updatedAt: now,
      createdBy: entity.createdBy,
    );

    await ref.set(created.toFirestore());
    return created;
  }

  @override
  Future<ServiceCategoryModel> updateServiceCategory(
      ServiceCategoryModel entity) async {
    await _ensureUniqueCode(entity.code, exceptId: entity.id);

    await _collection.doc(entity.id).update(entity.toUpdateMap());
    final doc = await _collection.doc(entity.id).get();
    if (!doc.exists) {
      throw NotFoundException(
        'Không tìm thấy bản ghi sau khi cập nhật: ${entity.id}',
      );
    }
    return ServiceCategoryModel.fromFirestore(doc);
  }

  @override
  Future<void> archiveServiceCategory(String id) async {
    await _ensureNoActiveChildren(id);
    await _collection.doc(id).update({
      'status': CatalogStatus.archived.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> restoreServiceCategory(String id) async {
    await _collection.doc(id).update({
      'status': CatalogStatus.active.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Client-side uniqueness guard, executed immediately before the write.
  /// Not transactional — a narrow race window is accepted (see sprint notes).
  Future<void> _ensureUniqueCode(String code, {String? exceptId}) async {
    final snapshot =
        await _collection.where('code', isEqualTo: code.trim()).get();
    final clashes = snapshot.docs.where((d) => d.id != exceptId);
    if (clashes.isNotEmpty) {
      throw DuplicateCodeException('Mã "$code" đã tồn tại.');
    }
  }

  /// Archiving is blocked while any ACTIVE repair_services document still
  /// references this category. Already-archived services never block.
  Future<void> _ensureNoActiveChildren(String id) async {
    final snapshot = await _firestore
        .collection(FirestoreConstants.repairServices)
        .where('categoryId', isEqualTo: id)
        .where('status', isEqualTo: CatalogStatus.active.name)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      throw const HasActiveChildrenException(
        'Không thể lưu trữ vì vẫn còn dịch vụ sửa chữa đang hoạt động '
        'thuộc nhóm này. Vui lòng lưu trữ các dịch vụ đó trước.',
      );
    }
  }
}
