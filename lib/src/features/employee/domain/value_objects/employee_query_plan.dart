import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user_entity.dart';
import 'employee_filter.dart';

/// Pure description of how an [EmployeeFilter] is turned into a single
/// Firestore-safe query plus any residual filtering that must run in Dart.
///
/// Firestore forbids combining an `in` filter with a `not-in` filter in the
/// same query (`'!hasNotIn': You cannot use 'in' filters with 'not-in'
/// filters.`). To stay well within that limit this plan follows two rules:
///
///  * The **role** predicate is always expressed server-side, and never as a
///    `not-in` clause — it is either an equality (`role == x`) or a whitelist
///    `whereIn` over the known employee roles.
///  * The default **status** predicate ("hide soft-deleted accounts") is
///    applied client-side via [clientExcludedStatuses]. Only an *explicit*
///    status choice is pushed to the server, and then only as an equality.
///
/// The result: no query ever contains more than one disjunctive (`in`) clause,
/// and `in` + `not-in` can never coexist.
class EmployeeQueryPlan extends Equatable {
  /// Server-side: `where('role', isEqualTo: roleIsEqualTo)`.
  final String? roleIsEqualTo;

  /// Server-side: `where('role', whereIn: roleWhereIn)`. Never empty when set.
  final List<String>? roleWhereIn;

  /// Server-side: `where('status', isEqualTo: statusIsEqualTo)`.
  final String? statusIsEqualTo;

  /// Client-side: drop any document whose `status` is contained here.
  /// Empty when no client-side exclusion is required.
  final Set<String> clientExcludedStatuses;

  const EmployeeQueryPlan({
    this.roleIsEqualTo,
    this.roleWhereIn,
    this.statusIsEqualTo,
    this.clientExcludedStatuses = const {},
  });

  /// Roles that represent staff accounts — everything except a pure customer.
  static final List<String> employeeRoleNames = UserRole.values
      .where((r) => r != UserRole.customer)
      .map((r) => r.name)
      .toList(growable: false);

  /// Statuses that are hidden by default (soft-deleted records).
  static const Set<String> defaultExcludedStatusNames = {'deleted'};

  factory EmployeeQueryPlan.fromFilter(EmployeeFilter filter) {
    // ---- Role: always server-side, always positive (equality or whitelist).
    final String? roleEq = filter.role?.name;
    final List<String>? roleIn = roleEq == null ? employeeRoleNames : null;

    // ---- Status.
    if (filter.status != null) {
      // Explicit status -> pure equality, safe next to any role clause.
      return EmployeeQueryPlan(
        roleIsEqualTo: roleEq,
        roleWhereIn: roleIn,
        statusIsEqualTo: filter.status!.name,
      );
    }

    // Default status rule = "not deleted", handled client-side so it never
    // becomes a `not-in` clause competing with the role `whereIn`.
    return EmployeeQueryPlan(
      roleIsEqualTo: roleEq,
      roleWhereIn: roleIn,
      clientExcludedStatuses: defaultExcludedStatusNames,
    );
  }

  bool get usesRoleWhereIn => roleWhereIn != null && roleWhereIn!.isNotEmpty;

  bool get requiresClientSideExclusion => clientExcludedStatuses.isNotEmpty;

  /// Human-readable one-liner for DEBUG logging. Contains no sensitive data.
  String describe(int limit) {
    final server = <String>[
      if (roleIsEqualTo != null) 'role==$roleIsEqualTo',
      if (usesRoleWhereIn) 'role whereIn $roleWhereIn',
      if (statusIsEqualTo != null) 'status==$statusIsEqualTo',
    ];
    final client = <String>[
      if (requiresClientSideExclusion)
        'status notIn ${clientExcludedStatuses.toList()}',
    ];
    return 'EmployeeQueryStrategy: serverFilters=$server '
        'clientFilters=$client limit=$limit';
  }

  @override
  List<Object?> get props => [
        roleIsEqualTo,
        roleWhereIn,
        statusIsEqualTo,
        clientExcludedStatuses,
      ];
}
