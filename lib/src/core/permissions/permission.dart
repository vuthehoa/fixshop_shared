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
}
