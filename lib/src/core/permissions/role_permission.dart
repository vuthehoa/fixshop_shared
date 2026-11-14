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
    Permission.manageSupportRequests,
    Permission.viewSystemHealth,
  };

  static const Set<Permission> _receptionPermissions = {
    Permission.readEmployee,
    Permission.viewCustomer,
    // Front desk registers walk-in customers and their devices (rules:
    // customers/devices create+update = admin/manager/reception).
    Permission.manageCustomer,
    Permission.viewCatalog,
    Permission.viewDevice,
    Permission.manageDevice,
    Permission.viewRepairOrder,
    Permission.createRepairOrder,
    Permission.updateRepairOrder,
    Permission.manageSupportRequests,
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
