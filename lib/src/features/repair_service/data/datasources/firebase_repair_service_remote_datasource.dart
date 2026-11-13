import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../activity_log/data/models/activity_log_model.dart';
import '../../../activity_log/domain/entities/activity_log_entity.dart';
import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/services/catalog_eligibility.dart';
import '../../domain/value_objects/repair_service_filter.dart';
import '../../domain/value_objects/repair_service_write_context.dart';
import '../models/catalog_eligibility_model.dart';
import '../models/repair_service_model.dart';
import 'repair_service_remote_datasource.dart';

class FirebaseRepairServiceRemoteDataSource
    implements RepairServiceRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseRepairServiceRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.repairServices);

  /// `catalog_eligibility/{serviceId}` — written in the SAME batch /
  /// transaction as EVERY `repair_services` write below (create, update,
  /// archive, restore). Firestore Rules reject a service write without it.
  CollectionReference<Map<String, dynamic>> get _eligibility =>
      _firestore.collection(FirestoreConstants.catalogEligibility);

  CollectionReference<Map<String, dynamic>> get _activityLogs =>
      _firestore.collection(FirestoreConstants.activityLogs);

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
    RepairServiceModel entity, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  }) async {
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

    final batch = _firestore.batch();
    batch.set(ref, created.toFirestore());
    batch.set(
      _eligibility.doc(ref.id),
      CatalogEligibilityModel.fromService(created, source: context.source),
    );
    await batch.commit();
    return created;
  }

  @override
  Future<RepairServiceModel> updateRepairService(
    RepairServiceModel entity, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  }) async {
    _ensureValid(entity);
    await _ensureUniqueModelPerCategory(
      entity.categoryId,
      entity.modelId,
      exceptId: entity.id,
    );

    final ref = _collection.doc(entity.id);
    // Transaction (not a blind batch): eligibility depends on the CURRENT
    // `status` (an update never changes it) and the price audit needs the
    // previous variants — both must be read atomically with the write.
    await _firestore.runTransaction<void>((tx) async {
      final snapshot = await tx.get(ref);
      if (!snapshot.exists) {
        throw NotFoundException('Không tìm thấy bản ghi: ${entity.id}');
      }
      final before = RepairServiceModel.fromFirestore(snapshot);

      tx.update(ref, entity.toUpdateMap());
      tx.set(
        _eligibility.doc(entity.id),
        CatalogEligibilityModel.toFirestore(
          modelId: entity.modelId,
          offers: computeEligibilityOffers(
            status: before.status,
            enabled: entity.enabled,
            variants: entity.variants,
          ),
          source: context.source,
        ),
      );

      final audit = buildPricingAuditMetadata(before: before, after: entity);
      if (audit != null && context.canAudit) {
        tx.set(
          _activityLogs.doc(),
          ActivityLogModel(
            id: '',
            actorId: context.actorId!,
            actorRole: context.actorRole!,
            action: ActivityActions.updateRepairServicePricing,
            targetId: entity.id,
            targetType: ActivityTargetTypes.repairService,
            metadata: audit,
            timestamp: DateTime.now(), // stored as serverTimestamp()
          ).toFirestore(),
        );
      }
    });

    final doc = await ref.get();
    if (!doc.exists) {
      throw NotFoundException(
        'Không tìm thấy bản ghi sau khi cập nhật: ${entity.id}',
      );
    }
    return RepairServiceModel.fromFirestore(doc);
  }

  @override
  Future<void> archiveRepairService(
    String id, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  }) =>
      _setStatus(id, CatalogStatus.archived, context);

  @override
  Future<void> restoreRepairService(
    String id, {
    RepairServiceWriteContext context = const RepairServiceWriteContext(),
  }) =>
      _setStatus(id, CatalogStatus.active, context);

  /// Archive/restore: flips `status` and re-derives `catalog_eligibility`
  /// from the stored document (raw — exactly what Rules will compare
  /// against) in the same transaction. Archived ⇒ `offers = {}`.
  Future<void> _setStatus(
    String id,
    CatalogStatus status,
    RepairServiceWriteContext context,
  ) async {
    final ref = _collection.doc(id);
    await _firestore.runTransaction<void>((tx) async {
      final snapshot = await tx.get(ref);
      if (!snapshot.exists) {
        throw NotFoundException('Không tìm thấy bản ghi: $id');
      }
      final data = Map<String, dynamic>.of(snapshot.data()!);
      data['status'] = status.name;

      tx.update(ref, {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      tx.set(
        _eligibility.doc(id),
        CatalogEligibilityModel.toFirestore(
          modelId: data['modelId'] as String? ?? '',
          offers: computeEligibilityOffersFromDocument(data),
          source: context.source,
        ),
      );
    });
  }

  /// Pure domain validation (enabled variants priced > 0, no negative
  /// prices, no duplicate variant/addon codes) —
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
