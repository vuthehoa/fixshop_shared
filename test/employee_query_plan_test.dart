import 'package:flutter_test/flutter_test.dart';

import 'package:fixshop_shared/fixshop_shared.dart';

void main() {
  group('EmployeeQueryPlan.fromFilter', () {
    test('1. no filter — role whitelist server-side, deleted excluded in Dart',
        () {
      final plan = EmployeeQueryPlan.fromFilter(const EmployeeFilter());

      expect(plan.roleIsEqualTo, isNull);
      expect(plan.roleWhereIn, EmployeeQueryPlan.employeeRoleNames);
      expect(plan.roleWhereIn, isNot(contains('customer')));
      expect(plan.statusIsEqualTo, isNull);
      expect(plan.clientExcludedStatuses, {'deleted'});
      expect(plan.requiresClientSideExclusion, isTrue);
    });

    test('2. explicit status only — whereIn(role) + equality(status), no notIn',
        () {
      final plan = EmployeeQueryPlan.fromFilter(
        const EmployeeFilter(status: UserStatus.active),
      );

      expect(plan.roleWhereIn, EmployeeQueryPlan.employeeRoleNames);
      expect(plan.statusIsEqualTo, 'active');
      expect(plan.clientExcludedStatuses, isEmpty);
      expect(plan.requiresClientSideExclusion, isFalse);
    });

    test(
        '3. explicit role only — equality(role) + client-side deleted exclusion',
        () {
      final plan = EmployeeQueryPlan.fromFilter(
        const EmployeeFilter(role: UserRole.technician),
      );

      expect(plan.roleIsEqualTo, 'technician');
      expect(plan.roleWhereIn, isNull);
      expect(plan.usesRoleWhereIn, isFalse);
      expect(plan.statusIsEqualTo, isNull);
      expect(plan.clientExcludedStatuses, {'deleted'});
    });

    test('4. role + status both set — two equalities, nothing client-side', () {
      final plan = EmployeeQueryPlan.fromFilter(
        const EmployeeFilter(
          role: UserRole.manager,
          status: UserStatus.disabled,
        ),
      );

      expect(plan.roleIsEqualTo, 'manager');
      expect(plan.roleWhereIn, isNull);
      expect(plan.statusIsEqualTo, 'disabled');
      expect(plan.clientExcludedStatuses, isEmpty);
    });

    test('5. null role/status behaves like an unset filter', () {
      final plan = EmployeeQueryPlan.fromFilter(
        const EmployeeFilter(role: null, status: null, pageSize: 20),
      );

      expect(plan, EmployeeQueryPlan.fromFilter(const EmployeeFilter()));
    });

    test('6. role whitelist is never empty', () {
      expect(EmployeeQueryPlan.employeeRoleNames, isNotEmpty);
      expect(
        EmployeeQueryPlan.employeeRoleNames,
        containsAll(<String>['admin', 'manager', 'reception', 'technician']),
      );
    });

    test('7. describe() reports the strategy and page size for logging', () {
      final plan = EmployeeQueryPlan.fromFilter(
        const EmployeeFilter(pageSize: 20),
      );
      final line = plan.describe(20);

      expect(line, contains('limit=20'));
      expect(line, contains('role whereIn'));
      expect(line, contains('status notIn [deleted]'));
    });

    test('10. no filter combination ever needs a server-side `not-in`', () {
      final filters = <EmployeeFilter>[
        const EmployeeFilter(),
        const EmployeeFilter(searchQuery: 'anne'),
        const EmployeeFilter(
          role: UserRole.reception,
          status: UserStatus.disabled,
        ),
        for (final r in UserRole.values) EmployeeFilter(role: r),
        for (final s in UserStatus.values) EmployeeFilter(status: s),
      ];

      for (final f in filters) {
        final plan = EmployeeQueryPlan.fromFilter(f);

        // Role is always positive: equality OR whitelist, never both, never
        // negated. Status exclusion is always resolved in Dart. Therefore a
        // server query built from this plan can hold at most one `in` clause
        // and zero `not-in` clauses -> the Firestore assertion cannot trip.
        final serverInClauses = [
          if (plan.roleIsEqualTo != null) 'role==',
          if (plan.usesRoleWhereIn) 'role in',
          if (plan.statusIsEqualTo != null) 'status==',
        ];
        final disjunctiveClauses =
            serverInClauses.where((c) => c.endsWith(' in')).length;

        expect(disjunctiveClauses, lessThanOrEqualTo(1));
        if (plan.roleWhereIn != null) {
          expect(plan.roleWhereIn, isNotEmpty, reason: 'never whereIn: []');
        }
      }
    });
  });

  group('EmployeeFilter helpers', () {
    test('hasRoleFilter / hasStatusFilter / hasTextSearch', () {
      const f = EmployeeFilter(
        role: UserRole.admin,
        searchQuery: '  ',
      );
      expect(f.hasRoleFilter, isTrue);
      expect(f.hasStatusFilter, isFalse);
      expect(f.hasTextSearch, isFalse); // whitespace only
      expect(const EmployeeFilter(searchQuery: 'x').hasTextSearch, isTrue);
    });

    test('requiresClientSideExclusion only when status is unset', () {
      expect(const EmployeeFilter().requiresClientSideExclusion, isTrue);
      expect(
        const EmployeeFilter(status: UserStatus.active)
            .requiresClientSideExclusion,
        isFalse,
      );
    });
  });

  group('assembleEmployeePage', () {
    List<int> seq(int n) => List<int>.generate(n, (i) => i);

    test('8. fewer than a page after client filtering, Firestore drained', () {
      final page = assembleEmployeePage(
        accepted: seq(8),
        pageSize: 20,
        firestoreExhausted: true,
      );

      expect(page.items.length, 8);
      expect(page.hasMore, isFalse);
    });

    test('8b. fewer than a page but Firestore still has data -> hasMore', () {
      final page = assembleEmployeePage(
        accepted: seq(8),
        pageSize: 20,
        firestoreExhausted: false,
      );

      expect(page.items.length, 8);
      expect(page.hasMore, isTrue);
    });

    test('9. over-fetched more than a page -> trimmed to 20, hasMore', () {
      final page = assembleEmployeePage(
        accepted: seq(27),
        pageSize: 20,
        firestoreExhausted: true,
      );

      expect(page.items.length, 20);
      expect(page.items, seq(20));
      expect(page.hasMore, isTrue);
    });

    test('exactly one page collected and Firestore drained -> no more', () {
      final page = assembleEmployeePage(
        accepted: seq(20),
        pageSize: 20,
        firestoreExhausted: true,
      );

      expect(page.items.length, 20);
      expect(page.hasMore, isFalse);
    });

    test('empty result', () {
      final page = assembleEmployeePage(
        accepted: <int>[],
        pageSize: 20,
        firestoreExhausted: true,
      );

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    });
  });
}
