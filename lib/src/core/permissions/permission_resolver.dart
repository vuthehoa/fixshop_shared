import '../../features/auth/domain/entities/user_entity.dart';
import 'permission.dart';
import 'role_permission.dart';

abstract final class PermissionResolver {
  static bool hasPermission(UserRole role, Permission permission) {
    return RolePermissions.of(role).contains(permission);
  }

  static bool hasAnyPermission(UserRole role, Iterable<Permission> permissions) {
    final granted = RolePermissions.of(role);
    return permissions.any(granted.contains);
  }

  static bool hasAllPermissions(UserRole role, Iterable<Permission> permissions) {
    final granted = RolePermissions.of(role);
    return permissions.every(granted.contains);
  }
}
