import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/paginated_result.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/value_objects/employee_filter.dart';
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
    Query<Map<String, dynamic>> query = _users;

    // Role filter — exclude customer accounts from employee list by default
    if (filter.role != null) {
      query = query.where('role', isEqualTo: filter.role!.name);
    } else {
      query = query.where('role', whereNotIn: [UserRole.customer.name]);
    }

    // Status filter — default: show active + disabled (exclude deleted)
    if (filter.status != null) {
      query = query.where('status', isEqualTo: filter.status!.name);
    } else {
      query = query.where(
        'status',
        whereIn: [UserStatus.active.name, UserStatus.disabled.name],
      );
    }

    query = query.orderBy('displayName').limit(filter.pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final models = snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();

    // Client-side text search (Firestore has no native full-text search)
    final filtered =
        filter.searchQuery == null || filter.searchQuery!.trim().isEmpty
            ? models
            : models.where((m) {
                final q = filter.searchQuery!.toLowerCase();
                return m.displayName.toLowerCase().contains(q) ||
                    m.email.toLowerCase().contains(q) ||
                    (m.phoneNumber?.toLowerCase().contains(q) ?? false);
              }).toList();

    return PaginatedResult(
      items: filtered,
      lastDocument:
          snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == filter.pageSize,
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
      throw AuthException(e.message ?? 'Failed to create Firebase Auth account.');
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
    if (!doc.exists) throw NotFoundException('Employee not found after update.');
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
