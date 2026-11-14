// Regression for:
//   'package:cloud_firestore/src/query.dart': Failed assertion: '!hasNotIn':
//   You cannot use 'in' filters with 'not-in' filters.
//
// Verifies the ACTUAL Firestore query FirebaseEmployeeRemoteDataSource builds
// for /employees: the role predicate is only ever `isEqualTo` or `whereIn`,
// `whereNotIn` is NEVER used, and the default "hide deleted" rule stays
// client-side — so an `in` and a `not-in` clause can never coexist.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fixshop_shared/fixshop_shared.dart';

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockAuth extends Mock implements FirebaseAuth {}

class _MockApp extends Mock implements FirebaseApp {}

// ignore: subtype_of_sealed_class
class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class _MockQuery extends Mock implements Query<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class _MockSnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

void main() {
  late _MockFirestore firestore;
  late _MockCollection users;
  late _MockQuery query;
  late FirebaseEmployeeRemoteDataSource ds;

  setUp(() {
    firestore = _MockFirestore();
    users = _MockCollection();
    query = _MockQuery();
    final snapshot = _MockSnapshot();

    when(() => firestore.collection('users')).thenReturn(users);

    // Any builder call returns a query we can keep chaining on.
    when(
      () => users.where(
        any<Object>(),
        isEqualTo: any(named: 'isEqualTo'),
        whereIn: any(named: 'whereIn'),
        whereNotIn: any(named: 'whereNotIn'),
      ),
    ).thenReturn(query);
    when(
      () => query.where(
        any<Object>(),
        isEqualTo: any(named: 'isEqualTo'),
        whereIn: any(named: 'whereIn'),
        whereNotIn: any(named: 'whereNotIn'),
      ),
    ).thenReturn(query);
    when(() => query.orderBy(any<Object>())).thenReturn(query);
    when(() => query.limit(any())).thenReturn(query);
    when(() => query.get()).thenAnswer((_) async => snapshot);
    when(() => snapshot.docs).thenReturn(const []);

    ds = FirebaseEmployeeRemoteDataSource(
      firestore: firestore,
      primaryAuth: _MockAuth(),
      secondaryApp: _MockApp(),
    );
  });

  void expectNoWhereNotInAnywhere() {
    verifyNever(
      () => users.where(
        any<Object>(),
        isEqualTo: any(named: 'isEqualTo'),
        whereIn: any(named: 'whereIn'),
        whereNotIn: any(named: 'whereNotIn', that: isNotNull),
      ),
    );
    verifyNever(
      () => query.where(
        any<Object>(),
        isEqualTo: any(named: 'isEqualTo'),
        whereIn: any(named: 'whereIn'),
        whereNotIn: any(named: 'whereNotIn', that: isNotNull),
      ),
    );
  }

  test(
      'default filter → role whereIn(employee roles); NO whereNotIn; '
      'NO server-side status filter', () async {
    await ds.getEmployees(const EmployeeFilter());

    verify(
      () => users.where(
        'role',
        whereIn: EmployeeQueryPlan.employeeRoleNames,
        isEqualTo: any(named: 'isEqualTo'),
        whereNotIn: any(named: 'whereNotIn'),
      ),
    ).called(1);
    expectNoWhereNotInAnywhere();
    verifyNever(
      () => query.where(
        'status',
        isEqualTo: any(named: 'isEqualTo'),
        whereIn: any(named: 'whereIn'),
        whereNotIn: any(named: 'whereNotIn'),
      ),
    );
  });

  test('explicit role → role isEqualTo; no whereIn; no whereNotIn', () async {
    await ds.getEmployees(const EmployeeFilter(role: UserRole.manager));

    verify(
      () => users.where(
        'role',
        isEqualTo: 'manager',
        whereIn: any(named: 'whereIn'),
        whereNotIn: any(named: 'whereNotIn'),
      ),
    ).called(1);
    verifyNever(
      () => users.where(
        'role',
        isEqualTo: any(named: 'isEqualTo'),
        whereIn: any(named: 'whereIn', that: isNotNull),
        whereNotIn: any(named: 'whereNotIn'),
      ),
    );
    expectNoWhereNotInAnywhere();
  });

  test('explicit status → role whereIn + status isEqualTo; still no whereNotIn',
      () async {
    await ds.getEmployees(const EmployeeFilter(status: UserStatus.active));

    verify(
      () => users.where(
        'role',
        whereIn: EmployeeQueryPlan.employeeRoleNames,
        isEqualTo: any(named: 'isEqualTo'),
        whereNotIn: any(named: 'whereNotIn'),
      ),
    ).called(1);
    verify(
      () => query.where(
        'status',
        isEqualTo: 'active',
        whereIn: any(named: 'whereIn'),
        whereNotIn: any(named: 'whereNotIn'),
      ),
    ).called(1);
    expectNoWhereNotInAnywhere();
  });

  test('pagination preserved: orderBy(displayName).limit(pageSize)', () async {
    await ds.getEmployees(const EmployeeFilter(pageSize: 20));
    verify(() => query.orderBy('displayName')).called(1);
    verify(() => query.limit(20)).called(1);
  });
}
