import 'package:equatable/equatable.dart';

import '../entities/device_entity.dart';

class DeviceFilter extends Equatable {
  final String? searchQuery;
  final DeviceStatus? status;
  final String? manufacturerId;
  final String? productFamilyId;
  final String? modelId;
  final String? customerId;
  final DateTime? createdFrom;
  final DateTime? createdTo;
  final WarrantyStatus? warrantyStatus;
  final DateTime? warrantyExpiringFrom;
  final DateTime? warrantyExpiringTo;
  final int pageSize;

  const DeviceFilter({
    this.searchQuery,
    this.status,
    this.manufacturerId,
    this.productFamilyId,
    this.modelId,
    this.customerId,
    this.createdFrom,
    this.createdTo,
    this.warrantyStatus,
    this.warrantyExpiringFrom,
    this.warrantyExpiringTo,
    this.pageSize = 20,
  });

  DeviceFilter copyWith({
    String? searchQuery,
    DeviceStatus? status,
    String? manufacturerId,
    String? productFamilyId,
    String? modelId,
    String? customerId,
    DateTime? createdFrom,
    DateTime? createdTo,
    WarrantyStatus? warrantyStatus,
    DateTime? warrantyExpiringFrom,
    DateTime? warrantyExpiringTo,
    int? pageSize,
    bool clearSearch = false,
    bool clearStatus = false,
    bool clearManufacturer = false,
    bool clearProductFamily = false,
    bool clearModel = false,
    bool clearCustomer = false,
    bool clearCreatedRange = false,
    bool clearWarrantyStatus = false,
    bool clearWarrantyExpiringRange = false,
  }) {
    return DeviceFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      status: clearStatus ? null : (status ?? this.status),
      manufacturerId:
          clearManufacturer ? null : (manufacturerId ?? this.manufacturerId),
      productFamilyId:
          clearProductFamily ? null : (productFamilyId ?? this.productFamilyId),
      modelId: clearModel ? null : (modelId ?? this.modelId),
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
      createdFrom: clearCreatedRange ? null : (createdFrom ?? this.createdFrom),
      createdTo: clearCreatedRange ? null : (createdTo ?? this.createdTo),
      warrantyStatus:
          clearWarrantyStatus ? null : (warrantyStatus ?? this.warrantyStatus),
      warrantyExpiringFrom: clearWarrantyExpiringRange
          ? null
          : (warrantyExpiringFrom ?? this.warrantyExpiringFrom),
      warrantyExpiringTo: clearWarrantyExpiringRange
          ? null
          : (warrantyExpiringTo ?? this.warrantyExpiringTo),
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        status,
        manufacturerId,
        productFamilyId,
        modelId,
        customerId,
        createdFrom,
        createdTo,
        warrantyStatus,
        warrantyExpiringFrom,
        warrantyExpiringTo,
        pageSize,
      ];
}
