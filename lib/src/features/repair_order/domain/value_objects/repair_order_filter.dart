import 'package:equatable/equatable.dart';

import '../../../device/domain/entities/device_entity.dart';
import '../entities/repair_order_entity.dart';

class RepairOrderFilter extends Equatable {
  final String? searchQuery;
  final RepairOrderStatus? status;
  final String? technicianId;
  final String? manufacturerId;
  final String? customerId;
  final DateTime? createdFrom;
  final DateTime? createdTo;

  /// Client-only concept — the referenced Device's warranty status is never
  /// duplicated onto the repair order, so this can't be a server-side query
  /// field. See `RepairOrderListCubit` for how it's applied after fetch.
  final WarrantyStatus? warrantyStatus;

  final int pageSize;

  const RepairOrderFilter({
    this.searchQuery,
    this.status,
    this.technicianId,
    this.manufacturerId,
    this.customerId,
    this.createdFrom,
    this.createdTo,
    this.warrantyStatus,
    this.pageSize = 20,
  });

  RepairOrderFilter copyWith({
    String? searchQuery,
    RepairOrderStatus? status,
    String? technicianId,
    String? manufacturerId,
    String? customerId,
    DateTime? createdFrom,
    DateTime? createdTo,
    WarrantyStatus? warrantyStatus,
    int? pageSize,
    bool clearSearch = false,
    bool clearStatus = false,
    bool clearTechnician = false,
    bool clearManufacturer = false,
    bool clearCustomer = false,
    bool clearCreatedRange = false,
    bool clearWarrantyStatus = false,
  }) {
    return RepairOrderFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      status: clearStatus ? null : (status ?? this.status),
      technicianId:
          clearTechnician ? null : (technicianId ?? this.technicianId),
      manufacturerId:
          clearManufacturer ? null : (manufacturerId ?? this.manufacturerId),
      customerId: clearCustomer ? null : (customerId ?? this.customerId),
      createdFrom: clearCreatedRange ? null : (createdFrom ?? this.createdFrom),
      createdTo: clearCreatedRange ? null : (createdTo ?? this.createdTo),
      warrantyStatus:
          clearWarrantyStatus ? null : (warrantyStatus ?? this.warrantyStatus),
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        searchQuery,
        status,
        technicianId,
        manufacturerId,
        customerId,
        createdFrom,
        createdTo,
        warrantyStatus,
        pageSize,
      ];
}
