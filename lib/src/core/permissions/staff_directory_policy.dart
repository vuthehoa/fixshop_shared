import '../../features/auth/domain/entities/user_entity.dart';

/// Who may create / edit / disable which staff account. Mirror of the
/// `users/{userId}` rules in fixshop_cms firestore.rules (2026-11-14):
///
/// * admin   → any staff account and any staff role, except their OWN
///             role/status (no accidental lock-out of the last admin).
/// * manager → only reception / technician accounts, and may only assign
///             reception / technician; never themselves, never admin/manager.
/// * others  → no directory writes (own profile fields only).
///
/// The CMS uses this to hide actions and narrow the role dropdown; the rules
/// enforce the same matrix server-side.
abstract final class StaffDirectoryPolicy {
  static const _frontLine = {UserRole.reception, UserRole.technician};

  /// Roles [actor] may give to an account (create or role change).
  static List<UserRole> assignableRoles(UserRole actor) => switch (actor) {
        UserRole.admin => const [
            UserRole.admin,
            UserRole.manager,
            UserRole.reception,
            UserRole.technician,
          ],
        UserRole.manager => const [UserRole.reception, UserRole.technician],
        _ => const [],
      };

  static bool canCreate(UserRole actor) => assignableRoles(actor).isNotEmpty;

  /// Whether [actor] may edit role/status (disable, activate, delete, change
  /// role) of [target].
  static bool canManage(UserEntity actor, UserEntity target) {
    if (actor.id == target.id) return false;
    return switch (actor.role) {
      UserRole.admin => target.role != UserRole.customer,
      UserRole.manager => _frontLine.contains(target.role),
      _ => false,
    };
  }

  /// Whether [actor] may open the edit form for [target]. Everyone may edit
  /// their own profile fields (name, phone…), but not their own role.
  static bool canEditProfile(UserEntity actor, UserEntity target) =>
      actor.id == target.id ? actor.role.isCmsUser : canManage(actor, target);

  /// Whether the role field is editable for [target] by [actor].
  static bool canChangeRole(UserEntity actor, UserEntity target) =>
      canManage(actor, target);
}
