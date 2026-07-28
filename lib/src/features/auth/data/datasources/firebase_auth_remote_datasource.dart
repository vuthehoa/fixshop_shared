import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';
import 'auth_remote_datasource.dart';

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRemoteDataSource({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return _fetchUserModel(firebaseUser.uid);
    });
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) throw const AuthException('Sign in returned no user.');
      return _fetchUserModel(user.uid);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign out failed.');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('No authenticated user.');
    return _fetchUserModel(user.uid);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const AuthException('No authenticated user.');
    }
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    }
  }

  @override
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('No authenticated user.');
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('No authenticated user.');
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send verification email.');
    }
  }

  Future<UserModel> _fetchUserModel(String uid) async {
    final doc =
        await _firestore.collection(FirestoreConstants.users).doc(uid).get();
    if (!doc.exists) throw NotFoundException('User document not found: $uid');
    return UserModel.fromFirestore(doc);
  }

  Exception _mapFirebaseAuthException(FirebaseAuthException e) {
    return switch (e.code) {
      'user-disabled' => const UserDisabledException(),
      'requires-recent-login' => const RequiresRecentLoginException(),
      'email-not-verified' => const EmailNotVerifiedException(),
      'wrong-password' ||
      'invalid-credential' ||
      'user-not-found' =>
        const AuthException('Invalid email or password.'),
      'too-many-requests' =>
        const AuthException('Too many attempts. Please try again later.'),
      'network-request-failed' =>
        const NetworkException('Network error. Please check your connection.'),
      _ => AuthException(e.message ?? 'Authentication error.'),
    };
  }
}
