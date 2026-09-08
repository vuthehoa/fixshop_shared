import 'package:equatable/equatable.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';

class RepairServiceFilter extends Equatable {
  final String? searchQuery;
  final CatalogStatus? status;
  final String? parentId;
  final String? categoryId;
  final int pageSize;

  const RepairServiceFilter({
    this.searchQuery,
    this.status,
    this.parentId,
    this.categoryId,
    this.pageSize = 20,
  });

  RepairServiceFilter copyWith({
    String? searchQuery,
    CatalogStatus? status,
    String? parentId,
    String? categoryId,
    int? pageSize,
    bool clearSearch = false,
    bool clearStatus = false,
    bool clearParent = false,
    bool clearCategory = false,
  }) {
    return RepairServiceFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      status: clearStatus ? null : (status ?? this.status),
      parentId: clearParent ? null : (parentId ?? this.parentId),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props =>
      [searchQuery, status, parentId, categoryId, pageSize];
}
