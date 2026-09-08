import 'package:equatable/equatable.dart';

import '../../../../core/qr/qr_payload_builder.dart';

/// Lifecycle status of a warranty embedded on a [DeviceEntity]. Never
/// persisted directly — always derived from
/// [DeviceEntity.warrantyActivatedAt]/[DeviceEntity.warrantyExpiredAt]/
/// [DeviceEntity.warrantyVoidedAt] plus the current time, so it can never
/// drift out of sync with the fields it's computed from.
enum WarrantyStatus {
  notActivated,
  active,
  expired,
  voided;

  String get displayName => switch (this) {
        WarrantyStatus.notActivated => 'Chưa kích hoạt',
        WarrantyStatus.active => 'Còn bảo hành',
        WarrantyStatus.expired => 'Hết hạn bảo hành',
        WarrantyStatus.voided => 'Đã huỷ bảo hành',
      };
}

/// Lifecycle status of a device. Distinct from [CatalogStatus] because a
/// device's operational lifecycle is richer than simple active/archived —
/// but `archived` still plays the same soft-delete role every other module
/// uses: never removed from Firestore, only hidden from the active list.
enum DeviceStatus {
  registered,
  active,
  underWarranty,
  repairing,
  inactive,
  archived;

  String get displayName => switch (this) {
        DeviceStatus.registered => 'Đã đăng ký',
        DeviceStatus.active => 'Đang hoạt động',
        DeviceStatus.underWarranty => 'Đang bảo hành',
        DeviceStatus.repairing => 'Đang sửa chữa',
        DeviceStatus.inactive => 'Ngừng sử dụng',
        DeviceStatus.archived => 'Đã lưu trữ',
      };

  static DeviceStatus fromName(String? value) => switch (value) {
        'registered' => DeviceStatus.registered,
        'active' => DeviceStatus.active,
        'underWarranty' => DeviceStatus.underWarranty,
        'repairing' => DeviceStatus.repairing,
        'inactive' => DeviceStatus.inactive,
        'archived' => DeviceStatus.archived,
        _ => DeviceStatus.registered,
      };
}

/// The core business entity of the FixShop ecosystem — every future
/// Warranty, Repair Order, Repair History and QR Code feature is anchored to
/// a Device.
///
/// [customerName], [customerPhone], [manufacturerName], [productFamilyName],
/// [modelName] and [variantName] are denormalized display fields, copied
/// from the referenced records at create/update time. They exist purely so
/// the list page can render and text-search across relations (customer name,
/// phone, model, manufacturer) without an N+1 join per row — the referenced
/// ids remain the source of truth and are re-copied on every update.
class DeviceEntity extends Equatable {
  final String id;
  final String deviceCode;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String manufacturerId;
  final String manufacturerName;
  final String productFamilyId;
  final String productFamilyName;
  final String modelId;
  final String modelName;
  final String? variantId;
  final String? variantName;
  final String deviceName;
  final String serialNumber;
  final String? imei;
  final DateTime? purchaseDate;
  final String? purchaseLocation;
  final String? invoiceNumber;
  final DateTime? warrantyActivatedAt;
  final DateTime? warrantyExpiredAt;
  final int? warrantyPeriodMonths;
  final DateTime? warrantyVoidedAt;
  final List<String> photoUrls;
  final String? note;
  final DeviceStatus status;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const DeviceEntity({
    required this.id,
    required this.deviceCode,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.manufacturerId,
    required this.manufacturerName,
    required this.productFamilyId,
    required this.productFamilyName,
    required this.modelId,
    required this.modelName,
    this.variantId,
    this.variantName,
    required this.deviceName,
    required this.serialNumber,
    this.imei,
    this.purchaseDate,
    this.purchaseLocation,
    this.invoiceNumber,
    this.warrantyActivatedAt,
    this.warrantyExpiredAt,
    this.warrantyPeriodMonths,
    this.warrantyVoidedAt,
    this.photoUrls = const [],
    this.note,
    this.status = DeviceStatus.registered,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool get isArchived => status == DeviceStatus.archived;
  bool get isActive => status != DeviceStatus.archived;

  /// QR payload is a pure function of [deviceCode] — no persistence, no
  /// scanning, just the architecture this and prior sprints prepare.
  String get qrPayload => QrPayloadBuilder.forDevice(deviceCode);

  /// Derived, never stored — see [WarrantyStatus] doc.
  WarrantyStatus get warrantyStatus {
    if (warrantyVoidedAt != null) return WarrantyStatus.voided;
    if (warrantyActivatedAt == null) return WarrantyStatus.notActivated;
    if (warrantyExpiredAt != null &&
        DateTime.now().isAfter(warrantyExpiredAt!)) {
      return WarrantyStatus.expired;
    }
    return WarrantyStatus.active;
  }

  /// `null` when there's no expiration to count down to. Negative once past
  /// expiration — callers should clamp for display (e.g. "Hết hạn").
  int? get warrantyRemainingDays =>
      warrantyExpiredAt?.difference(DateTime.now()).inDays;

  DeviceEntity copyWith({
    String? id,
    String? deviceCode,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? manufacturerId,
    String? manufacturerName,
    String? productFamilyId,
    String? productFamilyName,
    String? modelId,
    String? modelName,
    String? variantId,
    String? variantName,
    String? deviceName,
    String? serialNumber,
    String? imei,
    DateTime? purchaseDate,
    String? purchaseLocation,
    String? invoiceNumber,
    DateTime? warrantyActivatedAt,
    DateTime? warrantyExpiredAt,
    int? warrantyPeriodMonths,
    DateTime? warrantyVoidedAt,
    List<String>? photoUrls,
    String? note,
    DeviceStatus? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return DeviceEntity(
      id: id ?? this.id,
      deviceCode: deviceCode ?? this.deviceCode,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      manufacturerId: manufacturerId ?? this.manufacturerId,
      manufacturerName: manufacturerName ?? this.manufacturerName,
      productFamilyId: productFamilyId ?? this.productFamilyId,
      productFamilyName: productFamilyName ?? this.productFamilyName,
      modelId: modelId ?? this.modelId,
      modelName: modelName ?? this.modelName,
      variantId: variantId ?? this.variantId,
      variantName: variantName ?? this.variantName,
      deviceName: deviceName ?? this.deviceName,
      serialNumber: serialNumber ?? this.serialNumber,
      imei: imei ?? this.imei,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseLocation: purchaseLocation ?? this.purchaseLocation,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      warrantyActivatedAt: warrantyActivatedAt ?? this.warrantyActivatedAt,
      warrantyExpiredAt: warrantyExpiredAt ?? this.warrantyExpiredAt,
      warrantyPeriodMonths: warrantyPeriodMonths ?? this.warrantyPeriodMonths,
      warrantyVoidedAt: warrantyVoidedAt ?? this.warrantyVoidedAt,
      photoUrls: photoUrls ?? this.photoUrls,
      note: note ?? this.note,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        deviceCode,
        customerId,
        customerName,
        customerPhone,
        manufacturerId,
        manufacturerName,
        productFamilyId,
        productFamilyName,
        modelId,
        modelName,
        variantId,
        variantName,
        deviceName,
        serialNumber,
        imei,
        purchaseDate,
        purchaseLocation,
        invoiceNumber,
        warrantyActivatedAt,
        warrantyExpiredAt,
        warrantyPeriodMonths,
        warrantyVoidedAt,
        photoUrls,
        note,
        status,
        createdBy,
        createdAt,
        updatedAt,
        deletedAt,
      ];
}
