import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';

class EmployeeFilter extends Equatable {
  final String? searchQuery;
  final UserRole? role;
  final UserStatus? status;
  final int pageSize;

  const EmployeeFilter({
    this.searchQuery,
    this.role,
    this.status,
    this.pageSize = 20,
  });

  /// True when the user picked a specific role (query uses `role ==`).
  bool get hasRoleFilter => role != null;

  /// True when the user picked a specific status (query uses `status ==`).
  bool get hasStatusFilter => status != null;

  /// True when there is a non-blank free-text query (applied in Dart).
  bool get hasTextSearch => (searchQuery?.trim().isNotEmpty) ?? false;

  /// True when the default "hide deleted accounts" rule must run client-side
  /// — i.e. no explicit status was chosen, so it can't be pushed to the
  /// server as an equality without risking an `in` + `not-in` combination.
  bool get requiresClientSideExclusion => status == null;

  EmployeeFilter copyWith({
    String? searchQuery,
    UserRole? role,
    UserStatus? status,
    int? pageSize,
    bool clearSearch = false,
    bool clearRole = false,
    bool clearStatus = false,
  }) {
    return EmployeeFilter(
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      role: clearRole ? null : (role ?? this.role),
      status: clearStatus ? null : (status ?? this.status),
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [searchQuery, role, status, pageSize];
}
