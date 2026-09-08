import 'package:equatable/equatable.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';

class CustomerFilter extends Equatable {
  final String? searchQuery;
  final CatalogStatus? status;
  final String? province;
  final DateTime? createdFrom;
  final DateTime? createdTo;
  final int pageSize;

  const CustomerFilter({
    this.searchQuery,
    this.status,
    this.province,
    this.createdFrom,
    this.createdTo,
    this.pageSize = 20,
  });

  CustomerFilter copyWith({
    String? searchQuery,
    CatalogStatus? status,
    String? province,
    DateTime? createdFrom,
    DateTime? createdTo,
    int? pageSize,
    bool clearSearch = false,
    bool clearStatus = false,
    bool clearProvince = false,
    bool clearCreatedRange = false,
  }) {
    return CustomerFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      status: clearStatus ? null : (status ?? this.status),
      province: clearProvince ? null : (province ?? this.province),
      createdFrom: clearCreatedRange ? null : (createdFrom ?? this.createdFrom),
      createdTo: clearCreatedRange ? null : (createdTo ?? this.createdTo),
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props =>
      [searchQuery, status, province, createdFrom, createdTo, pageSize];
}
