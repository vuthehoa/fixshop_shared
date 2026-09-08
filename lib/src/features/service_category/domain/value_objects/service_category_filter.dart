import 'package:equatable/equatable.dart';

import '../../../catalog_common/domain/enums/catalog_status.dart';

class ServiceCategoryFilter extends Equatable {
  final String? searchQuery;
  final CatalogStatus? status;
  final bool? enabled;
  final int pageSize;

  const ServiceCategoryFilter({
    this.searchQuery,
    this.status,
    this.enabled,
    this.pageSize = 20,
  });

  ServiceCategoryFilter copyWith({
    String? searchQuery,
    CatalogStatus? status,
    bool? enabled,
    int? pageSize,
    bool clearSearch = false,
    bool clearStatus = false,
    bool clearEnabled = false,
  }) {
    return ServiceCategoryFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      status: clearStatus ? null : (status ?? this.status),
      enabled: clearEnabled ? null : (enabled ?? this.enabled),
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [searchQuery, status, enabled, pageSize];
}
