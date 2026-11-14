import 'package:fixshop_shared/fixshop_shared.dart';
import 'package:flutter_test/flutter_test.dart';

UserEntity _u(String id, UserRole role) => UserEntity(
      id: id,
      email: '$id@x.vn',
      displayName: id,
      role: role,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

void main() {
  final admin = _u('a', UserRole.admin);
  final admin2 = _u('a2', UserRole.admin);
  final manager = _u('m', UserRole.manager);
  final manager2 = _u('m2', UserRole.manager);
  final reception = _u('r', UserRole.reception);
  final tech = _u('t', UserRole.technician);

  test('assignable roles mirror firestore.rules users/{id}', () {
    expect(StaffDirectoryPolicy.assignableRoles(UserRole.admin),
        [UserRole.admin, UserRole.manager, UserRole.reception, UserRole.technician]);
    expect(StaffDirectoryPolicy.assignableRoles(UserRole.manager),
        [UserRole.reception, UserRole.technician]);
    expect(StaffDirectoryPolicy.assignableRoles(UserRole.reception), isEmpty);
    expect(StaffDirectoryPolicy.assignableRoles(UserRole.technician), isEmpty);
    expect(StaffDirectoryPolicy.canCreate(UserRole.reception), isFalse);
  });

  test('nobody manages their own role/status', () {
    for (final u in [admin, manager, reception, tech]) {
      expect(StaffDirectoryPolicy.canManage(u, u), isFalse, reason: u.role.name);
      expect(StaffDirectoryPolicy.canEditProfile(u, u), isTrue, reason: u.role.name);
      expect(StaffDirectoryPolicy.canChangeRole(u, u), isFalse, reason: u.role.name);
    }
  });

  test('admin manages every other staff account', () {
    for (final t in [admin2, manager, reception, tech]) {
      expect(StaffDirectoryPolicy.canManage(admin, t), isTrue, reason: t.role.name);
    }
  });

  test('manager manages only reception/technician', () {
    expect(StaffDirectoryPolicy.canManage(manager, reception), isTrue);
    expect(StaffDirectoryPolicy.canManage(manager, tech), isTrue);
    expect(StaffDirectoryPolicy.canManage(manager, manager2), isFalse);
    expect(StaffDirectoryPolicy.canManage(manager, admin), isFalse);
  });

  test('reception/technician manage nobody', () {
    expect(StaffDirectoryPolicy.canManage(reception, tech), isFalse);
    expect(StaffDirectoryPolicy.canManage(tech, reception), isFalse);
  });

  test('reception can register walk-in customers and devices', () {
    expect(PermissionResolver.hasPermission(UserRole.reception, Permission.manageCustomer), isTrue);
    expect(PermissionResolver.hasPermission(UserRole.reception, Permission.manageDevice), isTrue);
    expect(PermissionResolver.hasPermission(UserRole.technician, Permission.manageCustomer), isFalse);
    expect(PermissionResolver.hasPermission(UserRole.technician, Permission.manageDevice), isFalse);
  });
}
