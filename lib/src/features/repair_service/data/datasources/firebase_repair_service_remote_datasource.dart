import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/value_objects/repair_service_filter.dart';
import '../models/repair_service_model.dart';
import 'repair_service_remote_datasource.dart';

class FirebaseRepairServiceRemoteDataSource
    implements RepairServiceRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseRepairServiceRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.repairServices);

  @override
  Future<RepairServiceModel> getRepairService(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy bản ghi: $id');
    }
    return RepairServiceModel.fromFirestore(doc);
  }

  @override
  Future<PaginatedResult<RepairServiceModel>> getRepairServices(
    RepairServiceFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (filter.parentId != null) {
      query = query.where('modelId', isEqualTo: filter.parentId);
    }

    if (filter.categoryId != null) {
      query = query.where('categoryId', isEqualTo: filter.categoryId);
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
        snapshot.docs.map((RepairServiceModel.fromFirestore)).toList();

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
  Future<List<RepairServiceModel>> getActiveRepairServices(
      {String? parentId}) async {
    Query<Map<String, dynamic>> query =
        _collection.where('status', isEqualTo: CatalogStatus.active.name);

    if (parentId != null) {
      query = query.where('modelId', isEqualTo: parentId);
    }

    final snapshot = await query.orderBy('name').get();
    return snapshot.docs.map((RepairServiceModel.fromFirestore)).toList();
  }

  @override
  Future<RepairServiceModel> createRepairService(
      RepairServiceModel entity) async {
    _ensureValid(entity);
    await _ensureUniqueModelPerCategory(entity.categoryId, entity.modelId);

    final ref = _collection.doc();
    final now = DateTime.now();
    final created = RepairServiceModel(
      id: ref.id,
      categoryId: entity.categoryId,
      modelId: entity.modelId,
      name: entity.name,
      description: entity.description,
      enabled: entity.enabled,
      order: entity.order,
      variants: entity.variants,
      status: CatalogStatus.active,
      createdAt: now,
      updatedAt: now,
      createdBy: entity.createdBy,
    );

    await ref.set(created.toFirestore());
    return created;
  }

  @override
  Future<RepairServiceModel> updateRepairService(
      RepairServiceModel entity) async {
    _ensureValid(entity);
    await _ensureUniqueModelPerCategory(
      entity.categoryId,
      entity.modelId,
      exceptId: entity.id,
    );

    await _collection.doc(entity.id).update(entity.toUpdateMap());
    final doc = await _collection.doc(entity.id).get();
    if (!doc.exists) {
      throw NotFoundException(
        'Không tìm thấy bản ghi sau khi cập nhật: ${entity.id}',
      );
    }
    return RepairServiceModel.fromFirestore(doc);
  }

  @override
  Future<void> archiveRepairService(String id) async {
    await _collection.doc(id).update({
      'status': CatalogStatus.archived.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> restoreRepairService(String id) async {
    await _collection.doc(id).update({
      'status': CatalogStatus.active.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Pure domain validation (price >= 0, no duplicate variant/addon codes) —
  /// see [RepairServiceEntity.validationErrors]. Re-checked here so an
  /// invalid document can never reach Firestore even if a future caller
  /// bypasses the CMS form's own pre-submit check.
  void _ensureValid(RepairServiceModel entity) {
    final errors = entity.validationErrors();
    if (errors.isNotEmpty) {
      throw CatalogValidationException(errors.join(' '));
    }
  }

  /// Business rule: within one Service Category, a Device Model has at most
  /// one repair_services document — the key is (categoryId, modelId), never
  /// name, so renaming a service can never break uniqueness.
  ///
  /// Legacy documents with `categoryId == null` predate this rule and are
  /// intentionally excluded from the check — categoryId is required at the
  /// CMS form layer for every new/edited service going forward.
  Future<void> _ensureUniqueModelPerCategory(
    String? categoryId,
    String modelId, {
    String? exceptId,
  }) async {
    if (categoryId == null) return;

    final snapshot = await _collection
        .where('categoryId', isEqualTo: categoryId)
        .where('modelId', isEqualTo: modelId)
        .get();
    final clashes = snapshot.docs.where((d) => d.id != exceptId);
    if (clashes.isNotEmpty) {
      throw const DuplicateCodeException(
        'Model máy này đã có dịch vụ trong nhóm dịch vụ đã chọn.',
      );
    }
  }
}
