import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../catalog_common/domain/enums/catalog_status.dart';
import '../../domain/value_objects/customer_filter.dart';
import '../models/customer_model.dart';
import 'customer_remote_datasource.dart';

class FirebaseCustomerRemoteDataSource implements CustomerRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseCustomerRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.customers);

  @override
  Future<CustomerModel> getCustomer(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy khách hàng: $id');
    }
    return CustomerModel.fromFirestore(doc);
  }

  @override
  Future<PaginatedResult<CustomerModel>> getCustomers(
    CustomerFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (filter.status != null) {
      query = query.where('status', isEqualTo: filter.status!.name);
    }
    if (filter.province != null && filter.province!.trim().isNotEmpty) {
      query = query.where('province', isEqualTo: filter.province);
    }
    if (filter.createdFrom != null) {
      query = query.where('createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(filter.createdFrom!));
    }
    if (filter.createdTo != null) {
      query = query.where('createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(filter.createdTo!));
    }

    query = query.orderBy('createdAt', descending: true).limit(filter.pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final models = snapshot.docs.map((CustomerModel.fromFirestore)).toList();

    // Client-side text search — Firestore has no native full-text search.
    final filtered =
        filter.searchQuery == null || filter.searchQuery!.trim().isEmpty
            ? models
            : models.where((c) {
                final q = filter.searchQuery!.trim().toLowerCase();
                return c.customerCode.toLowerCase().contains(q) ||
                    c.fullName.toLowerCase().contains(q) ||
                    c.phone.toLowerCase().contains(q) ||
                    (c.email?.toLowerCase().contains(q) ?? false);
              }).toList();

    return PaginatedResult(
      items: filtered,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == filter.pageSize,
    );
  }

  @override
  Future<List<CustomerModel>> getActiveCustomers() async {
    final snapshot = await _collection
        .where('status', isEqualTo: CatalogStatus.active.name)
        .orderBy('fullName')
        .get();
    return snapshot.docs.map((CustomerModel.fromFirestore)).toList();
  }

  @override
  Future<CustomerModel> createCustomer(CustomerModel entity) async {
    await _ensureUniqueCode(entity.customerCode);
    await _ensureUniquePhone(entity.phone);
    if (entity.email != null && entity.email!.trim().isNotEmpty) {
      await _ensureUniqueEmail(entity.email!);
    }

    final ref = _collection.doc();
    final now = DateTime.now();
    final created = CustomerModel(
      id: ref.id,
      customerCode: entity.customerCode,
      fullName: entity.fullName,
      phone: entity.phone,
      email: entity.email,
      gender: entity.gender,
      birthday: entity.birthday,
      address: entity.address,
      province: entity.province,
      district: entity.district,
      ward: entity.ward,
      avatarUrl: entity.avatarUrl,
      status: CatalogStatus.active,
      note: entity.note,
      createdAt: now,
      updatedAt: now,
      createdBy: entity.createdBy,
    );

    await ref.set(created.toFirestore());
    return created;
  }

  @override
  Future<CustomerModel> updateCustomer(CustomerModel entity) async {
    await _ensureUniqueCode(entity.customerCode, exceptId: entity.id);
    await _ensureUniquePhone(entity.phone, exceptId: entity.id);
    if (entity.email != null && entity.email!.trim().isNotEmpty) {
      await _ensureUniqueEmail(entity.email!, exceptId: entity.id);
    }

    await _collection.doc(entity.id).update(entity.toUpdateMap());
    final doc = await _collection.doc(entity.id).get();
    if (!doc.exists) {
      throw NotFoundException(
        'Không tìm thấy khách hàng sau khi cập nhật: ${entity.id}',
      );
    }
    return CustomerModel.fromFirestore(doc);
  }

  @override
  Future<void> archiveCustomer(String id) async {
    await _collection.doc(id).update({
      'status': CatalogStatus.archived.name,
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> restoreCustomer(String id) async {
    await _collection.doc(id).update({
      'status': CatalogStatus.active.name,
      'deletedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Client-side uniqueness guard, executed immediately before the write.
  /// Not transactional — a narrow race window is accepted (see sprint notes).
  Future<void> _ensureUniqueCode(String code, {String? exceptId}) async {
    final snapshot =
        await _collection.where('customerCode', isEqualTo: code.trim()).get();
    final clashes = snapshot.docs.where((d) => d.id != exceptId);
    if (clashes.isNotEmpty) {
      throw DuplicateCodeException('Mã khách hàng "$code" đã tồn tại.');
    }
  }

  Future<void> _ensureUniquePhone(String phone, {String? exceptId}) async {
    final snapshot =
        await _collection.where('phone', isEqualTo: phone.trim()).get();
    final clashes = snapshot.docs.where((d) => d.id != exceptId);
    if (clashes.isNotEmpty) {
      throw DuplicatePhoneException('Số điện thoại "$phone" đã tồn tại.');
    }
  }

  Future<void> _ensureUniqueEmail(String email, {String? exceptId}) async {
    final snapshot =
        await _collection.where('email', isEqualTo: email.trim()).get();
    final clashes = snapshot.docs.where((d) => d.id != exceptId);
    if (clashes.isNotEmpty) {
      throw DuplicateEmailException('Email "$email" đã tồn tại.');
    }
  }
}
