import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/value_objects/device_filter.dart';
import '../models/device_model.dart';
import 'device_remote_datasource.dart';

class FirebaseDeviceRemoteDataSource implements DeviceRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirebaseDeviceRemoteDataSource({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestoreConstants.devices);

  @override
  Future<DeviceModel> getDevice(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy thiết bị: $id');
    }
    return DeviceModel.fromFirestore(doc);
  }

  @override
  Future<DeviceModel> getDeviceByCode(String deviceCode) async {
    final snapshot = await _collection
        .where('deviceCode', isEqualTo: deviceCode.trim())
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) {
      throw NotFoundException('Không tìm thấy thiết bị với mã: $deviceCode');
    }
    return DeviceModel.fromFirestore(snapshot.docs.first);
  }

  @override
  Future<PaginatedResult<DeviceModel>> getDevices(
    DeviceFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _collection;

    if (filter.status != null) {
      query = query.where('status', isEqualTo: filter.status!.name);
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
    if (filter.customerId != null) {
      query = query.where('customerId', isEqualTo: filter.customerId);
    }
    if (filter.createdFrom != null) {
      query = query.where('createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(filter.createdFrom!));
    }
    if (filter.createdTo != null) {
      query = query.where('createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(filter.createdTo!));
    }
    if (filter.warrantyExpiringFrom != null) {
      query = query.where('warrantyExpiredAt',
          isGreaterThanOrEqualTo:
              Timestamp.fromDate(filter.warrantyExpiringFrom!));
    }
    if (filter.warrantyExpiringTo != null) {
      query = query.where('warrantyExpiredAt',
          isLessThanOrEqualTo: Timestamp.fromDate(filter.warrantyExpiringTo!));
    }

    query = query.orderBy('createdAt', descending: true).limit(filter.pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final models = snapshot.docs.map((DeviceModel.fromFirestore)).toList();

    // Client-side text search — Firestore has no native full-text search.
    // Covers the denormalized relation names too (customer/manufacturer/model)
    // and the derived QR payload, so the search box works without an N+1
    // join per row.
    final searched =
        filter.searchQuery == null || filter.searchQuery!.trim().isEmpty
            ? models
            : models.where((d) {
                final q = filter.searchQuery!.trim().toLowerCase();
                return d.deviceCode.toLowerCase().contains(q) ||
                    d.serialNumber.toLowerCase().contains(q) ||
                    (d.imei?.toLowerCase().contains(q) ?? false) ||
                    d.deviceName.toLowerCase().contains(q) ||
                    d.customerName.toLowerCase().contains(q) ||
                    d.customerPhone.toLowerCase().contains(q) ||
                    d.manufacturerName.toLowerCase().contains(q) ||
                    d.modelName.toLowerCase().contains(q) ||
                    d.qrPayload.toLowerCase().contains(q);
              }).toList();

    // Warranty status is derived from activation/expiration/void timestamps
    // plus "now" (see [WarrantyStatus] doc) — it can't be queried server-side
    // as a stable field, so it's filtered client-side after the page fetch,
    // same as the text search above.
    final filtered = filter.warrantyStatus == null
        ? searched
        : searched
            .where((d) => d.warrantyStatus == filter.warrantyStatus)
            .toList();

    return PaginatedResult(
      items: filtered,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == filter.pageSize,
    );
  }

  @override
  Future<List<DeviceModel>> getActiveDevices({String? customerId}) async {
    Query<Map<String, dynamic>> query = _collection;
    if (customerId != null) {
      query = query.where('customerId', isEqualTo: customerId);
    }

    final snapshot = await query.orderBy('deviceName').get();
    return snapshot.docs
        .map((DeviceModel.fromFirestore))
        .where((d) => d.status != DeviceStatus.archived)
        .toList();
  }

  @override
  Future<DeviceModel> createDevice(DeviceModel entity) async {
    await _ensureUniqueDeviceCode(entity.deviceCode);
    await _ensureUniqueSerialNumber(entity.serialNumber);
    if (entity.imei != null && entity.imei!.trim().isNotEmpty) {
      await _ensureUniqueImei(entity.imei!);
    }

    final ref = _collection.doc();
    final now = DateTime.now();
    final created = DeviceModel(
      id: ref.id,
      deviceCode: entity.deviceCode,
      customerId: entity.customerId,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      manufacturerId: entity.manufacturerId,
      manufacturerName: entity.manufacturerName,
      productFamilyId: entity.productFamilyId,
      productFamilyName: entity.productFamilyName,
      modelId: entity.modelId,
      modelName: entity.modelName,
      variantId: entity.variantId,
      variantName: entity.variantName,
      deviceName: entity.deviceName,
      serialNumber: entity.serialNumber,
      imei: entity.imei,
      purchaseDate: entity.purchaseDate,
      purchaseLocation: entity.purchaseLocation,
      invoiceNumber: entity.invoiceNumber,
      photoUrls: entity.photoUrls,
      status: DeviceStatus.registered,
      note: entity.note,
      createdAt: now,
      updatedAt: now,
      createdBy: entity.createdBy,
    );

    await ref.set(created.toFirestore());
    return created;
  }

  @override
  Future<DeviceModel> updateDevice(DeviceModel entity) async {
    await _ensureUniqueDeviceCode(entity.deviceCode, exceptId: entity.id);
    await _ensureUniqueSerialNumber(entity.serialNumber, exceptId: entity.id);
    if (entity.imei != null && entity.imei!.trim().isNotEmpty) {
      await _ensureUniqueImei(entity.imei!, exceptId: entity.id);
    }

    await _collection.doc(entity.id).update(entity.toUpdateMap());
    final doc = await _collection.doc(entity.id).get();
    if (!doc.exists) {
      throw NotFoundException(
        'Không tìm thấy thiết bị sau khi cập nhật: ${entity.id}',
      );
    }
    return DeviceModel.fromFirestore(doc);
  }

  @override
  Future<void> archiveDevice(String id) async {
    await _collection.doc(id).update({
      'status': DeviceStatus.archived.name,
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> restoreDevice(String id) async {
    await _collection.doc(id).update({
      'status': DeviceStatus.active.name,
      'deletedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<DeviceModel> activateWarranty(String id,
      {required int warrantyPeriodMonths}) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy thiết bị: $id');
    }
    final current = DeviceModel.fromFirestore(doc);

    if (current.status == DeviceStatus.archived) {
      throw const OperationNotAllowedException(
        'Không thể kích hoạt bảo hành cho thiết bị đã lưu trữ.',
      );
    }
    if (current.warrantyActivatedAt != null) {
      throw const OperationNotAllowedException(
          'Bảo hành đã được kích hoạt trước đó.');
    }
    if (current.customerId.trim().isEmpty) {
      throw const OperationNotAllowedException('Thiết bị chưa có khách hàng.');
    }
    if (current.purchaseDate == null) {
      throw const OperationNotAllowedException('Thiết bị chưa có ngày mua.');
    }

    final now = DateTime.now();
    final expiredAt =
        DateTime(now.year, now.month + warrantyPeriodMonths, now.day);

    await _collection.doc(id).update({
      'warrantyActivatedAt': Timestamp.fromDate(now),
      'warrantyExpiredAt': Timestamp.fromDate(expiredAt),
      'warrantyPeriodMonths': warrantyPeriodMonths,
      'warrantyVoidedAt': null,
      'status': DeviceStatus.underWarranty.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updated = await _collection.doc(id).get();
    return DeviceModel.fromFirestore(updated);
  }

  @override
  Future<DeviceModel> voidWarranty(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy thiết bị: $id');
    }
    final current = DeviceModel.fromFirestore(doc);
    if (current.warrantyActivatedAt == null) {
      throw const OperationNotAllowedException(
          'Thiết bị chưa kích hoạt bảo hành.');
    }

    await _collection.doc(id).update({
      'warrantyVoidedAt': Timestamp.fromDate(DateTime.now()),
      // Warranty ending early still leaves the device usable — fall back to
      // the plain "active" lifecycle state, only when it was under warranty.
      if (current.status == DeviceStatus.underWarranty)
        'status': DeviceStatus.active.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updated = await _collection.doc(id).get();
    return DeviceModel.fromFirestore(updated);
  }

  @override
  Future<DeviceModel> restoreWarranty(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      throw NotFoundException('Không tìm thấy thiết bị: $id');
    }
    final current = DeviceModel.fromFirestore(doc);
    if (current.warrantyVoidedAt == null) {
      throw const OperationNotAllowedException('Bảo hành chưa bị huỷ.');
    }

    await _collection.doc(id).update({
      'warrantyVoidedAt': null,
      if (current.status == DeviceStatus.active)
        'status': DeviceStatus.underWarranty.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updated = await _collection.doc(id).get();
    return DeviceModel.fromFirestore(updated);
  }

  /// Client-side uniqueness guard, executed immediately before the write.
  /// Not transactional — a narrow race window is accepted (see sprint notes).
  Future<void> _ensureUniqueDeviceCode(String code, {String? exceptId}) async {
    final snapshot =
        await _collection.where('deviceCode', isEqualTo: code.trim()).get();
    final clashes = snapshot.docs.where((d) => d.id != exceptId);
    if (clashes.isNotEmpty) {
      throw DuplicateCodeException('Mã thiết bị "$code" đã tồn tại.');
    }
  }

  Future<void> _ensureUniqueSerialNumber(String serial,
      {String? exceptId}) async {
    final snapshot =
        await _collection.where('serialNumber', isEqualTo: serial.trim()).get();
    final clashes = snapshot.docs.where((d) => d.id != exceptId);
    if (clashes.isNotEmpty) {
      throw DuplicateSerialNumberException('Số serial "$serial" đã tồn tại.');
    }
  }

  Future<void> _ensureUniqueImei(String imei, {String? exceptId}) async {
    final snapshot =
        await _collection.where('imei', isEqualTo: imei.trim()).get();
    final clashes = snapshot.docs.where((d) => d.id != exceptId);
    if (clashes.isNotEmpty) {
      throw DuplicateImeiException('Số IMEI "$imei" đã tồn tại.');
    }
  }
}
