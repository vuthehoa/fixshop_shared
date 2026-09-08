import 'entities/user_entity.dart';

/// Single source of truth for deciding what a freshly auto-provisioned
/// Firestore `users/{uid}` profile should look like.
///
/// Firebase Authentication accounts can exist without a matching Firestore
/// profile document (e.g. an account created directly in the Firebase
/// console). When such an account signs in, the auth data source
/// auto-creates the missing `users/{uid}` document. This policy is the
/// ONLY place that decides:
///
///   * which role that auto-created profile receives, and
///   * what display name it gets.
///
/// By default every auto-provisioned account receives the least-privileged
/// role ([defaultRole] = [UserRole.customer]) — which the CMS treats as
/// "no CMS access" — so simply owning a Firebase Auth account never grants
/// staff access. Only the explicitly allow-listed bootstrap administrator
/// ([_adminUids] / [_adminEmails]) is provisioned as [UserRole.admin].
///
/// Never scatter admin/UID checks anywhere else — extend this class.
abstract final class AdminBootstrapPolicy {
  const AdminBootstrapPolicy._();

  /// UIDs that are provisioned as [UserRole.admin] when their Firestore
  /// profile is missing. Keep this list tiny — it is a break-glass measure
  /// for the very first administrator only. Everyone else is promoted from
  /// the Employee management screen by an existing admin/manager.
  static const Set<String> _adminUids = {
    'FLbzn3xHL1RGBza7981rIfmDxwJ3',
  };

  /// Email addresses treated the same way as [_adminUids]. Compared
  /// case-insensitively after trimming.
  static const Set<String> _adminEmails = {
    'admin@fixshop.vn',
  };

  /// Role given to any auto-provisioned profile that is NOT the bootstrap
  /// administrator. [UserRole.customer] is deliberately outside
  /// `UserRole.isCmsUser`, so an auto-provisioned account cannot reach the
  /// CMS until an admin assigns it a real staff role.
  static const UserRole defaultRole = UserRole.customer;

  /// Display name used for the bootstrap administrator profile when
  /// Firebase Auth carries no `displayName`.
  static const String adminDisplayName = 'Administrator';

  /// Fallback display name for a non-admin auto-provisioned profile when no
  /// name can be derived from Firebase Auth.
  static const String fallbackDisplayName = 'Người dùng';

  /// Whether [uid] / [email] identifies the allow-listed bootstrap admin.
  static bool isBootstrapAdmin({required String uid, String? email}) {
    if (_adminUids.contains(uid)) return true;
    final normalized = email?.trim().toLowerCase();
    return normalized != null && _adminEmails.contains(normalized);
  }

  /// Role for a newly auto-provisioned profile.
  static UserRole roleFor({required String uid, String? email}) =>
      isBootstrapAdmin(uid: uid, email: email) ? UserRole.admin : defaultRole;

  /// Display name for a newly auto-provisioned profile.
  ///
  /// Priority: bootstrap-admin constant → Firebase Auth `displayName` →
  /// email local-part → [fallbackDisplayName].
  static String displayNameFor({
    required String uid,
    String? email,
    String? firebaseDisplayName,
  }) {
    if (isBootstrapAdmin(uid: uid, email: email)) return adminDisplayName;

    final fromAuth = firebaseDisplayName?.trim();
    if (fromAuth != null && fromAuth.isNotEmpty) return fromAuth;

    final localPart = email?.trim().split('@').first ?? '';
    if (localPart.isNotEmpty) return localPart;

    return fallbackDisplayName;
  }
}
