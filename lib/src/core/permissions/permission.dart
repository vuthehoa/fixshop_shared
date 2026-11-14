enum Permission {
  // Employee management
  createEmployee,
  readEmployee,
  updateEmployee,
  disableEmployee,
  deleteEmployee,
  resetEmployeePassword,
  updateEmployeeRole,

  // Activity logs
  viewActivityLogs,

  // Future modules (declared now so PermissionResolver is extensible)
  viewCustomer,
  manageCustomer,
  viewCatalog,
  manageCatalog,
  viewDevice,
  manageDevice,
  viewRepairOrder,
  createRepairOrder,
  updateRepairOrder,
  assignRepairOrder,
  completeRepairOrder,
  viewReports,
  manageSystemSettings,
  // Existing CMS references; declaration alone grants no non-admin rights.
  manageWarranty,
  cancelRepairOrder,
  viewNotifications,
  sendNotifications,

  // 2026-11-14 — CMS core pages (mirror of firestore.rules)
  /// support_requests inbox (rules: isSupportStaff = admin/manager/reception).
  manageSupportRequests,
  /// system_health/latest (rules: admin/manager read).
  viewSystemHealth,
}
