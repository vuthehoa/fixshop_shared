import '../../features/auth/domain/entities/user_entity.dart';
import 'permission.dart';

abstract final class RolePermissions {
  static const Set<Permission> _adminPermissions = {
    ...Permission.values, // admin has every permission
  };

  static const Set<Permission> _managerPermissions = {
    Permission.createEmployee,
    Permission.readEmployee,
    Permission.updateEmployee,
    Permission.disableEmployee,
    Permission.resetEmployeePassword,
    Permission.updateEmployeeRole,
    Permission.viewActivityLogs,
    Permission.viewCustomer,
    Permission.manageCustomer,
    Permission.viewCatalog,
    Permission.viewDevice,
    Permission.manageDevice,
    Permission.viewRepairOrder,
    Permission.createRepairOrder,
    Permission.updateRepairOrder,
    Permission.assignRepairOrder,
    Permission.completeRepairOrder,
    Permission.viewReports,
    // Manual notification UI is restricted to admin and manager.
    Permission.viewNotifications,
    Permission.sendNotifications,
  };

  static const Set<Permission> _receptionPermissions = {
    Permission.readEmployee,
    Permission.viewCustomer,
    Permission.viewCatalog,
    Permission.viewDevice,
    Permission.viewRepairOrder,
    Permission.createRepairOrder,
    Permission.updateRepairOrder,
  };

  static const Set<Permission> _technicianPermissions = {
    Permission.readEmployee,
    Permission.viewRepairOrder,
    Permission.updateRepairOrder,
    Permission.assignRepairOrder,
    Permission.completeRepairOrder,
  };

  static const Set<Permission> _customerPermissions = <Permission>{};

  static Set<Permission> of(UserRole role) => switch (role) {
        UserRole.admin => _adminPermissions,
        UserRole.manager => _managerPermissions,
        UserRole.reception => _receptionPermissions,
        UserRole.technician => _technicianPermissions,
        UserRole.customer => _customerPermissions,
      };
}
