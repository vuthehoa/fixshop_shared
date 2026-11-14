import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/value_objects/employee_filter.dart';
import '../../domain/value_objects/employee_page_assembler.dart';
import '../../domain/value_objects/employee_query_plan.dart';
import 'employee_remote_datasource.dart';

class FirebaseEmployeeRemoteDataSource implements EmployeeRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _primaryAuth;
  final FirebaseApp _secondaryApp;

  FirebaseEmployeeRemoteDataSource({
    required FirebaseFirestore firestore,
    required FirebaseAuth primaryAuth,
    required FirebaseApp secondaryApp,
  })  : _firestore = firestore,
        _primaryAuth = primaryAuth,
        _secondaryApp = secondaryApp;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(FirestoreConstants.users);

  @override
  Future<UserModel> getEmployee(String id) async {
    final doc = await _users.doc(id).get();
    if (!doc.exists) throw NotFoundException('Employee not found: $id');
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<PaginatedResult<UserModel>> getEmployees(
    EmployeeFilter filter, {
    DocumentSnapshot? startAfter,
  }) async {
    // A single Firestore-safe query per [EmployeeQueryPlan]: the role
    // predicate is always POSITIVE (equality or a `whereIn` whitelist of the
    // employee roles) and only an *explicit* status choice is pushed to the
    // server, as equality. The default "hide deleted" rule runs client-side.
    // This guarantees an `in` filter and a `not-in` filter can never coexist
    // in the same query (the assertion `'!hasNotIn': You cannot use 'in'
    // filters with 'not-in' filters`).
    final plan = EmployeeQueryPlan.fromFilter(filter);

    if (kDebugMode) {
      debugPrint('[EmployeeQuery] ${plan.describe(filter.pageSize)}');
    }

    Query<Map<String, dynamic>> query = _users;

    if (plan.roleIsEqualTo != null) {
      query = query.where('role', isEqualTo: plan.roleIsEqualTo);
    } else if (plan.usesRoleWhereIn) {
      query = query.where('role', whereIn: plan.roleWhereIn);
    }

    if (plan.statusIsEqualTo != null) {
      query = query.where('status', isEqualTo: plan.statusIsEqualTo);
    }

    query = query.orderBy('displayName').limit(filter.pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    var models =
        snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();

    // Client-side: drop default-hidden statuses (e.g. `deleted`). Never a
    // server `not-in` clause.
    if (plan.requiresClientSideExclusion) {
      models = models
          .where((m) => !plan.clientExcludedStatuses.contains(m.status.name))
          .toList();
    }

    // Client-side text search (Firestore has no native full-text search).
    final rawQuery = filter.searchQuery?.trim().toLowerCase();
    final filtered = rawQuery == null || rawQuery.isEmpty
        ? models
        : models.where((m) {
            return m.displayName.toLowerCase().contains(rawQuery) ||
                m.email.toLowerCase().contains(rawQuery) ||
                (m.phoneNumber?.toLowerCase().contains(rawQuery) ?? false);
          }).toList();

    final page = assembleEmployeePage(
      accepted: filtered,
      pageSize: filter.pageSize,
      firestoreExhausted: snapshot.docs.length < filter.pageSize,
    );

    return PaginatedResult(
      items: page.items,
      // Cursor advances past the last FETCHED doc (even one dropped
      // client-side), so the next page never re-reads it.
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: page.hasMore,
    );
  }

  @override
  Future<UserModel> createEmployee({
    required String email,
    required String password,
    required UserModel employee,
  }) async {
    final secondaryAuth = FirebaseAuth.instanceFor(app: _secondaryApp);
    String? uid;

    try {
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      uid = credential.user?.uid;
      if (uid == null) {
        throw const ServerException('Firebase Auth returned no user UID.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw DuplicateEmailException(
          'An account with email "$email" already exists.',
        );
      }
      throw AuthException(
          e.message ?? 'Failed to create Firebase Auth account.');
    } finally {
      await secondaryAuth.signOut();
    }

    final now = DateTime.now();
    final newEmployee = UserModel(
      id: uid,
      email: email.trim(),
      displayName: employee.displayName,
      photoUrl: employee.photoUrl,
      phoneNumber: employee.phoneNumber,
      role: employee.role,
      status: UserStatus.active,
      createdAt: now,
      updatedAt: now,
      address: employee.address,
      gender: employee.gender,
      createdBy: employee.createdBy,
    );

    try {
      await _users.doc(uid).set(newEmployee.toFirestore());
    } catch (e) {
      // Rollback: delete the Firebase Auth account if Firestore write fails
      await _attemptAuthRollback(email, password);
      throw const ServerException(
        'Failed to save employee record. Firebase Auth account was rolled back.',
      );
    }

    return newEmployee;
  }

  Future<void> _attemptAuthRollback(String email, String password) async {
    final rollbackAuth = FirebaseAuth.instanceFor(app: _secondaryApp);
    try {
      await rollbackAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await rollbackAuth.currentUser?.delete();
    } catch (_) {
      // Best-effort rollback — log elsewhere
    } finally {
      await rollbackAuth.signOut();
    }
  }

  @override
  Future<UserModel> updateEmployee(UserModel employee) async {
    await _users.doc(employee.id).update(employee.toUpdateMap());
    final doc = await _users.doc(employee.id).get();
    if (!doc.exists) {
      throw NotFoundException('Employee not found after update.');
    }
    return UserModel.fromFirestore(doc);
  }

  @override
  Future<void> deleteEmployee(String id) async {
    await _users.doc(id).update({
      'status': UserStatus.deleted.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateEmployeeStatus(String id, UserStatus status) async {
    await _users.doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> resetEmployeePassword(String email) async {
    try {
      await _primaryAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        e.message ?? 'Failed to send password reset email.',
      );
    }
  }
}
