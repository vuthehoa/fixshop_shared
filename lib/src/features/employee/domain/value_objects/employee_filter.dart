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
