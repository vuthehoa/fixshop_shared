import 'package:equatable/equatable.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';

class ProductFamilyFilter extends Equatable {
  final String? searchQuery;
  final CatalogStatus? status;
  final String? parentId;
  final int pageSize;

  const ProductFamilyFilter({
    this.searchQuery,
    this.status,
    this.parentId,
    this.pageSize = 20,
  });

  ProductFamilyFilter copyWith({
    String? searchQuery,
    CatalogStatus? status,
    String? parentId,
    int? pageSize,
    bool clearSearch = false,
    bool clearStatus = false,
    bool clearParent = false,
  }) {
    return ProductFamilyFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      status: clearStatus ? null : (status ?? this.status),
      parentId: clearParent ? null : (parentId ?? this.parentId),
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [searchQuery, status, parentId, pageSize];
}
