import 'package:equatable/equatable.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';

class ManufacturerFilter extends Equatable {
  final String? searchQuery;
  final CatalogStatus? status;
  final int pageSize;

  const ManufacturerFilter({
    this.searchQuery,
    this.status,
    this.pageSize = 20,
  });

  ManufacturerFilter copyWith({
    String? searchQuery,
    CatalogStatus? status,
    int? pageSize,
    bool clearSearch = false,
    bool clearStatus = false,
  }) {
    return ManufacturerFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      status: clearStatus ? null : (status ?? this.status),
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [searchQuery, status, pageSize];
}
