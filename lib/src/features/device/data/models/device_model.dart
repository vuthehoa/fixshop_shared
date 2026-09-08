import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/device_entity.dart';

class DeviceModel extends DeviceEntity {
  const DeviceModel({
    required super.id,
    required super.deviceCode,
    required super.customerId,
    required super.customerName,
    required super.customerPhone,
    required super.manufacturerId,
    required super.manufacturerName,
    required super.productFamilyId,
    required super.productFamilyName,
    required super.modelId,
    required super.modelName,
    super.variantId,
    super.variantName,
    required super.deviceName,
    required super.serialNumber,
    super.imei,
    super.purchaseDate,
    super.purchaseLocation,
    super.invoiceNumber,
    super.warrantyActivatedAt,
    super.warrantyExpiredAt,
    super.warrantyPeriodMonths,
    super.warrantyVoidedAt,
    super.photoUrls,
    super.note,
    super.status,
    super.createdBy,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory DeviceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeviceModel(
      id: doc.id,
      deviceCode: data['deviceCode'] as String? ?? '',
      customerId: data['customerId'] as String? ?? '',
      customerName: data['customerName'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      manufacturerId: data['manufacturerId'] as String? ?? '',
      manufacturerName: data['manufacturerName'] as String? ?? '',
      productFamilyId: data['productFamilyId'] as String? ?? '',
      productFamilyName: data['productFamilyName'] as String? ?? '',
      modelId: data['modelId'] as String? ?? '',
      modelName: data['modelName'] as String? ?? '',
      variantId: data['variantId'] as String?,
      variantName: data['variantName'] as String?,
      deviceName: data['deviceName'] as String? ?? '',
      serialNumber: data['serialNumber'] as String? ?? '',
      imei: data['imei'] as String?,
      purchaseDate: (data['purchaseDate'] as Timestamp?)?.toDate(),
      purchaseLocation: data['purchaseLocation'] as String?,
      invoiceNumber: data['invoiceNumber'] as String?,
      warrantyActivatedAt:
          (data['warrantyActivatedAt'] as Timestamp?)?.toDate(),
      warrantyExpiredAt: (data['warrantyExpiredAt'] as Timestamp?)?.toDate(),
      warrantyPeriodMonths: data['warrantyPeriodMonths'] as int?,
      warrantyVoidedAt: (data['warrantyVoidedAt'] as Timestamp?)?.toDate(),
      photoUrls:
          (data['photoUrls'] as List<dynamic>?)?.cast<String>() ?? const [],
      note: data['note'] as String?,
      status: DeviceStatus.fromName(data['status'] as String?),
      createdBy: data['createdBy'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deletedAt: (data['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory DeviceModel.fromEntity(DeviceEntity entity) {
    return DeviceModel(
      id: entity.id,
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
      warrantyActivatedAt: entity.warrantyActivatedAt,
      warrantyExpiredAt: entity.warrantyExpiredAt,
      warrantyPeriodMonths: entity.warrantyPeriodMonths,
      warrantyVoidedAt: entity.warrantyVoidedAt,
      photoUrls: entity.photoUrls,
      note: entity.note,
      status: entity.status,
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'deviceCode': deviceCode,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'manufacturerId': manufacturerId,
      'manufacturerName': manufacturerName,
      'productFamilyId': productFamilyId,
      'productFamilyName': productFamilyName,
      'modelId': modelId,
      'modelName': modelName,
      'variantId': variantId,
      'variantName': variantName,
      'deviceName': deviceName,
      'serialNumber': serialNumber,
      'imei': imei,
      'purchaseDate':
          purchaseDate == null ? null : Timestamp.fromDate(purchaseDate!),
      'purchaseLocation': purchaseLocation,
      'invoiceNumber': invoiceNumber,
      'warrantyActivatedAt': warrantyActivatedAt == null
          ? null
          : Timestamp.fromDate(warrantyActivatedAt!),
      'warrantyExpiredAt': warrantyExpiredAt == null
          ? null
          : Timestamp.fromDate(warrantyExpiredAt!),
      'warrantyPeriodMonths': warrantyPeriodMonths,
      'warrantyVoidedAt': warrantyVoidedAt == null
          ? null
          : Timestamp.fromDate(warrantyVoidedAt!),
      'photoUrls': photoUrls,
      'note': note,
      'status': status.name,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'deletedAt': deletedAt == null ? null : Timestamp.fromDate(deletedAt!),
    };
  }

  /// Update payload — never touches createdAt/createdBy/status/deletedAt.
  /// Status and deletedAt are only ever changed via archive/restore.
  Map<String, dynamic> toUpdateMap() {
    return {
      'deviceCode': deviceCode,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'manufacturerId': manufacturerId,
      'manufacturerName': manufacturerName,
      'productFamilyId': productFamilyId,
      'productFamilyName': productFamilyName,
      'modelId': modelId,
      'modelName': modelName,
      'variantId': variantId,
      'variantName': variantName,
      'deviceName': deviceName,
      'serialNumber': serialNumber,
      'imei': imei,
      'purchaseDate':
          purchaseDate == null ? null : Timestamp.fromDate(purchaseDate!),
      'purchaseLocation': purchaseLocation,
      'invoiceNumber': invoiceNumber,
      'photoUrls': photoUrls,
      'note': note,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
