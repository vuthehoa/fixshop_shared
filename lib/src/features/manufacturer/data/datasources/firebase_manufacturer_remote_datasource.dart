import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/value_objects/manufacturer_filter.dart';
import '../models/manufacturer_model.dart';
import 'manufacturer_remote_datasource.dart';

class FirebaseManufacturerRemoteDataSource
    implements ManufacturerRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseManufacturerRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.manufacturers);

  @override
  Future<ManufacturerModel> getManufacturer(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy bản ghi: $id');
    }
    return ManufacturerModel.fromFirestore(doc);
  }

  @override
  Future<PaginatedResult<ManufacturerModel>> getManufacturers(
    ManufacturerFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (filter.status != null) {
      query = query.where('status', isEqualTo: filter.status!.name);
    }

    query = query.orderBy('name').limit(filter.pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final models =
        snapshot.docs.map((ManufacturerModel.fromFirestore)).toList();

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
  Future<List<ManufacturerModel>> getActiveManufacturers() async {
    Query<Map<String, dynamic>> query =
        _collection.where('status', isEqualTo: CatalogStatus.active.name);

    final snapshot = await query.orderBy('name').get();
    return snapshot.docs.map((ManufacturerModel.fromFirestore)).toList();
  }

  @override
  Future<ManufacturerModel> createManufacturer(ManufacturerModel entity) async {
    await _ensureUniqueCode(entity.code);

    // A non-empty pre-assigned id (CMS reserves one so catalog images can be
    // uploaded to catalog/<collection>/<id>/ BEFORE the first save) is
    // honoured, but never allowed to overwrite an existing document.
    final ref = await _newDocRef(entity.id);
    final now = DateTime.now();
    final created = ManufacturerModel(
      id: ref.id,
      code: entity.code,
      name: entity.name,
      description: entity.description,
      logoUrl: entity.logoUrl,
      coverUrl: entity.coverUrl,
      status: CatalogStatus.active,
      createdAt: now,
      updatedAt: now,
      createdBy: entity.createdBy,
    );

    await ref.set(created.toFirestore());
    return created;
  }

  @override
  Future<ManufacturerModel> updateManufacturer(ManufacturerModel entity) async {
    await _ensureUniqueCode(entity.code, exceptId: entity.id);

    await _collection.doc(entity.id).update(entity.toUpdateMap());
    final doc = await _collection.doc(entity.id).get();
    if (!doc.exists) {
      throw NotFoundException(
        'Không tìm thấy bản ghi sau khi cập nhật: ${entity.id}',
      );
    }
    return ManufacturerModel.fromFirestore(doc);
  }

  @override
  Future<void> archiveManufacturer(String id) async {
    await _ensureNoActiveChildren(id);
    await _collection.doc(id).update({
      'status': CatalogStatus.archived.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> restoreManufacturer(String id) async {
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

  /// Archiving is blocked while any ACTIVE child record still references this
  /// document. Already-archived children never block.
  Future<void> _ensureNoActiveChildren(String id) async {
    final productFamiliesSnapshot = await _firestore
        .collection(FirestoreConstants.productFamilies)
        .where('manufacturerId', isEqualTo: id)
        .where('status', isEqualTo: CatalogStatus.active.name)
        .limit(1)
        .get();
    if (productFamiliesSnapshot.docs.isNotEmpty) {
      throw const HasActiveChildrenException(
        'Không thể lưu trữ vì vẫn còn dòng sản phẩm đang hoạt động. '
        'Vui lòng lưu trữ các bản ghi con trước.',
      );
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> _newDocRef(String id) async {
    if (id.trim().isEmpty) return _collection.doc();
    final ref = _collection.doc(id.trim());
    if ((await ref.get()).exists) {
      throw DuplicateCodeException('Bản ghi $id đã tồn tại.');
    }
    return ref;
  }
}
